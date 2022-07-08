import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import utils 1.0
import shared.panels 1.0

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
    property string channelColor: ""
    property bool emojiPopupOpened: false
    property var emojiPopup: null
    readonly property int communityColorValidator: Utils.Validate.NoEmpty
                                                   | Utils.Validate.TextHexColor

    readonly property int maxChannelNameLength: 24
    readonly property int maxChannelDescLength: 140

    signal createCommunityChannel(string chName, string chDescription, string chEmoji,
        string chColor, string chCategoryId)
    signal editCommunityChannel(string chName, string chDescription, string chEmoji, string chColor,
        string chCategoryId)

    header.title: qsTr("New channel")

    onOpened: {
        contentItem.channelName.input.text = ""
        contentItem.channelName.input.icon.emoji = ""
        contentItem.channelName.input.edit.forceActiveFocus(Qt.MouseFocusReason)
        if (isEdit) {
            header.title = qsTr("Edit #%1").arg(popup.channelName);
            contentItem.channelName.input.text = popup.channelName
            contentItem.channelDescription.input.text = popup.channelDescription
            if (popup.channelEmoji) {
                contentItem.channelName.input.icon.emoji = popup.channelEmoji
            }
            scrollView.channelColorDialog.color = popup.channelColor
        } else {
            contentItem.channelName.input.icon.isLetterIdenticon = true;
        }
    }

    onClosed: destroy()

    Connections {
        enabled: popup.opened && popup.emojiPopupOpened
        target: emojiPopup

        onEmojiSelected: function (emojiText, atCursor) {
            contentItem.channelName.input.icon.isLetterIdenticon = false;
            scrollView.channelName.input.icon.emoji = emojiText
        }
        onClosed: {
            popup.emojiPopupOpened = false
        }
    }

    function isFormValid() {
        return (scrollView.channelName.valid &&
                scrollView.channelDescription.valid) &&
                Utils.validateAndReturnError(scrollView.channelColorDialog.color.toString().toUpperCase(),
                                        communityColorValidator) === ""
    }

    contentItem: ScrollView {

        id: scrollView

        property ScrollBar vScrollBar: ScrollBar.vertical

        property alias channelName: nameInput
        property alias channelDescription: descriptionTextArea
        property alias channelColorDialog: colorDialog

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
            topPadding: 16

            StatusInput {
                id: nameInput

                anchors.left: parent.left
                anchors.leftMargin: 16

                label: qsTr("Channel name")
                charLimit: popup.maxChannelNameLength
                input.placeholderText: qsTr("Name the channel")
                input.onTextChanged: {
                    input.text = Utils.convertSpacesToDashesAndUpperToLowerCase(input.text);
                    input.cursorPosition = input.text.length
                    if (popup.channelEmoji === "") {
                        input.letterIconName = text;
                    }
                }
                input.icon.color: colorDialog.color.toString()
                input.leftPadding: 16
                input.rightComponent: StatusRoundButton {
                    implicitWidth: 20
                    implicitHeight: 20
                    icon.width: implicitWidth
                    icon.height: implicitHeight
                    icon.name: "smiley"
                    onClicked: {
                        popup.emojiPopupOpened = true;
                        popup.emojiPopup.open();
                        popup.emojiPopup.emojiSize = StatusQUtils.Emoji.size.verySmall;
                        popup.emojiPopup.x = popup.width - 2*Style.current.xlPadding;
                        popup.emojiPopup.y = popup.y + nameInput.height + 2*Style.current.xlPadding;
                    }
                }
                validationMode: StatusInput.ValidationMode.Always
                validators: [
                    StatusMinLengthValidator {
                        minLength: 1
                        errorMessage: Utils.getErrorMessage(nameInput.errors, qsTr("channel name"))
                    }
                ]
            }

            Item {
                id: spacer1
                height: 16
                width: parent.width
            }

            StatusBaseText {
                text: qsTr("Channel colour")
                font.pixelSize: 15
                color: Theme.palette.directColor1
                anchors.left: parent.left
                anchors.leftMargin: 16
            }

            Item {
                id: spacer2
                height: 8
                width: parent.width
            }

            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                height: colorSelectorButton.height + 16
                width: parent.width - 32

                StatusPickerButton {
                    id: colorSelectorButton

                    property string validationError: ""

                    bgColor: colorDialog.colorSelected ?
                        colorDialog.color : Theme.palette.baseColor2
                    // TODO adjust text color depending on the background color to make it readable
                    // contentColor: colorDialog.colorSelected ? Theme.palette.indirectColor1 : Theme.palette.baseColor1
                    text: colorDialog.colorSelected ?
                        colorDialog.color.toString().toUpperCase() :
                        qsTr("Pick a color")

                    onClicked: colorDialog.open();
                    onTextChanged: {
                        if (colorDialog.colorSelected) {
                            validationError = Utils.validateAndReturnError(text, communityColorValidator)
                        }
                    }
                }

                StatusColorDialog {
                    id: colorDialog
                    anchors.centerIn: parent
                    property bool colorSelected: popup.isEdit && popup.channelColor
                    color: popup.isEdit && popup.channelColor ? popup.channelColor :
                        Theme.palette.primaryColor1
                    onAccepted: colorSelected = true
                }

                StatusBaseText {
                    text: colorSelectorButton.validationError
                    visible: !!text
                    color: Theme.palette.dangerColor1
                    anchors.top: colorSelectorButton.bottom
                    anchors.topMargin: 4
                    anchors.right: colorSelectorButton.right
                }
            }

            StatusInput {
                id: descriptionTextArea

                anchors.left: parent.left
                anchors.leftMargin: 16

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

            /* TODO: use the code below to enable private channels and message limit */
            /* StatusListItem { */
            /*     width: parent.width */
            /*     height: 56 */
            /*     sensor.enabled: false */
            /*     title: qsTr("Private channel") */
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
            /*     text: qsTr("By making a channel private, only members with selected permission will be able to access it") */
            /* } */

            /* StatusModalDivider { */
            /*     topPadding: 8 */
            /*     bottomPadding: 8 */
            /* } */

            /* StatusListItem { */
            /*     width: parent.width */
            /*     height: 56 */
            /*     sensor.enabled: false */
            /*     title: qsTr("Message limit") */
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
            /*     text: qsTr("Limit channel members to sending one message per chose time interval") */
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
                  qsTr("Save") :
                  qsTr("Create")
            onClicked: {
                if (!isFormValid()) {
                    scrollView.scrollBackUp()
                    return
                }
                let error = "";
                let emoji =  StatusQUtils.Emoji.deparseFromParse(popup.contentItem.channelName.input.icon.emoji)

                if (!isEdit) {
                    //popup.contentItem.communityColor.color.toString().toUpperCase()
                    popup.createCommunityChannel(Utils.filterXSS(popup.contentItem.channelName.input.text),
                                                 Utils.filterXSS(popup.contentItem.channelDescription.input.text),
                                                 emoji,
                                                 popup.contentItem.channelColorDialog.color.toString().toUpperCase(),
                                                 popup.categoryId)
                } else {
                    popup.editCommunityChannel(Utils.filterXSS(popup.contentItem.channelName.input.text),
                                                 Utils.filterXSS(popup.contentItem.channelDescription.input.text),
                                                 emoji,
                                                 popup.contentItem.channelColorDialog.color.toString().toUpperCase(),
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
        title: qsTr("Error creating the community")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }
}

