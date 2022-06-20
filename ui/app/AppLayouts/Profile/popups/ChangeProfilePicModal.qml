import QtQuick 2.13
import QtQuick.Dialogs 1.3

import utils 1.0

import StatusQ.Controls 0.1

import shared 1.0
import shared.panels 1.0
import shared.popups 1.0

// TODO: replace with StatusModal
ModalPopup {
    id: popup
    //% "Profile picture"
    title: qsTrId("profile-picture")

    property var profileStore

    property string selectedImage // selectedImage is for us to be able to analyze it before setting it as current
    property string uploadError
    property url largeImage: popup.profileStore.profileLargeImage
    property bool hasIdentityImage: !!popup.profileStore.profileLargeImage

    onClosed: {
        destroy()
    }

    onSelectedImageChanged: {
        if (!selectedImage) {
            return
        }

        cropImageModal.open()
    }

    Item {
        anchors.fill: parent

        RoundedImage {
            id: profilePic
            source: popup.largeImage
            width: Style.dp(160)
            height: Style.dp(160)
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            border.width: 1
            border.color: Style.current.border
            onClicked: imageDialog.open()
        }

        StyledText {
            visible: !!uploadError
            text: uploadError
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: profilePic.bottom
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Style.current.additionalTextSize
            wrapMode: Text.WordWrap
            anchors.topMargin: Style.dp(13)
            font.weight: Font.Thin
            color: Style.current.danger
        }

        ImageCropperModal {
            id: cropImageModal

            selectedImage: popup.selectedImage
            ratio: "1:1"
            onCropFinished: {
                popup.uploadError = popup.profileStore.uploadImage(selectedImage, aX, aY, bX, bY)
            }
        }
    }

    footer: Item {
        width: parent.width
        height: uploadBtn.height

        StatusFlatButton {
            visible: popup.hasIdentityImage
            type: StatusBaseButton.Type.Danger
            //% "Remove"
            text: qsTrId("remove")
            anchors.right: uploadBtn.left
            anchors.rightMargin: Style.current.padding
            anchors.bottom: parent.bottom
            onClicked: {
                popup.uploadError = popup.profileStore.removeImage()
            }
        }

        StatusButton {
            id: uploadBtn
            //% "Upload"
            text: qsTrId("upload")
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            onClicked: {
                imageDialog.open()
            }

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
                    selectedImage = imageDialog.fileUrls[0]
                }
            }
        }
    }
}

