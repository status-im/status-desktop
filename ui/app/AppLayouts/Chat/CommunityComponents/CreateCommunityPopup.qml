import QtQuick 2.12
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    readonly property int maxDescChars: 140

    property QtObject community: chatsModel.communities.activeCommunity

    property bool isEdit: false
    property bool isValid:
        nameInput.isValid &&
        descriptionTextArea.isValid &&
        colorPicker.isValid

    id: popup
    height: 600

    onOpened: {
        if (isEdit) {
            nameInput.text = community.name;
            descriptionTextArea.text = community.description;
        }
        nameInput.forceActiveFocus(Qt.MouseFocusReason)
    }
    onClosed: destroy()

    function validate() {
        nameInput.validate()
        descriptionTextArea.validate()
        colorPicker.validate()
        return isValid
    }

    title: isEdit ?
            //% "Edit community"
            qsTrId("edit-community") :
            //% "New community"
            qsTrId("new-community")

    ScrollView {
        property ScrollBar vScrollBar: ScrollBar.vertical

        id: scrollView
        anchors.fill: parent
        rightPadding: Style.current.padding
        anchors.rightMargin: -Style.current.padding
        anchors.topMargin: -Style.current.padding
        leftPadding: Style.current.padding
        topPadding: Style.current.padding
        anchors.leftMargin: -Style.current.padding
        contentHeight: content.height
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOn
        clip: true

        function scrollBackUp() {
            vScrollBar.setPosition(0)
        }

        Item {
            id: content
            height: childrenRect.height + 100 // Bottom padding
            width: parent.width

            Input {
                id: nameInput
                //% "Name your community"
                label: qsTrId("name-your-community")
                //% "A catchy name"
                placeholderText: qsTrId("name-your-community-placeholder")
                property bool isValid: false

                onTextEdited: {
                    if (text.includes(" ")) {
                        text = text.replace(" ", "-")
                    }
                    validate()
                }

                function validate() {
                    validationError = ""
                    if (nameInput.text === "") {
                        //% "You need to enter a name"
                        validationError = qsTrId("you-need-to-enter-a-name")
                    } else if (!(/^[a-z0-9\-]+$/.test(nameInput.text))) {
                        validationError = qsTr("Use only lowercase letters (a to z), numbers & dashes (-). Do not use chat keys.")
                    } else if (nameInput.text.length > 100) {
                        //% "Your name needs to be 100 characters or shorter"
                        validationError = qsTrId("your-name-needs-to-be-100-characters-or-shorter")
                    }
                    isValid = validationError === ""
                    return validationError
                }
            }

            StyledTextArea {
                id: descriptionTextArea
                //% "Give it a short description"
                label: qsTrId("give-a-short-description-community")
                //% "What your community is about"
                placeholderText: qsTrId("what-your-community-is-about")
                //% "The description cannot exceed 140 characters"
                validationError: descriptionTextArea.text.length > popup.maxDescChars ? qsTrId("the-description-cannot-exceed-140-characters") :
                                                                                  popup.descriptionValidationError || ""
                anchors.top: nameInput.bottom
                anchors.topMargin: Style.current.bigPadding
                customHeight: 88
                textField.wrapMode: TextEdit.Wrap

                property bool isValid: false
                onTextChanged: validate()

                function resetValidation() {
                    isValid = false
                    validationError = ""
                }

                function validate() {
                    validationError = ""
                    if (text.length > popup.maxDescChars) {
                        validationError = qsTrId("the-description-cannot-exceed-140-characters")
                    }
                    if (text === "") {
                        validationError = qsTr("You need to enter a description")
                    }
                    isValid = validationError === ""
                }
            }

            StyledText {
                id: charLimit
                text: `${descriptionTextArea.text.length}/${popup.maxDescChars}`
                anchors.top: descriptionTextArea.bottom
                anchors.topMargin: !descriptionTextArea.validationError ? 5 : - Style.current.smallPadding
                anchors.right: descriptionTextArea.right
                font.pixelSize: 12
                color: !descriptionTextArea.validationError ? Style.current.textColor : Style.current.danger
            }

            StyledText {
                id: thumbnailText
                //% "Thumbnail image"
                text: qsTrId("thumbnail-image")
                anchors.top: charLimit.bottom
                anchors.topMargin: Style.current.smallPadding
                font.pixelSize: 13
                color: Style.current.textColor
                font.weight: Font.Medium
            }


            Rectangle {
                id: addImageButton
                color: imagePreview.visible ? "transparent" : Style.current.inputBackground
                width: 128
                height: width
                radius: width / 2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: thumbnailText.bottom
                anchors.topMargin: Style.current.padding
                property string selectedImage: ""


                FileDialog {
                    id: imageDialog
                    //% "Please choose an image"
                    title: qsTrId("please-choose-an-image")
                    folder: shortcuts.pictures
                    nameFilters: [
                        //% "Image files (*.jpg *.jpeg *.png)"
                        qsTrId("image-files----jpg---jpeg---png-")
                    ]
                    onAccepted: {
                        addImageButton.selectedImage = imageDialog.fileUrls[0]
                        imageCropperModal.open()
                    }
                }

                Rectangle {
                    id: imagePreviewCropper
                    clip: true
                    width: parent.width
                    height: parent.height
                    radius: parent.width / 2
                    visible: !!addImageButton.selectedImage

                    Image {
                        id: imagePreview
                        visible: !!addImageButton.selectedImage
                        source: addImageButton.selectedImage
                        fillMode: Image.PreserveAspectFit
                        width: parent.width
                        height: parent.height
                    }
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            anchors.centerIn: parent
                            width: imageCropperModal.width
                            height: imageCropperModal.height
                            radius: width / 2
                        }
                    }
                }

                Item {
                    id: addImageCenter
                    visible: !imagePreview.visible
                    width: uploadText.width
                    height: childrenRect.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    SVGImage {
                        id: imageImg
                        source: "../../../img/images_icon.svg"
                        width: 20
                        height: 18
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    StyledText {
                        id: uploadText
                        //% "Upload"
                        text: qsTrId("upload")
                        anchors.top: imageImg.bottom
                        anchors.topMargin: 5
                        font.pixelSize: 15
                        color: Style.current.secondaryText
                    }
                }

                Rectangle {
                    color: Style.current.primary
                    width: 40
                    height: width
                    radius: width / 2
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.halfPadding

                    SVGImage {
                        source: "../../../img/plusSign.svg"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        width: 13
                        height: 13
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: imageDialog.open()
                }

                ImageCropperModal {
                    id: imageCropperModal
                    selectedImage: addImageButton.selectedImage
                    ratio: "1:1"
                }

            }
            StyledText {
                id: imageValidation
                visible: text && text !== ""
                anchors.top: addImageButton.bottom
                anchors.topMargin: Style.current.smallPadding
                anchors.left: parent.left
                anchors.right: parent.right
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                color: Style.current.danger
            }

            Input {
                property string defaultColor: "#4360DF"
                property bool isValid: true

                id: colorPicker
                label: qsTr("Community color")
                placeholderText: qsTr("Pick a color")
                anchors.top: imageValidation.bottom
                anchors.topMargin: Style.current.smallPadding
                textField.text: defaultColor
                textField.onReleased: colorDialog.open()

                onTextChanged: validate()

                function resetValidation() {
                    isValid = true
                    validationError = ""
                }

                function validate() {
                    validationError = ""
                    if (text === "") {
                        validationError = qsTr("Please enter a color")
                    } else if (!Utils.isHexColor(colorPicker.text)) {
                        validationError = qsTr("Must be an hexadecimal color (eg: #4360DF)")
                    }
                    isValid = validationError === ""
                }

                StatusIconButton {
                    icon.name: "caret"
                    iconRotation: -90
                    iconColor: Style.current.textColor
                    icon.width: 13
                    icon.height: 7
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.smallPadding
                    anchors.top: parent.top
                    anchors.topMargin: colorPicker.textField.height / 2 - height / 2 + Style.current.bigPadding
                    onClicked: colorDialog.open()
                }

                ColorDialog {
                    id: colorDialog
                    title: qsTr("Please choose a color")
                    color: colorPicker.defaultColor
                    onAccepted: {
                        colorPicker.text = colorDialog.color
                    }
                }
            }

            Separator {
                id: separator1
                anchors.top: colorPicker.bottom
                anchors.topMargin: isEdit ? 0 : Style.current.bigPadding
                anchors.left: parent.left
                anchors.leftMargin: -Style.current.padding
                anchors.right: parent.right
                anchors.rightMargin: -Style.current.padding
                visible: !isEdit
            }

            StatusSettingsLineButton {
                id: membershipRequirementSetting
                anchors.top: separator1.bottom
                anchors.topMargin: Style.current.halfPadding
                text: qsTr("Membership requirement")
                currentValue: {
                    switch (membershipRequirementSettingPopup.checkedMembership) {
                    case Constants.communityChatInvitationOnlyAccess: return qsTr("Require invite from another member")
                    case Constants.communityChatOnRequestAccess: return qsTr("Require approval")
                    default: return qsTr("No requirement")
                    }
                }
                onClicked: {
                    membershipRequirementSettingPopup.open()
                }
            }

            StyledText {
                visible: !isEdit
                height: visible ? implicitHeight : 0
                id: privateExplanation
                anchors.top: membershipRequirementSetting.bottom
                wrapMode: Text.WordWrap
                anchors.topMargin: isEdit ? 0 : Style.current.halfPadding
                font.pixelSize: 13
                color: Style.current.secondaryText
                width: parent.width * 0.78
                text: qsTr("You can require new members to meet certain criteria before they can join. This can be changed at any time")
            }

            // Feature commented temporarily
            /*
            StatusSettingsLineButton {
                id: ensOnlySwitch
                anchors.top: privateExplanation.bottom
                anchors.topMargin: Style.current.padding
                isEnabled: profileModel.profile.ensVerified
                text: qsTr("Require ENS username")
                isSwitch: true
                onClicked: switchChecked = checked

                StatusToolTip {
                    visible: !ensOnlySwitch.isEnabled && ensMouseArea.isHovered
                    text: qsTr("You can only enable this setting if you have an ENS name")
                }

                MouseArea {
                    property bool isHovered: false

                    id: ensMouseArea
                    enabled: !ensOnlySwitch.isEnabled
                    visible: enabled
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: isHovered = true
                    onExited: isHovered = false
                }
            }

            StyledText {
                visible: !isEdit
                height: visible ? implicitHeight : 0
                id: ensExplanation
                anchors.top: ensOnlySwitch.bottom
                wrapMode: Text.WordWrap
                anchors.topMargin: isEdit ? 0 : Style.current.halfPadding
                width: parent.width
                text: qsTr("Your community requires an ENS username to be able to join")
            }
            */
        }

        MembershipRequirementPopup {
            id: membershipRequirementSettingPopup
        }
    }

    footer: StatusButton {
        text: isEdit ?
              //% "Edit"
              qsTrId("edit") :
              //% "Create"
              qsTrId("create")
        anchors.right: parent.right
        onClicked: {
            if (!validate()) {
                scrollView.scrollBackUp()
                return
            }

            let error = false;
            if(isEdit) {
                console.log("TODO: implement this (not available in status-go yet)");
            } else {
                error = chatsModel.communities.createCommunity(Utils.filterXSS(nameInput.text),
                                                   Utils.filterXSS(descriptionTextArea.text),
                                                   membershipRequirementSettingPopup.checkedMembership,
                                                   false, // ensOnlySwitch.switchChecked, // TODO:
                                                   colorPicker.text,
                                                   addImageButton.selectedImage,
                                                   imageCropperModal.aX,
                                                   imageCropperModal.aY,
                                                   imageCropperModal.bX,
                                                   imageCropperModal.bY)
            }

            if (error) {
                creatingError.text = error
                return creatingError.open()
            }

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

