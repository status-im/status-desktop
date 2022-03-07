import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

StatusModal {
    id: popup

    property bool isEdit: false
    property string chatId: ""
    property string categoryId: ""
    property string channelName: ""
    property string channelDescription: ""
    property string channelEmoji: ""
    property bool emojiPopupOpened: false
    property var emojiPopup: null
    readonly property string emojiRegexStr: 'alt="(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])"'

    readonly property int maxChannelNameLength: 30
    readonly property int maxChannelDescLength: 140

    signal createCommunityChannel(string chName, string chDescription, string chEmoji, string chCategoryId)
    signal editCommunityChannel(string chName, string chDescription, string chEmoji, string chCategoryId)

    //% "New channel"
    header.title: qsTrId("create-channel-title")

    onOpened: {
        contentItem.channelName.input.text = ""
        contentItem.channelName.input.forceActiveFocus(Qt.MouseFocusReason)
        if (isEdit) {
            //% "Edit #%1"
            header.title = qsTrId("edit---1").arg(popup.channelName);
            contentItem.channelName.input.text = popup.channelName
            contentItem.channelDescription.input.text = popup.channelDescription
            contentItem.channelEmoji.text = StatusQUtils.Emoji.parse(popup.channelEmoji)
        }
    }

    onClosed: destroy()

    Connections {
        enabled: popup.opened && popup.emojiPopupOpened
        target: emojiPopup

        onEmojiSelected: function (emojiText, atCursor) {
            scrollView.channelEmoji.text = emojiText
        }
        onClosed: {
            popup.emojiPopupOpened = false
        }
    }

    function isFormValid() {
        return (scrollView.channelName.valid &&
               scrollView.channelDescription.valid)
    }

    contentItem: ScrollView {

        id: scrollView

        property ScrollBar vScrollBar: ScrollBar.vertical

        property alias channelName: nameInput
        property alias channelDescription: descriptionTextArea
        property alias channelEmoji: emojiText

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
                validationMode: StatusInput.ValidationMode.Always
                validators: [StatusMinLengthValidator {
                    minLength: 1
                    errorMessage: Utils.getErrorMessage(nameInput.errors, qsTr("channel name"))
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
                validationMode: StatusInput.ValidationMode.Always
                validators: [StatusMinLengthValidator {
                    minLength: 1
                    errorMessage:  Utils.getErrorMessage(descriptionTextArea.errors, qsTr("channel description"))
                }]
            }

            // TODO replace this with the new emoji + name + color input when it is implemented in StatusQ
            Item {
                width: parent.width
                height: childrenRect.height + 8

                StatusButton {
                    id: emojiBtn
                    text: qsTr("Choose emoji")
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    onClicked: {
                        popup.emojiPopupOpened = true
                        popup.emojiPopup.open()
                        popup.emojiPopup.x = Global.applicationWindow.width/2 - popup.emojiPopup.width/2 + popup.width/2
                        popup.emojiPopup.y = Global.applicationWindow.height/2 - popup.emojiPopup.height/2
                    }
                }
                StatusBaseText {
                    id: emojiText
                    font.pixelSize: 15
                    anchors.verticalCenter: emojiBtn.verticalCenter
                    anchors.left: emojiBtn.right
                    anchors.leftMargin: 8
                }
                StatusButton {
                    id: removeEmojiBtn
                    visible: !!emojiText.text
                    text: qsTr("Remove emoji")
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    anchors.left: emojiText.right
                    anchors.leftMargin: 8
                    onClicked: {
                        emojiText.text = ""
                    }
                }
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
                let emoji = ""
                const found = RegExp(emojiRegexStr, 'g').exec(popup.contentItem.channelEmoji.text);
                if (found) {
                    emoji = found[1]
                }
                if (!isEdit) {
                    popup.createCommunityChannel(Utils.filterXSS(popup.contentItem.channelName.input.text),
                                                 Utils.filterXSS(popup.contentItem.channelDescription.input.text),
                                                 emoji,
                                                 popup.categoryId)
                } else {
                    popup.editCommunityChannel(Utils.filterXSS(popup.contentItem.channelName.input.text),
                                                 Utils.filterXSS(popup.contentItem.channelDescription.input.text),
                                                 emoji,
                                                 popup.categoryId)
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

