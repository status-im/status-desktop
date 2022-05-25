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

    property bool isEdit: true
    property bool communityHistoryArchiveSupportEnabled: false

    property color color: Theme.palette.primaryColor1

    property alias name: nameInput.text
    property alias description: descriptionInput.text
    property alias image: addImageButton.selectedImage
    property alias historyArchive: historyArchiveSupportCheckbox
    property alias requestToJoin: requestToJoinCheckbox
    property alias pinMessagesAllMembers: pinMessagesAllMembersCheckbox

    readonly property alias imageAx: imageCropperModal.aX
    readonly property alias imageAy: imageCropperModal.aY
    readonly property alias imageBx: imageCropperModal.bX
    readonly property alias imageBy: imageCropperModal.bY

    readonly property int maxCommunityNameLength: 30
    readonly property int maxCommunityDescLength: 140
    readonly property string colorString: color.toString().toUpperCase()
    readonly property var communityColorValidator: Utils.Validate.NoEmpty | Utils.Validate.TextHexColor
    readonly property bool isFormValid: nameInput.valid && descriptionInput.valid && Utils.validateAndReturnError(
                                        colorString, communityColorValidator) === ""

    function scrollBackUp() {
        contentY = 0;
    }

    function forceNameFocus() {
        nameInput.forceActiveFocus();
    }

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
            charLimit: maxCommunityNameLength
            input.placeholderText: qsTr("A catchy name")
            validators: [
                StatusMinLengthValidator {
                    minLength: 1
                    errorMessage: Utils.getErrorMessage(nameInput.errors,
                                                        qsTr("community name"))
                },
                StatusRegularExpressionValidator {
                    regularExpression: /^[^<>]+$/
                    errorMessage: qsTr("This is not a valid community name")
                }
            ]
            validationMode: StatusInput.ValidationMode.Always

            Component.onCompleted: nameInput.input.forceActiveFocus(Qt.MouseFocusReason)
        }

        StatusInput {
            id: descriptionInput

            Layout.fillWidth: true

            leftPadding: 0
            rightPadding: 0
            label: qsTr("Description")
            charLimit: maxCommunityDescLength

            input.placeholderText: qsTr("What your community is about")
            input.multiline: true
            input.implicitHeight: 88

            validators: [
                StatusMinLengthValidator {
                    minLength: 1
                    errorMessage: Utils.getErrorMessage(
                                      descriptionInput.errors,
                                      qsTr("community description"))
                }
            ]
            validationMode: StatusInput.ValidationMode.Always
        }

        ColumnLayout {
            Layout.fillWidth: true
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
                        //% "Please choose an image"
                        title: qsTrId("please-choose-an-image")
                        folder: shortcuts.pictures
                        nameFilters: [//% "Image files (*.jpg *.jpeg *.png)"
                            qsTrId("image-files----jpg---jpeg---png-")]
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
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            StatusBaseText {
                text: qsTrId("Community colour")
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
            visible: communityHistoryArchiveSupportEnabled
            title: qsTr("Community history service")
            sensor.onClicked: {
                if (communityHistoryArchiveSupportEnabled) {
                    historyArchiveSupportCheckbox.checked = !historyArchiveSupportCheckbox.checked
                }
            }
            components: [
                StatusCheckBox {
                    id: historyArchiveSupportCheckbox
                    enabled: communityHistoryArchiveSupportEnabled
                    checked: isEdit ? community.historyArchiveSupportEnabled : false
                }
            ]
            Layout.fillWidth: true
        }

        StatusListItem {
            title: qsTr("Request to join required")
            visible: !isEdit
            sensor.onClicked: {
                requestToJoinCheckbox.checked = !requestToJoinCheckbox.checked
            }
            components: [
                StatusCheckBox {
                    id: requestToJoinCheckbox
                    checked: true
                }
            ]
            Layout.fillWidth: true
        }

        StatusListItem {
            title: qsTr("Any member can pin a message")
            visible: !isEdit
            sensor.onClicked: {
                pinMessagesAllMembersCheckbox.checked = !pinMessagesAllMembersCheckbox.checked
            }
            components: [
                StatusCheckBox {
                    id: pinMessagesAllMembersCheckbox
                    checked: isEdit ? community.pinMessageAllMembersEnabled : false
                }
            ]
            Layout.fillWidth: true
        }

        Item {
            Layout.fillHeight: true
        }
    }
}

