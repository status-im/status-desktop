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

    height: Style.dp(510)
    header.title: qsTr("Upload profile picture")

    property string currentProfileImg: ""
    property string croppedImg: ""

    signal setProfileImage(string image)

    // Internals
    //
    onOpened: imageEditor.userSelectedImage = false
    onClosed: popup.croppedImg = ""

    contentItem: Item {
        anchors.fill: parent

        EditCroppedImagePanel {
            id: imageEditor

            width: Style.dp(160)
            height: Style.dp(160)
            anchors.centerIn: parent

            imageFileDialogTitle: qsTr("Choose an image for profile picture")
            title: qsTr("Profile picture")
            acceptButtonText: qsTr("Make this my profile picture")

            aspectRatio: 1

            dataImage: popup.currentProfileImg

            NoImageUploadedPanel {
                anchors.centerIn: parent

                visible: imageEditor.nothingToShow
            }
        }
    }

    rightButtons: [
        StatusFlatButton {
            visible: !!popup.currentProfileImg
            type: StatusBaseButton.Type.Danger
            text: qsTr("Remove")
            onClicked: {
                OnboardingStore.clearImageProps()
                popup.setProfileImage("")
                close();
            }
        },
        StatusButton {
            id: uploadBtn
            text: imageEditor.userSelectedImage ? qsTr("Upload") : qsTr("Done")
            onClicked: {
                if (imageEditor.userSelectedImage) {
                    popup.croppedImg = OnboardingStore.generateImage(imageEditor.source,
                                             imageEditor.cropRect.x.toFixed(),
                                             imageEditor.cropRect.y.toFixed(),
                                             (imageEditor.cropRect.x + imageEditor.cropRect.width).toFixed(),
                                             (imageEditor.cropRect.y + imageEditor.cropRect.height).toFixed())
                    popup.setProfileImage(popup.croppedImg)
                }
                close();
            }
        }
    ]
}

