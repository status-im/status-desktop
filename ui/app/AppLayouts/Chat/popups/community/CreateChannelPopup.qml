import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.3
import QtQml.Models 2.15

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

    QtObject {
        id: d
        function openEmojiPopup(leftSide = false) {
            root.emojiPopupOpened = true;
            root.emojiPopup.open();
            root.emojiPopup.emojiSize = StatusQUtils.Emoji.size.verySmall;
            root.emojiPopup.x = leftSide ? root.x + Style.current.padding : (root.x + (root.width - root.emojiPopup.width - Style.current.padding));
            root.emojiPopup.y = root.y + root.header.height + root.topPadding + nameInput.height + Style.current.smallPadding;
        }
    }

    title: qsTr("New channel")
    padding: 0

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

    Connections {
        enabled: root.opened && root.emojiPopupOpened
        target: emojiPopup

        function onEmojiSelected(emojiText: string, atCursor: bool) {
            nameInput.input.asset.isLetterIdenticon = false;
            nameInput.input.asset.emoji = emojiText
        }
        function onClosed() {
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

        anchors.fill: parent
        contentWidth: availableWidth
        padding: 16

        function scrollBackUp() {
            vScrollBar.setPosition(0)
        }

        ColumnLayout {
            id: content

            width: scrollView.availableWidth
            spacing: 0

            StatusInput {
                id: nameInput
                Layout.fillWidth: true
                input.edit.objectName: "createOrEditCommunityChannelNameInput"
                label: qsTr("Channel name")
                charLimit: root.maxChannelNameLength
                placeholderText: qsTr("# Name the channel")

                input.onTextChanged: {
                    const cursorPosition = input.cursorPosition
                    input.text = Utils.convertSpacesToDashes(input.text)
                    input.cursorPosition = cursorPosition
                    if (root.channelEmoji === "") {
                        input.letterIconName = text;
                    }
                }
                input.asset.color: colorDialog.color.toString()
                input.rightComponent: StatusRoundButton {
                    objectName: "StatusChannelPopup_emojiButton"
                    implicitWidth: 32
                    implicitHeight: 32
                    icon.width: 20
                    icon.height: 20
                    icon.name: "smiley"
                    onClicked: {
                        d.openEmojiPopup();
                    }
                }
                onIconClicked: {
                    d.openEmojiPopup(true);
                }

                validators: [
                    StatusMinLengthValidator {
                        minLength: 1
                        errorMessage: Utils.getErrorMessage(nameInput.errors, qsTr("channel name"))
                    },
                    StatusRegularExpressionValidator {
                        regularExpression: Constants.regularExpressions.alphanumericalExpanded
                        errorMessage: Constants.errorMessages.alphanumericalExpandedRegExp
                    }
                ]
            }

            Item {
                id: spacer1
                height: 16
                Layout.fillWidth: true
            }

            StatusBaseText {
                Layout.fillWidth: true
                text: qsTr("Channel colour")
                font.pixelSize: 15
                color: Theme.palette.directColor1
            }

            Item {
                id: spacer2
                height: 8
                Layout.fillWidth: true
            }

            Item {
                height: colorSelectorButton.height + 16
                Layout.fillWidth: true

                StatusPickerButton {
                    id: colorSelectorButton

                    property string validationError: ""

                    bgColor: colorDialog.colorSelected ? colorDialog.color : Theme.palette.baseColor2
                    contentColor: colorDialog.colorSelected ? Theme.palette.white : Theme.palette.baseColor1
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
                    header.title: qsTr("Channel Colour")
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
                Layout.fillWidth: true
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
                Layout.fillWidth: true
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
                    let emoji =  StatusQUtils.Emoji.deparse(nameInput.input.asset.emoji)

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

