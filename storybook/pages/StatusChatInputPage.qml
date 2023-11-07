import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import Models 1.0

import utils 1.0
import shared.status 1.0
import shared.stores 1.0

import StatusQ.Core.Utils 0.1

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
            RootStore.isWalletEnabled = true
            RootStore.gifUnfurlingEnabled = true
            RootStore.getSelectedTextWithFormationChars = rootStoreMock.getSelectedTextWithFormationChars
            RootStore.gifColumnA = rootStoreMock.gifColumnA
            rootStoreMock.ready = true
        }
    }

    UsersModel {
        id: fakeUsersModel
    }

    LinkPreviewModel {
        id: fakeLinksModel
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
            id: chatInputLoader
            active: rootStoreMock.ready && globalUtilsMock.ready
            sourceComponent: StatusChatInput {
                id: chatInput
                property var globalUtils: globalUtilsMock.globalUtils
                property string unformattedText: chatInput.textInput.getText(0, chatInput.textInput.length)

                readonly property ModelChangeTracker urlsModelChangeTracker: ModelChangeTracker {
                    model: fakeLinksModel
                }

                onUnformattedTextChanged: {
                    textEditConnection.enabled = false
                    d.loadLinkPreviews(unformattedText)
                    textEditConnection.enabled = true
                }

                Connections {
                    id: textEditConnection
                    target: chatInput.textInput
                    function onTextChanged() {
                        if(unformattedText !== chatInput.textInput.getText(0, chatInput.textInput.length))
                            unformattedText = chatInput.textInput.getText(0, chatInput.textInput.length)
                    }
                }

                enabled: enabledCheckBox.checked
                linkPreviewModel: fakeLinksModel
                urlsList: {
                    urlsModelChangeTracker.revision
                    ModelUtils.modelToFlatArray(fakeLinksModel, "url")
                }
                askToEnableLinkPreview: askToEnableLinkPreviewSwitch.checked
                onAskToEnableLinkPreviewChanged: {
                    if(askToEnableLinkPreview) {
                        fakeLinksModel.clear()
                        d.loadLinkPreviews(unformattedText)
                    }
                }
                usersStore: QtObject {
                    readonly property var usersModel: fakeUsersModel
                }
                onSendMessage: {
                    logs.logEvent("StatusChatInput::sendMessage", ["MessageWithPk"], [chatInput.getTextWithPublicKeys()])
                    logs.logEvent("StatusChatInput::sendMessage", ["PlainText"], [globalUtilsMock.globalUtils.plainText(chatInput.getTextWithPublicKeys())])
                    logs.logEvent("StatusChatInput::sendMessage", ["RawText"], [chatInput.textInput.text])
                }
                onEnableLinkPreviewForThisMessage: {
                    linkPreviewSwitch.checked = true
                    askToEnableLinkPreviewSwitch.checked = false
                }
                onEnableLinkPreview: {
                    linkPreviewSwitch.checked = true
                    askToEnableLinkPreviewSwitch.checked = false
                }
                onDisableLinkPreview: {
                    linkPreviewSwitch.checked = false
                    askToEnableLinkPreviewSwitch.checked = false
                }
                onDismissLinkPreviewSettings: {
                    askToEnableLinkPreviewSwitch.checked = false
                    linkPreviewSwitch.checked = false
                }
                onDismissLinkPreview: (index) => {
                    fakeLinksModel.setProperty(index, "unfurled", false)
                    fakeLinksModel.setProperty(index, "immutable", true)
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }

        QtObject {
            id: d
            property bool linkPreviewsEnabled: linkPreviewSwitch.checked && !askToEnableLinkPreviewSwitch.checked
            onLinkPreviewsEnabledChanged: {
                loadLinkPreviews(chatInputLoader.item ? chatInputLoader.item.unformattedText : "")
            }
            function loadLinkPreviews(text) {
                var words = text.split(/\s+/)

                fakeLinksModel.clear()
                words.forEach(function(word){
                    if(Utils.isURL(word)) {
                        const linkPreview = fakeLinksModel.getStandardLinkPreview()
                        linkPreview.url = encodeURI(word)
                        linkPreview.unfurled = Math.random() > 0.2
                        linkPreview.immutable = !d.linkPreviewsEnabled
                        linkPreview.empty = Math.random() > 0.7
                        fakeLinksModel.append(linkPreview)
                    }
                })
            }
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

            TabBar {
                id: bar
                TabButton {
                    text: "Attachments"
                }
                TabButton {
                    text: "Users"
                }
            }

            StackLayout {
                currentIndex: bar.currentIndex
                ColumnLayout {
                    id: attachmentsTab
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Label {
                        text: "Images"
                        Layout.fillWidth: true
                    }
                    ComboBox {
                        id: imageNb
                        editable: true
                        model: 20
                        validator: IntValidator {bottom: 0; top: 20;}
                        focus: true
                        onCurrentIndexChanged: {
                            if(!chatInputLoader.item)
                                return
                            const urls = []
                            for (let i = 0; i < imageNb.currentIndex ; i++) {
                                urls.push("https://picsum.photos/200/300?random=" + i)
                            }
                            console.log(urls.length)
                            chatInputLoader.item.fileUrlsAndSources = urls
                        }
                    }
                    Label {
                        text: "Links"
                        Layout.fillWidth: true
                    }

                    Switch {
                        id: linkPreviewSwitch
                        text: "Link Preview enabled"
                    }

                    Switch {
                        id: askToEnableLinkPreviewSwitch
                        text: "Ask to enable Link Preview"
                        checked: true
                    }

                    ComboBox {
                        id: linksNb
                        editable: true
                        model: 20
                        validator: IntValidator {bottom: 0; top: 20;}
                        onCurrentIndexChanged: {
                            if(!chatInputLoader.item)
                                return
                            let urls = ""
                            for (let i = 0; i < linksNb.currentIndex ; i++) {
                                urls += "https://www.youtube.com/watch?v=9bZkp7q19f0" + Math.floor(Math.random() * 100) + " "
                            }

                            chatInputLoader.item.textInput.text = urls
                        }
                    }
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
            Label {
                text: "Attachments"
                Layout.fillWidth: true
            }
        }
    }
}

// category: Components

// https://www.figma.com/file/Mr3rqxxgKJ2zMQ06UAKiWL/💬-Chat⎜Desktop?type=design&node-id=23155-66084&mode=design&t=VWBVK4DOUxr1BmTp-0
