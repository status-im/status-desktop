import QtQuick 2.12
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    property QtObject community: chatsModel.communities.activeCommunity

    property bool isEdit: false

    readonly property int maxCommunityNameLength: 30
    readonly property var communityNameValidator: Utils.Validate.NoEmpty
                                                  | Utils.Validate.TextLength

    readonly property int maxCommunityDescLength: 140
    readonly property var communityDescValidator: Utils.Validate.NoEmpty
                                                  | Utils.Validate.TextLength

    readonly property var communityColorValidator: Utils.Validate.NoEmpty
                                                   | Utils.Validate.TextHexColor

    id: popup
    height: 600

    onOpened: {
        if (isEdit) {
            nameInput.text = community.name;
            descriptionTextArea.text = community.description;
            colorPicker.defaultColor = community.communityColor;
            if (community.largeImage) {
                addImageButton.selectedImage = community.largeImage
            }
            membershipRequirementSettingPopup.checkedMembership = community.access
        }
        nameInput.forceActiveFocus(Qt.MouseFocusReason)
    }
    onClosed: destroy()

    function isFormValid() {
        return Utils.validateAndReturnError(nameInput.text,
                                            communityNameValidator,
                                            //% "community name"
                                            qsTrId("community-name"),
                                            maxCommunityNameLength) === ""
               && Utils.validateAndReturnError(descriptionTextArea.text,
                                               communityDescValidator,
                                               //% "community decription"
                                               qsTrId("community-decription"),
                                               maxCommunityDescLength) === ""
               && Utils.validateAndReturnError(colorPicker.text,
                                               communityColorValidator) === ""
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
                maxLength: maxCommunityNameLength

                onTextEdited: {
                    validationError = Utils.validateAndReturnError(text,
                                                                   communityNameValidator,
                                                                   //% "community name"
                                                                   qsTrId("community-name"),
                                                                   maxCommunityNameLength)
                }
            }

            StyledTextArea {
                id: descriptionTextArea
                //% "Give it a short description"
                label: qsTrId("give-a-short-description-community")
                //% "What your community is about"
                placeholderText: qsTrId("what-your-community-is-about")

                anchors.top: nameInput.bottom
                anchors.topMargin: Style.current.bigPadding
                customHeight: 88
                textField.wrapMode: TextEdit.Wrap

                onTextChanged: {
                    if(text.length > maxCommunityDescLength)
                    {
                        textField.remove(maxCommunityDescLength, text.length)
                        return
                    }

                    validationError = Utils.validateAndReturnError(text,
                                                                   communityDescValidator,
                                                                   //% "community decription"
                                                                   qsTrId("community-decription"),
                                                                   maxCommunityDescLength)
                }
            }

            StyledText {
                id: charLimit
                text: `${descriptionTextArea.text.length}/${maxCommunityDescLength}`
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
                property string defaultColor: Style.current.blue

                id: colorPicker
                //% "Community color"
                label: qsTrId("community-color")
                //% "Pick a color"
                placeholderText: qsTrId("pick-a-color")
                anchors.top: imageValidation.bottom
                anchors.topMargin: Style.current.smallPadding
                textField.text: defaultColor
                textField.onReleased: colorDialog.open()

                onTextChanged: {
                    validationError = Utils.validateAndReturnError(text, communityColorValidator)
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
                    //% "Please choose a color"
                    title: qsTrId("please-choose-a-color")
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
                // TODO: remove 'isEnabled: false' when we no longer need to force
                // "request access" membership
                isEnabled: false
                anchors.top: separator1.bottom
                anchors.topMargin: Style.current.halfPadding
                //% "Membership requirement"
                text: qsTrId("membership-title")
                currentValue: {
                    switch (membershipRequirementSettingPopup.checkedMembership) {
                        //% "Require invite from another member"
                        case Constants.communityChatInvitationOnlyAccess: return qsTrId("membership-invite")
                        //% "Require approval"
                        case Constants.communityChatOnRequestAccess: return qsTrId("membership-approval")
                        //% "No requirement"
                        default: return qsTrId("membership-free")
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
                //% "You can require new members to meet certain criteria before they can join. This can be changed at any time"
                text: qsTrId("membership-none-placeholder")
            }

            // Feature commented temporarily
            /*
            StatusSettingsLineButton {
                id: ensOnlySwitch
                anchors.top: privateExplanation.bottom
                anchors.topMargin: Style.current.padding
                isEnabled: profileModel.profile.ensVerified
                //% "Require ENS username"
                text: qsTrId("membership-ens")
                isSwitch: true
                onClicked: switchChecked = checked

                StatusToolTip {
                    visible: !ensOnlySwitch.isEnabled && ensMouseArea.isHovered
                    //% "You can only enable this setting if you have an ENS name"
                    text: qsTrId("you-can-only-enable-this-setting-if-you-have-an-ens-name")
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
                //% "Your community requires an ENS username to be able to join"
                text: qsTrId("membership-ens-description")
            }
            */
        }

        MembershipRequirementPopup {
            id: membershipRequirementSettingPopup
            // TODO: remove the 'checkedMemership' setting when we no longer need
            // to force "require approval" membership
            checkedMembership: Constants.communityChatOnRequestAccess
        }
    }

    footer: Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: btnCreateEdit.height

        StatusRoundButton {
            id: btnBack
            anchors.left: parent.left
            visible: isEdit
            icon.name: "arrow-right"
            icon.width: 20
            icon.height: 16
            rotation: 180
            onClicked: popup.destroy()
        }
        StatusButton {
            id: btnCreateEdit
            enabled: isFormValid()
            text: isEdit ?
                //% "Save"
                qsTrId("Save") :
                //% "Create"
                qsTrId("create")
            anchors.right: parent.right
            onClicked: {
                if (!isFormValid()) {
                    scrollView.scrollBackUp()
                    return
                }

                let error = false;
                if(isEdit) {
                    error = chatsModel.communities.editCommunity(community.id,
                                                    Utils.filterXSS(nameInput.text),
                                                    Utils.filterXSS(descriptionTextArea.text),
                                                    membershipRequirementSettingPopup.checkedMembership,
                                                    false,
                                                    colorPicker.text,
                                                    // to retain the existing image, pass "" for the image path
                                                    addImageButton.selectedImage ===  community.largeImage ? "" : addImageButton.selectedImage,
                                                    imageCropperModal.aX,
                                                    imageCropperModal.aY,
                                                    imageCropperModal.bX,
                                                    imageCropperModal.bY)
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
                    creatingError.text = error.error
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
}

