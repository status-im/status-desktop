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
    property string logoImageData: ""
    property alias logoImagePath: logoEditor.source
    property alias logoCropRect: logoEditor.cropRect
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

            // Logo
            //
            StatusBaseText {
                text: qsTr("Community logo")
                font.pixelSize: 15
                color: Theme.palette.directColor1
            }

            EditCroppedImagePanel {
                id: logoEditor

                Layout.preferredWidth: 128
                Layout.preferredHeight: Layout.preferredWidth / aspectRatio
                Layout.alignment: Qt.AlignHCenter

                imageFileDialogTitle: qsTr("Choose an image as logo")
                title: qsTr("Community logo")
                acceptButtonText: qsTr("Make this my Community logo")

                dataImage: root.logoImageData

                NoImageUploadedPanel {
                    anchors.centerIn: parent

                    visible: !logoEditor.userSelectedImage && !root.logoImageData
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

