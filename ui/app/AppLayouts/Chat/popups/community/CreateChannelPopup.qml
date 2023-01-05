import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3
import QtQml.Models 2.14

import utils 1.0
import shared.panels 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialog {
    id: root
    width: 480
    height: 509

    property bool isEdit: false
    property bool isDeleteable: false
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

    signal createCommunityChannel(string chName, string chDescription, string chEmoji, string chColor, string chCategoryId)
    signal editCommunityChannel(string chName, string chDescription, string chEmoji, string chColor, string chCategoryId)
    signal deleteCommunityChannel()

    title: qsTr("New channel")

    onOpened: {
        nameInput.text = ""
        nameInput.input.asset.emoji = ""
        nameInput.input.edit.forceActiveFocus(Qt.MouseFocusReason)
        if (isEdit) {
            root.title = qsTr("Edit #%1").arg(root.channelName);
            nameInput.text = root.channelName
            descriptionTextArea.text = root.channelDescription
            if (root.channelEmoji) {
                nameInput.input.asset.emoji = root.channelEmoji
            }
            colorDialog.color = root.channelColor
        } else {
            nameInput.input.asset.isLetterIdenticon = true;
        }
    }

    onClosed: destroy()

    Connections {
        enabled: root.opened && root.emojiPopupOpened
        target: emojiPopup

        onEmojiSelected: function (emojiText, atCursor) {
            nameInput.input.asset.isLetterIdenticon = false;
            nameInput.input.asset.emoji = emojiText
        }
        onClosed: {
            root.emojiPopupOpened = false
        }
    }

    function isFormValid() {
        return (nameInput.valid &&
                descriptionTextArea.valid) &&
                Utils.validateAndReturnError(colorDialog.color.toString().toUpperCase(),
                                             communityColorValidator) === ""
    }

    StatusScrollView {

        id: scrollView

        property ScrollBar vScrollBar: ScrollBar.vertical

        width: root.width
        height: Math.min(content.height, 432)
        leftPadding: 0
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        function scrollBackUp() {
            vScrollBar.setPosition(0)
        }

        Column {
            id: content

            StatusInput {
                id: nameInput
                input.edit.objectName: "createOrEditCommunityChannelNameInput"
                label: qsTr("Channel name")
                charLimit: root.maxChannelNameLength
                placeholderText: qsTr("# Name the channel")

                input.onTextChanged: {
                    const cursorPosition = input.cursorPosition
                    input.text = Utils.convertSpacesToDashesAndUpperToLowerCase(input.text)
                    input.cursorPosition = cursorPosition
                    if (root.channelEmoji === "") {
                        input.letterIconName = text;
                    }
                }
                input.asset.color: colorDialog.color.toString()
                leftPadding: 16
                input.rightComponent: StatusRoundButton {
                    objectName: "StatusChannelPopup_emojiButton"
                    implicitWidth: 32
                    implicitHeight: 32
                    icon.width: 20
                    icon.height: 20
                    icon.name: "smiley"
                    onClicked: {
                        root.emojiPopupOpened = true;
                        root.emojiPopup.open();
                        root.emojiPopup.emojiSize = StatusQUtils.Emoji.size.verySmall;
                        root.emojiPopup.x = root.x + (root.width - root.emojiPopup.width - Style.current.padding);
                        root.emojiPopup.y = root.y + root.header.height + root.topPadding + nameInput.height + Style.current.smallPadding;
                    }
                }
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
            }

            Item {
                id: spacer2
                height: 8
                width: parent.width
            }

            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                height: colorSelectorButton.height + 16
                width: parent.width

                StatusPickerButton {
                    id: colorSelectorButton

                    property string validationError: ""

                    bgColor: colorDialog.colorSelected ?
                                 colorDialog.color : Theme.palette.baseColor2
                    // TODO adjust text color depending on the background color to make it readable
                    // contentColor: colorDialog.colorSelected ? Theme.palette.indirectColor1 : Theme.palette.baseColor1
                    text: colorDialog.colorSelected ?
                              colorDialog.color.toString().toUpperCase() :
                              qsTr("Pick a colour")

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
                    property bool colorSelected: root.isEdit && root.channelColor
                    color: root.isEdit && root.channelColor ? root.channelColor :
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
                input.edit.objectName: "createOrEditCommunityChannelDescriptionInput"
                input.verticalAlignment: TextEdit.AlignTop
                label: qsTr("Description")
                charLimit: 140

                placeholderText: qsTr("Describe the channel")
                input.multiline: true
                minimumHeight: 88
                maximumHeight: 88
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

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusButton {
                objectName: "deleteCommunityChannelBtn"
                visible: isEdit && isDeleteable
                text: qsTr("Delete channel")
                type: StatusBaseButton.Type.Danger
                onClicked: {
                    root.deleteCommunityChannel()
                }
            }
            StatusButton {
                objectName: "createOrEditCommunityChannelBtn"
                enabled: isFormValid()
                text: isEdit ?
                          qsTr("Save changes") :
                          qsTr("Create channel")
                onClicked: {
                    if (!isFormValid()) {
                        scrollView.scrollBackUp()
                        return
                    }
                    let error = "";
                    let emoji =  StatusQUtils.Emoji.deparseFromParse(nameInput.input.asset.emoji)

                    if (!isEdit) {
                        //scrollView.communityColor.color.toString().toUpperCase()
                        root.createCommunityChannel(StatusQUtils.Utils.filterXSS(nameInput.input.text),
                                                     StatusQUtils.Utils.filterXSS(descriptionTextArea.text),
                                                     emoji,
                                                     colorDialog.color.toString().toUpperCase(),
                                                     root.categoryId)
                    } else {
                        root.editCommunityChannel(StatusQUtils.Utils.filterXSS(nameInput.input.text),
                                                   StatusQUtils.Utils.filterXSS(descriptionTextArea.text),
                                                   emoji,
                                                   colorDialog.color.toString().toUpperCase(),
                                                   root.categoryId)
                    }

                    if (error) {
                        const errorJson = JSON.parse(error)
                        creatingError.text = errorJson.error
                        return creatingError.open()
                    }

                    // TODO Open the community once we have designs for it
                    root.close()
                }
            }
        }
    }

    MessageDialog {
        id: creatingError
        title: qsTr("Error creating the community")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }
}

