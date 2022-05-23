import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

import utils 1.0

Item {
    id: root

    signal imageCropped(var image, var cropRect)

    function chooseImageToCrop() {
        fileDialog.open()
    }

    FileDialog {
        id: fileDialog

        title: qsTr("Choose an image for profile picture")
        folder: shortcuts.pictures
        nameFilters: [qsTr("Supported image formats (%1)").arg("*.jpg, *.jpeg, *.jfif, *.png *.tiff *.heif")]
        onAccepted: {
            if (fileDialog.fileUrls.length > 0) {
                bannerCropper.source = fileDialog.fileUrls[0]
                imageCropperModal.open()
            }
        }
    } // FileDialog

    StatusModal {
        id: imageCropperModal

        header.title: qsTr("Profile picture")

        anchors.centerIn: Overlay.overlay

        StatusImageCropPanel {
            id: bannerCropper

            implicitWidth: 480
            implicitHeight: 350

            anchors {
                 fill: parent
                 leftMargin: Style.current.padding * 2
                 rightMargin: Style.current.padding * 2
                 topMargin: Style.current.bigPadding
                 bottomMargin: Style.current.bigPadding
             }

            aspectRatio: 1

            enableCheckers: true
        }

        rightButtons: [
            StatusButton {
                text: qsTr("Make this my profile picture")

                enabled: bannerCropper.sourceSize.width > 0 && bannerCropper.sourceSize.height > 0

                onClicked: {
                    root.imageCropped(bannerCropper.source, bannerCropper.cropRect)
                    imageCropperModal.close()
                }
            }
        ]
    } // StatusModal
} // Item

