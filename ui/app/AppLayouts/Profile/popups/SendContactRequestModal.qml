import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1

StatusModal {
    id: root

    property var contactsStore

    header.title: qsTr("Send Contact Request to chat key")

    QtObject {
        id: d
        readonly property int maxMsgLength: 280
        readonly property int minMsgLength: 0 //TODO: update this to 1 later, when we introduce "say who you are" feature
        readonly property int msgHeight: 152
        readonly property int contentSpacing: 0

        property int minChatKeyLength: 4 // ens or chat key
        property string realChatKey: ""
        property string elidedChatKey: realChatKey.length > 32?
                                           realChatKey.substring(0, 15) + "..." + realChatKey.substring(realChatKey.length - 16) :
                                           realChatKey

        property bool validChatKey: false
        property bool showPasteButton: true
        property bool showChatKeyValidationIndicator: false
        property int showChatKeyValidationIndicatorSize: 24

        property var lookupContact: Backpressure.debounce(root, 400, function (value) {
            root.contactsStore.resolveENS(value)
        })
    }

    Connections {
        target: contactsStore.mainModuleInst
        onResolvedENS: {
            if(!d.showChatKeyValidationIndicator){
                d.showPasteButton = false
                d.showChatKeyValidationIndicator = true
            }
            d.validChatKey = resolvedPubKey !== ""
        }
    }

    Component {
        id: chatKeyValidationIndicator
        Item {
            implicitWidth: d.showChatKeyValidationIndicatorSize
            implicitHeight: d.showChatKeyValidationIndicatorSize
            anchors.verticalCenter: parent.verticalCenter
            StatusIcon {
                anchors.fill: parent
                icon: d.validChatKey? "checkmark-circle" : "close-circle"
                color: d.validChatKey? Style.current.success : Style.current.danger
            }
        }
    }

    Component {
        id: pasteButtonComponent
        StatusButton {
            anchors.verticalCenter: parent.verticalCenter
            border.width: 1
            border.color: Theme.palette.primaryColor1
            size: StatusBaseButton.Size.Tiny
            text: qsTr("Paste")
            onClicked: {
                d.realChatKey = root.contactsStore.getFromClipboard()
                d.showPasteButton = false
            }
        }
    }

    contentItem: Column {
        id: content
        width: root.width
        spacing: d.contentSpacing

        StatusInput {
            id: chatKeyInput

            input.placeholderText: qsTr("Enter chat key here")
            input.text: input.edit.focus? d.realChatKey : d.elidedChatKey
            input.rightComponent: {
                if(d.showPasteButton)
                    return pasteButtonComponent
                else if(d.showChatKeyValidationIndicator)
                    return chatKeyValidationIndicator
                else
                    return null
            }
            input.onTextChanged: {
                if(input.edit.focus)
                {
                    d.realChatKey = text

                    if(d.realChatKey === "") {
                        d.showPasteButton = true
                        d.showChatKeyValidationIndicator = false
                    }

                    if (text.length < d.minChatKeyLength) {
                        d.validChatKey = false
                        return
                    }

                    Qt.callLater(d.lookupContact, text);
                }
            }
        }

        StatusInput {
            id: messageInput
            charLimit: d.maxMsgLength

            input.placeholderText: qsTr("Say who you are / why you want to become a contact...")
            input.multiline: true
            input.implicitHeight: d.msgHeight
            input.verticalAlignmet: TextEdit.AlignTop

            validators: [StatusMinLengthValidator {
                    minLength: d.minMsgLength
                    errorMessage: Utils.getErrorMessage(messageInput.errors, qsTr("who are you"))
                }]
            validationMode: StatusInput.ValidationMode.Always
        }
    }

    rightButtons: [
        StatusButton {
            id: btnCreateEdit
            enabled: d.validChatKey && messageInput.valid
            text: qsTr("Send Contact Request")
            onClicked: {
                root.contactsStore.addContact(d.realChatKey)
                root.close()
            }
        }
    ]
}
