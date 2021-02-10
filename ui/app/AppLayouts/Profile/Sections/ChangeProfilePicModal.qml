import QtQuick 2.13
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    property string selectedImage // selectedImage is for us to be able to analyze it before setting it as current
    property string uploadError

    id: popup

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
            source: profileModel.profile.largeImage
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
            onCropFinished: {
                uploadError = profileModel.uploadNewProfilePic(selectedImage, aX, aY, bX, bY)
            }
        }
    }

    footer: Item {
        width: parent.width
        height: uploadBtn.height

        StatusButton {
            visible: profileModel.profile.hasIdentityImage
            type: "secondary"
            flat: true
            color: Style.current.danger
            //% "Remove"
            text: qsTrId("remove")
            anchors.right: uploadBtn.left
            anchors.rightMargin: Style.current.padding
            anchors.bottom: parent.bottom
            onClicked: {
                uploadError = profileModel.deleteProfilePic()
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

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
