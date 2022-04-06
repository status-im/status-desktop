import QtQuick 2.13
import QtQuick.Dialogs 1.3

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import shared 1.0
import shared.panels 1.0
import shared.popups 1.0

import "../stores"

StatusModal {
    id: popup

    height: 510
    header.title: qsTr("Upload profile picture")

    readonly property alias aX: cropImageModal.aX
    readonly property alias aY: cropImageModal.aY
    readonly property alias bX: cropImageModal.bX
    readonly property alias bY: cropImageModal.bY

    property string selectedImage
    property string croppedImg: ""
    property string uploadError

    signal profileImageReady(string croppedImg)

    onClosed: {
        popup.selectedImage = ""
        popup.croppedImg = ""
    }

    contentItem: Item {
        anchors.fill: parent
        StatusRoundedImage {
            id: profilePic
            width: 160
            height: 160
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            image.source: popup.croppedImg
            showLoadingIndicator: true
            border.width: 1
            border.color: Style.current.border

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: imageDialog.open()
            }
        }

        StyledText {
            visible: !!uploadError
            text: uploadError
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: profilePic.bottom
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 13
            wrapMode: Text.WordWrap
            anchors.topMargin: 13
            font.weight: Font.Thin
            color: Style.current.danger
        }

        ImageCropperModal {
            id: cropImageModal
            ratio: "1:1"
            onCropFinished: {
                popup.croppedImg = OnboardingStore.uploadImage(selectedImage, aX, aY, bX, bY);
                popup.selectedImage = ""
            }
        }
    }

    rightButtons: [
        StatusButton {
            id: uploadBtn
            text: popup.croppedImg? qsTr("Done") : qsTr("Upload")
            onClicked: {
                if (popup.croppedImg) {
                    popup.profileImageReady(popup.croppedImg)
                    close();
                } else {
                    imageDialog.open();
                }
            }
            FileDialog {
                id: imageDialog
                title: qsTrId("please-choose-an-image")
                folder: shortcuts.pictures
                nameFilters: [
                    qsTrId("image-files----jpg---jpeg---png-")
                ]
                onAccepted: {
                    if(imageDialog.fileUrls.length > 0) {
                        cropImageModal.selectedImage = imageDialog.fileUrls[0];
                        cropImageModal.open()
                    }
                }
            }
        }
    ]
}

