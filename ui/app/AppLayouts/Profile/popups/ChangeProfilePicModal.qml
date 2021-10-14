import QtQuick 2.13
import QtQuick.Dialogs 1.3

import utils 1.0
import "../../../../shared"
import "../../../../shared/popups"
import "../../../../shared/status"

// TODO: replace with StatusModal
ModalPopup {
    property string selectedImage // selectedImage is for us to be able to analyze it before setting it as current
    property string uploadError

    id: popup

    property url largeImage: ""
    property bool hasIdentityImage: false

    signal cropFinished(var aX, var aY, var bX, var bY)
    signal removeImageButtonClicked()

    //% "Profile picture"
    title: qsTrId("profile-picture")

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
            onCropFinished: popup.cropFinished(selectedImage, aX, aY, bX, bY)
        }
    }

    footer: Item {
        width: parent.width
        height: uploadBtn.height

        StatusButton {
            visible: popup.hasIdentityImage
            type: "secondary"
            flat: true
            color: Style.current.danger
            //% "Remove"
            text: qsTrId("remove")
            anchors.right: uploadBtn.left
            anchors.rightMargin: Style.current.padding
            anchors.bottom: parent.bottom
            onClicked: popup.removeImageButtonClicked()
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

