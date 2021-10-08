import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import utils 0.1

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

StatusModal {
    id: popup
    property string communityId
    property QtObject channel
    property bool isEdit: false
    property string categoryId: ""
    property var position: null

    readonly property int maxChannelNameLength: 30
    readonly property int maxChannelDescLength: 140
    
    property Component pinnedMessagesPopupComponent

    //% "New channel"
    header.title: qsTrId("create-channel-title")

    onOpened: {
        contentItem.channelName.input.text = ""
        contentItem.channelName.input.forceActiveFocus(Qt.MouseFocusReason)
        if (isEdit) {
            //% "Edit #%1"
            header.title = qsTrId("edit---1").arg(channel.name);
            contentItem.channelId = channel.id
            contentItem.channelCategoryId = channel.categoryId
            contentItem.channelName.input.text = channel.name
            contentItem.channelDescription.input.text = channel.description
            position = channel.position
        }
    }

    onClosed: destroy()

    function isFormValid() {
        return contentItem.channelName.valid &&
               contentItem.channelDescription.valid
    }

    contentItem: ScrollView {

        id: scrollView

        property ScrollBar vScrollBar: ScrollBar.vertical

        property alias channelName: nameInput
        property alias channelDescription: descriptionTextArea
        property string channelId
        property string channelCategoryId

        contentHeight: content.height
        height: Math.min(content.height, 432)
        width: popup.width

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        clip: true

        function scrollBackUp() {
            vScrollBar.setPosition(0)
        }

        Column {
            id: content
            width: popup.width

            StatusInput {
                id: nameInput
                charLimit: popup.maxChannelNameLength
                input.placeholderText: qsTr("Channel name")
                input.onTextChanged: {
                    input.text = Utils.convertSpacesToDashesAndUpperToLowerCase(input.text);
                    input.cursorPosition = input.text.length
                }
                validators: [StatusMinLengthValidator {
                    minLength: 1
                    errorMessage: Utils.getErrorMessage(errors, qsTr("channel name"))
                }]
            }

            StatusModalDivider {
                topPadding: 8
                bottomPadding: 8
            }

            StatusInput {
                id: descriptionTextArea
                label: qsTr("Description")
                charLimit: 140

                input.placeholderText: qsTr("Describe the channel")
                input.multiline: true
                input.implicitHeight: 88
                validators: [StatusMinLengthValidator {
                    minLength: 1
                    errorMessage:  Utils.getErrorMessage(errors, qsTr("channel description"))
                }]
            }

            /* TODO: use the code below to enable private channels and message limit */
            /* StatusListItem { */
            /*     width: parent.width */
            /*     height: 56 */
            /*     sensor.enabled: false */
            //% "Private channel"
            /*     title: qsTrId("private-channel") */
            /*     components: [ */
            /*         StatusSwitch { */
            /*             id: privateSwitch */
            /*         } */
            /*     ] */
            /* } */

            /* StatusBaseText { */
            /*     width: parent.width - 32 */
            /*     anchors.left: parent.left */
            /*     anchors.right: parent.right */
            /*     anchors.rightMargin: 121 */
            /*     anchors.leftMargin: 16 */
            /*     color: Theme.palette.baseColor1 */
            /*     wrapMode: Text.WordWrap */
            //% "By making a channel private, only members with selected permission will be able to access it"
            /*     text: qsTrId("by-making-a-channel-private--only-members-with-selected-permission-will-be-able-to-access-it") */
            /* } */

            /* StatusModalDivider { */
            /*     topPadding: 8 */
            /*     bottomPadding: 8 */
            /* } */

            /* StatusListItem { */
            /*     width: parent.width */
            /*     height: 56 */
            /*     sensor.enabled: false */
            //% "Message limit"
            /*     title: qsTrId("message-limit") */
            /*     components: [ */
            /*         StatusSwitch {} */
            /*     ] */
            /* } */

            /* StatusBaseText { */
            /*     width: parent.width - 32 */
            /*     anchors.left: parent.left */
            /*     anchors.right: parent.right */
            /*     anchors.rightMargin: 121 */
            /*     anchors.leftMargin: 16 */
            /*     color: Theme.palette.baseColor1 */
            /*     wrapMode: Text.WordWrap */
            //% "Limit channel members to sending one message per chose time interval"
            /*     text: qsTrId("limit-channel-members-to-sending-one-message-per-chose-time-interval") */
            /* } */

            Item {
                width: parent.width
                height: 8
            }

            StatusListItem {
                anchors.horizontalCenter: parent.horizontalCenter
                //% "Pinned messages"
                title: qsTrId("pinned-messages")
                icon.name: "pin"
                label: chatsModel.messageView.pinnedMessagesList.count
                components: [
                    StatusIcon {
                        icon: "chevron-down"
                        rotation: 270
                        color: Theme.palette.baseColor1
                    }
                ]

                sensor.onClicked: openPopup(pinnedMessagesPopupComponent)
            }

            Item {
                width: parent.width
                height: 8
            }
        }
    }
 
    rightButtons: [
        StatusButton {
            enabled: isFormValid()
            text: isEdit ?
                  //% "Save"
                  qsTrId("save") :
                  //% "Create"
                  qsTrId("create")
            onClicked: {
                if (!isFormValid()) {
                    scrollView.scrollBackUp()
                    return
                }
                let error = "";
                if (!isEdit) {
                    error = chatsModel.createCommunityChannel(communityId,
                                                                Utils.filterXSS(popup.contentItem.channelName.input.text),
                                                                Utils.filterXSS(popup.contentItem.channelDescription.input.text),
                                                                categoryId)
                                                                // TODO: pass the private value when private channels
                                                                // are implemented
                                                                //privateSwitch.checked)
                } else {
                    error = chatsModel.editCommunityChannel(communityId,
                                                                popup.contentItem.channelId,
                                                                Utils.filterXSS(popup.contentItem.channelName.input.text),
                                                                Utils.filterXSS(popup.contentItem.channelDescription.input.text),
                                                                popup.contentItem.channelCategoryId,
                                                                popup.position)
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
        }
    ]

    MessageDialog {
        id: creatingError
        //% "Error creating the community"
        title: qsTrId("error-creating-the-community")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }
}

