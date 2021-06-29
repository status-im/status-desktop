import QtQuick 2.12
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../components"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    property string communityId
    property QtObject channel
    property bool isEdit: false
    property string categoryId: ""

    readonly property int maxChannelNameLength: 30
    readonly property var channelNameValidator: Utils.Validate.NoEmpty
                                                | Utils.Validate.TextLength
                                                | Utils.Validate.TextLowercaseLettersNumberAndDashes

    readonly property int maxChannelDescLength: 140
    readonly property var channelDescValidator: Utils.Validate.NoEmpty
                                                | Utils.Validate.TextLength
    
    property Component pinnedMessagesPopupComponent

    id: popup
    height: 475

    onOpened: {
        nameInput.text = "";
        if (isEdit) {
            nameInput.text = channel.name;
            title = qsTr("Edit #%1").arg(channel.name);
            descriptionTextArea.text = channel.description;
            // TODO: re-enable once private channels are implemented
            // privateSwitch.checked = channel.private
        }
        nameInput.forceActiveFocus(Qt.MouseFocusReason)
    }
    onClosed: destroy()

    function isFormValid() {
        return Utils.validateAndReturnError(nameInput.text,
                                            channelNameValidator,
                                            qsTr("channel name"),
                                            maxChannelNameLength) === ""
               && Utils.validateAndReturnError(descriptionTextArea.text,
                                               channelDescValidator,
                                               qsTr("channel decription"),
                                               maxChannelDescLength) === ""
    }

    //% "New channel"
    title: qsTrId("new-channel")

    ScrollView {
        property ScrollBar vScrollBar: ScrollBar.vertical

        id: scrollView
        anchors.fill: parent
        rightPadding: Style.current.padding
        anchors.rightMargin: - Style.current.halfPadding
        contentHeight: content.height
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        clip: true

        function scrollBackUp() {
            vScrollBar.setPosition(0)
        }

        Item {
            id: content
            height: childrenRect.height
            width: parent.width

            Input {
                id: nameInput
                //% "A cool name"
                placeholderText: qsTrId("a-cool-name")
                maxLength: popup.maxChannelNameLength

                onTextEdited: {
                    text = Utils.convertSpacesToDashesAndUpperToLowerCase(text);

                    validationError = Utils.validateAndReturnError(text,
                                                                   channelNameValidator,
                                                                   qsTr("channel name"),
                                                                   maxChannelNameLength)
                }
            }

            StyledTextArea {
                id: descriptionTextArea
                //% "Channel description"
                label: qsTrId("channel-description")
                //% "What your channel is about"
                placeholderText: qsTrId("what-your-channel-is-about")

                anchors.top: nameInput.bottom
                anchors.topMargin: Style.current.bigPadding
                customHeight: 88

                onTextChanged: {
                    if(text.length > maxChannelDescLength)
                    {
                        textField.remove(maxChannelDescLength, text.length)
                        return
                    }

                    validationError = Utils.validateAndReturnError(text,
                                                                   channelDescValidator,
                                                                   qsTr("channel decription"),
                                                                   maxChannelDescLength)
                }
            }

            StyledText {
                id: charLimit
                text: `${descriptionTextArea.text.length}/${maxChannelDescLength}`
                anchors.top: descriptionTextArea.bottom
                anchors.topMargin: !descriptionTextArea.validationError ? 5 : - Style.current.smallPadding
                anchors.right: descriptionTextArea.right
                font.pixelSize: 12
                color: !descriptionTextArea.validationError ? Style.current.textColor : Style.current.danger
            }

            // Separator {
            //     id: separator1
            //     anchors.top: charLimit.bottom
            //     anchors.topMargin: Style.current.bigPadding
            // }

            // TODO: use the switch below to enable private channels
            // Item {
            //     id: privateSwitcher
            //     height: privateSwitch.height
            //     width: parent.width
            //     anchors.top: separator1.bottom
            //     anchors.topMargin: Style.current.smallPadding * 2

            //     StyledText {
            //         //% "Private channel"
            //         text: qsTrId("private-channel")
            //         anchors.verticalCenter: parent.verticalCenter
            //     }

            //     StatusSwitch {
            //         id: privateSwitch
            //         anchors.right: parent.right
            //     }
            // }

            // StyledText {
            //     id: privateExplanation
            //     anchors.top: privateSwitcher.bottom
            //     color: Style.current.secondaryText
            //     wrapMode: Text.WordWrap
            //     anchors.topMargin: Style.current.smallPadding * 2
            //     width: parent.width
            //     //% "By making a channel private, only members with selected permission will be able to access it"
            //     text: qsTrId("by-making-a-channel-private--only-members-with-selected-permission-will-be-able-to-access-it")
            // }

            CommunityPopupButton {
                id: memberBtn
                label: qsTr("Pinned messages")
                iconName: "../pin"
                txtColor: Style.current.textColor
                onClicked: openPopup(pinnedMessagesPopupComponent)
                anchors.top: charLimit.bottom
                anchors.topMargin: Style.current.bigPadding
                
                Item {
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.padding
                    anchors.verticalCenter: parent.verticalCenter
                    width: childrenRect.width
                    height: memberBtn.height

                    StyledText {
                        id: nbPinMessagesText
                        text: chatsModel.messageView.pinnedMessagesList.count
                        anchors.verticalCenter: parent.verticalCenter
                        padding: 0
                        font.pixelSize: 15
                        color: Style.current.secondaryText
                    }

                    SVGImage {
                        id: caret
                        anchors.left: nbPinMessagesText.right
                        anchors.leftMargin: Style.current.padding
                        anchors.verticalCenter: parent.verticalCenter
                        source: "../../../img/caret.svg"
                        width: 13
                        height: 7
                        rotation: -90
                        ColorOverlay {
                            anchors.fill: parent
                            source: parent
                            color: Style.current.secondaryText
                        }
                    }
                }
            }
        }
    }

    footer: StatusButton {
        enabled: isFormValid()
        text: isEdit ?
              qsTr("Save") :
              //% "Create"
              qsTrId("create")
        anchors.right: parent.right
        onClicked: {
            if (!isFormValid()) {
                scrollView.scrollBackUp()
                return
            }
            let error = "";
            if (!isEdit) {
                error = chatsModel.createCommunityChannel(communityId,
                                                            Utils.filterXSS(nameInput.text),
                                                            Utils.filterXSS(descriptionTextArea.text),
							    categoryId)
                                                            // TODO: pass the private value when private channels
                                                            // are implemented
                                                            //privateSwitch.checked)
            } else {
                error = chatsModel.editCommunityChannel(communityId,
                                                            channel.id,
                                                            Utils.filterXSS(nameInput.text),
                                                            Utils.filterXSS(descriptionTextArea.text),
							    categoryId)
                                                            // TODO: pass the private value when private channels
                                                            // are implemented
                                                            //privateSwitch.checked)
            }

            if (error) {
                const errorJson = JSON.parse(error)
                creatingError.text = errorJson.error
                return creatingError.open()
            }

            // TODO Open the community once we have designs for it
            popup.close()
        }

        MessageDialog {
            id: creatingError
            //% "Error creating the community"
            title: qsTrId("error-creating-the-community")
            icon: StandardIcon.Critical
            standardButtons: StandardButton.Ok
        }
    }
}

