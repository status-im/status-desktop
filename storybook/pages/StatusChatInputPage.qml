import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import Models 1.0

import utils 1.0
import shared.status 1.0
import shared.stores 1.0

SplitView {
    id: root

    Logs { id: logs }

    QtObject {
        id: globalUtilsMock

        property bool ready: false
        property var globalUtils: QtObject {
            function plainText(htmlText) {
                return htmlText.replace(/(?:<style[^]+?>[^]+?<\/style>|[\n]|<script[^]+?>[^]+?<\/script>|<(?:!|\/?[a-zA-Z]+).*?\/?>)/g,'')
            }
            function isCompressedPubKey(publicKey) {
                return false
            }
        }
        Component.onCompleted: {
            Utils.globalUtilsInst = globalUtilsMock.globalUtils
            Global.dragArea = null
            globalUtilsMock.ready = true
        }
    }

    QtObject {
        id: rootStoreMock

        property bool ready: false

        readonly property ListModel gifColumnA: ListModel {}

        readonly property var formationChars: (["*", "`", "~"])

        function getSelectedTextWithFormationChars(messageInputField) {
            let i = 1
            let text = ""
            while (true) {
                if (messageInputField.selectionStart - i < 0 && messageInputField.selectionEnd + i > messageInputField.length) {
                    break
                }

                text = messageInputField.getText(messageInputField.selectionStart - i, messageInputField.selectionEnd + i)

                if (!formationChars.includes(text.charAt(0)) ||
                        !formationChars.includes(text.charAt(text.length - 1))) {
                    break
                }
                i++
            }
            return text
        }

        Component.onCompleted: {
            RootStore.isGifWidgetEnabled = true
            RootStore.isWalletEnabled = true
            RootStore.isTenorWarningAccepted = true
            RootStore.getSelectedTextWithFormationChars = rootStoreMock.getSelectedTextWithFormationChars
            RootStore.gifColumnA = rootStoreMock.gifColumnA
            rootStoreMock.ready = true
        }
    }

    UsersModel {
        id: fakeUsersModel
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true
        //dummy item to position chatInput at the bottom
        Item {
            SplitView.fillHeight: true
            SplitView.fillWidth: true
        }

        Loader {
            active: rootStoreMock.ready && globalUtilsMock.ready
            sourceComponent: StatusChatInput {
                id: chatInput
                property var globalUtils: globalUtilsMock.globalUtils
                enabled: enabledCheckBox.checked
                usersStore: QtObject {
                    readonly property var usersModel: fakeUsersModel
                }
                onSendMessage: {
                    logs.logEvent("StatusChatInput::sendMessage", ["MessageWithPk"], [chatInput.getTextWithPublicKeys()])
                    logs.logEvent("StatusChatInput::sendMessage", ["PlainText"], [globalUtilsMock.globalUtils.plainText(chatInput.getTextWithPublicKeys())])
                    logs.logEvent("StatusChatInput::sendMessage", ["RawText"], [chatInput.textInput.text])
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }
    }

    Pane {
         SplitView.minimumWidth: 300
         SplitView.preferredWidth: 300

         ColumnLayout {
             anchors.fill: parent
             CheckBox {
                 id: enabledCheckBox
                 text: "enabled"
                 checked: true
             }
             MenuSeparator {
                 Layout.fillWidth: true
             }
             UsersModelEditor {
                 id: modelEditor
                 Layout.fillWidth: true
                 Layout.fillHeight: true
                 model: fakeUsersModel

                 onRemoveClicked: fakeUsersModel.remove(index, 1)
                 onRemoveAllClicked: fakeUsersModel.clear()
                 onAddClicked: fakeUsersModel.append(modelEditor.getNewUser(fakeUsersModel.count))
             }
         }
     }
}
