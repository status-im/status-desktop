import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import "../../../../imports"

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

    readonly property int maxChannelNameLength: 30
    readonly property int maxChannelDescLength: 140
    
    property Component pinnedMessagesPopupComponent

    //% "New channel"
    header.title: qsTrId("create-channel-title")

    onOpened: {
        contentComponent.channelName.input.text = ""
        if (isEdit) {
            //% "Edit #%1"
            header.title = qsTrId("edit---1").arg(channel.name);
            contentComponent.channelName.input.text = channel.name
        }
        contentComponent.channelName.input.forceActiveFocus(Qt.MouseFocusReason)
    }

    onClosed: destroy()

    function isFormValid() {
        return contentComponent.channelName.valid &&
               contentComponent.channelDescription.valid
    }

    content: ScrollView {

        id: scrollView

        property ScrollBar vScrollBar: ScrollBar.vertical

        property alias channelName: nameInput
        property alias channelDescription: descriptionTextArea

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
                    errorMessage = Utils.getErrorMessage(errors, qsTr("channel name"))
                }
                validators: [StatusMinLengthValidator { minLength: 1 }]
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
                input.text: popup.isEdit ? popup.channel.description : ""
                input.onTextChanged: errorMessage = Utils.getErrorMessage(errors, qsTr("channel description"))
                validators: [StatusMinLengthValidator { minLength: 1 }]
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

            StatusModalDivider {
                topPadding: 8
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
                                                                Utils.filterXSS(popup.contentComponent.channelName.input.text),
                                                                Utils.filterXSS(popup.contentComponent.channelDescription.input.text),
                      categoryId)
                                                                // TODO: pass the private value when private channels
                                                                // are implemented
                                                                //privateSwitch.checked)
                } else {
                    error = chatsModel.editCommunityChannel(communityId,
                                                                channel.id,
                                                                Utils.filterXSS(popup.contentComponent.channelName.input.text),
                                                                Utils.filterXSS(popup.contentComponent.channelDescription.input.text),
                      channel.categoryId)
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

