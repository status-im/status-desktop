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
    title: qsTr("Profile picture")

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
            width: 160
            height: 160
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
            font.pixelSize: 13
            wrapMode: Text.WordWrap
            anchors.topMargin: 13
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
            text: qsTr("Remove")
            anchors.right: uploadBtn.left
            anchors.rightMargin: Style.current.padding
            anchors.bottom: parent.bottom
            onClicked: {
                popup.uploadError = popup.profileStore.removeImage()
            }
        }

        StatusButton {
            id: uploadBtn
            text: qsTr("Upload")
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            onClicked: {
                imageDialog.open()
            }

            FileDialog {
                id: imageDialog
                title: qsTr("Please choose an image")
                folder: shortcuts.pictures
                nameFilters: [
                    qsTr("Image files (*.jpg *.jpeg *.png)")
                ]
                onAccepted: {
                    selectedImage = imageDialog.fileUrls[0]
                }
            }
        }
    }
}

