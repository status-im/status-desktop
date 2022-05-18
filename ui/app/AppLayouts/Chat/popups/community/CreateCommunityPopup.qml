import QtQuick 2.12
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.3

import utils 1.0
import shared.panels 1.0
import shared.popups 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Popups 0.1

StatusModal {
    id: popup
    height: 509

    property var store
    property var communitySectionModule
    property bool isEdit: false
    property QtObject community: null
    property var onSave: () => {}
    readonly property int maxCommunityNameLength: 30
    readonly property int maxCommunityDescLength: 140
    readonly property var communityColorValidator: Utils.Validate.NoEmpty
                                                   | Utils.Validate.TextHexColor

    onOpened: {
        if (isEdit) {
            contentItem.communityName.input.text = community.name;
            contentItem.communityDescription.input.text = community.description;
            contentItem.communityColor.color = community.color;
            contentItem.communityColor.colorSelected = true
            if (community.largeImage) {
                contentItem.communityImage.selectedImage = community.largeImage
            }
            requestToJoinCheckbox.checked = community.access === Constants.communityChatOnRequestAccess
        }
        contentItem.communityName.input.edit.forceActiveFocus()
    }
    onClosed: destroy()

    function isFormValid() {
        return contentItem.communityName.valid && contentItem.communityDescription.valid &&
            Utils.validateAndReturnError(contentItem.communityColor.color.toString().toUpperCase(),
                                        communityColorValidator) === ""
    }

    header.title: isEdit ?
            qsTr("Edit Community") :
            qsTr("Create New Community")

    contentItem: ScrollView {

        id: scrollView

        property ScrollBar vScrollBar: ScrollBar.vertical

        property alias communityName: nameInput
        property alias communityDescription: descriptionTextArea
        property alias communityColor: colorDialog
        property alias communityImage: addImageButton
        property alias imageCropperModal: imageCropperModal
        property alias historyArchiveSupportToggle: historyArchiveSupportToggle
        property alias pinMessagesAllMembersCheckbox: pinMessagesAllMembersCheckbox

        contentHeight: content.height
        bottomPadding: 8
        width: popup.width

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        clip: true

        function scrollBackUp() {
            vScrollBar.setPosition(0)
        }

        Column {
            id: content
            width: popup.width
            spacing: 8

            Item {
                height: 8
                width: parent.width
            }

            StatusInput {
                id: nameInput
                label: qsTr("Name your community")
                charLimit: maxCommunityNameLength
                input.placeholderText: qsTr("A catchy name")
                validators: [
                    StatusMinLengthValidator {
                        minLength: 1
                        errorMessage: Utils.getErrorMessage(nameInput.errors, "community name")
                    },
                    StatusRegularExpressionValidator {
                        regularExpression: /^[^<>]+$/
                        errorMessage: qsTr("This is not a valid community name")
                    }
                ]
                validationMode: StatusInput.ValidationMode.Always
            }

            StatusInput {
                id: descriptionTextArea
                label: qsTr("Give it a short description")
                charLimit: maxCommunityDescLength

                input.placeholderText: qsTr("What your community is about")
                input.multiline: true
                input.implicitHeight: 88
                input.verticalAlignment: TextEdit.AlignTop

                validators: [StatusMinLengthValidator {
                    minLength: 1
                    errorMessage: Utils.getErrorMessage(descriptionTextArea.errors, "community description")
                }]
                validationMode: StatusInput.ValidationMode.Always
            }

            StatusBaseText {
                id: thumbnailText
                //% "Thumbnail image"
                text: qsTrId("thumbnail-image")
                font.pixelSize: 15
                color: Theme.palette.directColor1
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.topMargin: 8
            }

            Item {
                width: parent.width
                height: addImageButton.height + 32

                Rectangle {
                    id: addImageButton
                    color: imagePreview.visible ? "transparent" : Style.current.inputBackground
                    width: 128
                    height: width
                    radius: width / 2
                    anchors.centerIn: parent
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
                        anchors.centerIn: parent

                        SVGImage {
                            id: imageImg
                            source: Style.svg("images_icon")
                            width: 20
                            height: 18
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        StatusBaseText {
                            id: uploadText
                            //% "Upload"
                            text: qsTrId("upload")
                            anchors.top: imageImg.bottom
                            anchors.topMargin: 5
                            font.pixelSize: 15
                            color: Theme.palette.baseColor1
                        }
                    }

                    StatusRoundButton {
                        type: StatusRoundButton.Type.Secondary
                        icon.name: "add"
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.rightMargin: Style.current.halfPadding
                        highlighted: sensor.containsMouse
                    }

                    MouseArea {
                        id: sensor
                        hoverEnabled: true
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
            }

            StatusBaseText {
                text: qsTr("Community colour")
                font.pixelSize: 15
                color: Theme.palette.directColor1
                anchors.left: parent.left
                anchors.leftMargin: 16
            }

            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                height: colorSelectorButton.height + 16
                width: parent.width - 32

                StatusPickerButton {
                    id: colorSelectorButton
                    anchors.top: parent.top
                    anchors.topMargin: 10

                    property string validationError: ""

                    bgColor: colorDialog.colorSelected ?
                        colorDialog.color : Theme.palette.baseColor2
                    contentColor: colorDialog.colorSelected ? Theme.palette.indirectColor1 : Theme.palette.baseColor1
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
                    property bool colorSelected: false
                    color: Theme.palette.primaryColor1
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

            StatusModalDivider {
                topPadding: 8
                bottomPadding: 8
                visible: !isEdit
            }

            StatusListItem {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: popup.store.isCommunityHistoryArchiveSupportEnabled
                title: qsTr("Community history service")
                sensor.onClicked: {
                    if (popup.store.isCommunityHistoryArchiveSupportEnabled) {
                        historyArchiveSupportToggle.checked = !historyArchiveSupportToggle.checked
                    }
                }
                components: [
                    StatusCheckBox {
                        id: historyArchiveSupportToggle
                        enabled: popup.store.isCommunityHistoryArchiveSupportEnabled
                        checked: isEdit ? community.historyArchiveSupportEnabled : false
                    }
                ]
            }

            StatusListItem {
                anchors.horizontalCenter: parent.horizontalCenter
                title: qsTr("Request to join required")
                sensor.onClicked: {
                    requestToJoinCheckbox.checked = !requestToJoinCheckbox.checked
                }
                components: [
                    StatusCheckBox {
                        id: requestToJoinCheckbox
                        checked: true
                    }
                ]
            }

            StatusListItem {
                anchors.horizontalCenter: parent.horizontalCenter
                title: qsTr("Any member can pin a message")
                sensor.onClicked: {
                    pinMessagesAllMembersCheckbox.checked = !pinMessagesAllMembersCheckbox.checked
                }
                components: [
                    StatusCheckBox {
                        id: pinMessagesAllMembersCheckbox
                        checked: isEdit ? community.pinMessageAllMembersEnabled : false
                    }
               ]
            }
        }

    }

    leftButtons: [
        StatusRoundButton {
            id: btnBack
            visible: isEdit
            icon.name: "arrow-right"
            icon.width: 20
            icon.height: 16
            rotation: 180
            onClicked: popup.destroy()
        }
    ]

    rightButtons: [
        StatusButton {
            id: btnCreateEdit
            enabled: isFormValid()
            text: isEdit ?
                //% "Save"
                qsTrId("Save") :
                //% "Create"
                qsTrId("create")
            onClicked: {
                if (!isFormValid()) {
                    popup.contentItem.scrollBackUp()
                    return
                }

                let error = false;
                if(isEdit) {
                    error = communitySectionModule.editCommunity(
                        Utils.filterXSS(popup.contentItem.communityName.input.text),
                        Utils.filterXSS(popup.contentItem.communityDescription.input.text),
                        requestToJoinCheckbox.checked ? Constants.communityChatOnRequestAccess : Constants.communityChatPublicAccess,
                        popup.contentItem.communityColor.color.toString().toUpperCase(),
                        // to retain the existing image, pass "" for the image path
                        popup.contentItem.communityImage.selectedImage ===  community.largeImage ? "" :
                            popup.contentItem.communityImage.selectedImage,
                        popup.contentItem.imageCropperModal.aX,
                        popup.contentItem.imageCropperModal.aY,
                        popup.contentItem.imageCropperModal.bX,
                        popup.contentItem.imageCropperModal.bY,
                        popup.contentItem.historyArchiveSupportToggle.checked,
                        popup.contentItem.pinMessagesAllMembersCheckbox.checked
                  )
                } else {
                    error = popup.store.createCommunity(
                        Utils.filterXSS(popup.contentItem.communityName.input.text),
                        Utils.filterXSS(popup.contentItem.communityDescription.input.text),
                        requestToJoinCheckbox.checked ? Constants.communityChatOnRequestAccess : Constants.communityChatPublicAccess,
                        popup.contentItem.communityColor.color.toString().toUpperCase(),
                        popup.contentItem.communityImage.selectedImage,
                        popup.contentItem.imageCropperModal.aX,
                        popup.contentItem.imageCropperModal.aY,
                        popup.contentItem.imageCropperModal.bX,
                        popup.contentItem.imageCropperModal.bY,
                        popup.contentItem.historyArchiveSupportToggle.checked,
                        popup.contentItem.pinMessagesAllMembersCheckbox.checked
                    )
                }

                if (error) {
                    creatingError.text = error.error
                    return creatingError.open()
                }
                popup.onSave()
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

