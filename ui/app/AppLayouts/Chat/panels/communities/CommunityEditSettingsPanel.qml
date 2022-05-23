import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.13

import utils 1.0
import shared.panels 1.0
import shared.popups 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Layout 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

Flickable {
    id: root

    property color color: Theme.palette.primaryColor1

    property alias name: nameInput.text
    property alias description: descriptionTextInput.text
    property alias logoImagePath: addImageButton.selectedImage
    property string logoImageData: ""
    readonly property alias imageAx: imageCropperModal.aX
    readonly property alias imageAy: imageCropperModal.aY
    readonly property alias imageBx: imageCropperModal.bX
    readonly property alias imageBy: imageCropperModal.bY
    property string bannerImageData: ""
    property alias bannerPath: bannerEditor.source
    property alias bannerCropRect: bannerEditor.cropRect
    property bool isCommunityHistoryArchiveSupportEnabled: false
    property alias historyArchiveSupportToggle: historyArchiveSupportToggle.checked

    contentWidth: layout.width
    contentHeight: layout.height
    clip: true
    interactive: contentHeight > height
    flickableDirection: Flickable.VerticalFlick

    ColumnLayout {
        id: layout

        width: root.width
        spacing: 12

        StatusInput {
            id: nameInput

            Layout.fillWidth: true

            leftPadding: 0
            rightPadding: 0
            label: qsTr("Community name")
            charLimit: 30
            input.placeholderText: qsTr("A catchy name")
            validators: [
                StatusMinLengthValidator {
                    minLength: 1
                    errorMessage: Utils.getErrorMessage(nameInput.errors,
                                                        qsTr("community name"))
                }
            ]
            validationMode: StatusInput.ValidationMode.Always

            Component.onCompleted: nameInput.input.forceActiveFocus(Qt.MouseFocusReason)
        }

        StatusInput {
            id: descriptionTextInput

            Layout.fillWidth: true

            leftPadding: 0
            rightPadding: 0
            label: qsTr("Description")
            charLimit: 140

            input.placeholderText: qsTr("What your community is about")
            input.multiline: true
            input.implicitHeight: 88

            validators: [
                StatusMinLengthValidator {
                    minLength: 1
                    errorMessage: Utils.getErrorMessage(
                                      descriptionTextInput.errors,
                                      qsTr("community description"))
                }
            ]
            validationMode: StatusInput.ValidationMode.Always
        }

        ColumnLayout {
            spacing: 8

            StatusBaseText {
                text: qsTr("Community logo")
                font.pixelSize: 15
                color: Theme.palette.directColor1
            }

            Item {
                Layout.fillWidth: true

                implicitHeight: addImageButton.height + 32

                Rectangle {
                    id: addImageButton

                    property string selectedImage: ""

                    anchors.centerIn: parent
                    color: imagePreview.visible ? "transparent" : Style.current.inputBackground
                    width: 128
                    height: width
                    radius: width / 2

                    FileDialog {
                        id: imageDialog
                        title: qsTr("Please choose an image")
                        folder: shortcuts.pictures
                        nameFilters: [qsTr("Image files (*.jpg *.jpeg *.png)")]
                        onAccepted: {
                            if(imageDialog.fileUrls.length > 0) {
                                addImageButton.selectedImage = imageDialog.fileUrls[0]
                                imageCropperModal.open()
                            }
                        }
                    }

                    Rectangle {
                        id: imagePreviewCropper
                        clip: true
                        width: parent.width
                        height: parent.height
                        radius: parent.width / 2
                        visible: !!addImageButton.selectedImage || !!root.logoImageData

                        Image {
                            id: imagePreview
                            visible: !!addImageButton.selectedImage || !!root.logoImageData
                            source: addImageButton.selectedImage
                                        ? addImageButton.selectedImage
                                        : root.logoImageData
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

                    NoImageUploadedPanel {
                        anchors.centerIn: parent

                        visible: !imagePreview.visible
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

            // Banner
            //
            StatusBaseText {
                text: qsTr("Community banner")

                font.pixelSize: 15
                color: Theme.palette.directColor1
            }

            EditCroppedImagePanel {
                id: bannerEditor

                Layout.preferredWidth: 475
                Layout.preferredHeight: Layout.preferredWidth / aspectRatio
                Layout.alignment: Qt.AlignHCenter

                imageFileDialogTitle: qsTr("Choose an image for banner")
                title: qsTr("Community banner")
                acceptButtonText: qsTr("Make this my Community banner")

                roundedImage: false
                aspectRatio: 375/184

                dataImage: root.bannerImageData

                NoImageUploadedPanel {
                    anchors.centerIn: parent

                    visible: !bannerEditor.userSelectedImage && !root.bannerImageData
                    showARHint: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            StatusBaseText {
                text: qsTr("Community colour")
                font.pixelSize: 15
                color: Theme.palette.directColor1
            }

            StatusPickerButton {
                Layout.fillWidth: true

                property string validationError: ""

                bgColor: root.color
                contentColor: Theme.palette.indirectColor1
                text: root.color.toString()

                onClicked: {
                    colorDialog.color = root.color;
                    colorDialog.open();
                }
                onTextChanged: {
                    validationError = Utils.validateAndReturnError(text,
                                          Utils.Validate.NoEmpty |
                                          Utils.Validate.TextHexColor);
                }

                StatusColorDialog {
                    id: colorDialog
                    anchors.centerIn: parent
                    header.title: qsTr("Community Colour")
                    previewText: qsTr("White text should be legable on top of this colour")
                    acceptText: qsTr("Select Community Colour")
                    onAccepted: {
                        root.color = color;
                    }
                }
            }
        }

        StatusListItem {
            title: qsTr("Community history service")

            Layout.fillWidth: true
            visible: root.isCommunityHistoryArchiveSupportEnabled

            components: [
                StatusSwitch {
                    id: historyArchiveSupportToggle
                    enabled: root.isCommunityHistoryArchiveSupportEnabled
                }
            ]
        }

        Item {
            Layout.fillHeight: true
        }
    }
}

