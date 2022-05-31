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

    property alias aspectRatio: bannerCropper.aspectRatio
    property alias windowStyle: bannerCropper.windowStyle
    /*required*/ property string imageFileDialogTitle: ""
    /*required*/ property string title: ""
    /*required*/ property string acceptButtonText: ""
    property bool roundedImage: true

    signal imageCropped(var image, var cropRect)

    function chooseImageToCrop() {
        fileDialog.open()
    }

    FileDialog {
        id: fileDialog

        title: root.imageFileDialogTitle
        folder: root.userSelectedImage ? bannerCropper.source.substr(0, bannerCropper.source.lastIndexOf("/")) : shortcuts.pictures
        nameFilters: [qsTr("Supported image formats (%1)").arg("*.jpg *.jpeg *.jfif *.webp *.png *.heif")]
        onAccepted: {
            if (fileDialog.fileUrls.length > 0) {
                bannerCropper.source = fileDialog.fileUrls[0]
                imageCropperModal.open()
            }
        }
    } // FileDialog

    StatusModal {
        id: imageCropperModal

        header.title: root.title

        anchors.centerIn: Overlay.overlay

        width: root.roundedImage ? 480 : 580

        StatusImageCropPanel {
            id: bannerCropper

            implicitHeight: 350

            anchors {
                 fill: parent
                 leftMargin: Style.current.padding * 2
                 rightMargin: Style.current.padding * 2
                 topMargin: Style.current.bigPadding
                 bottomMargin: Style.current.bigPadding
            }

            margins: root.roundedImage ? 10 : 20
            windowStyle: root.roundedImage ? StatusImageCrop.WindowStyle.Rounded : StatusImageCrop.WindowStyle.Rectangular
            enableCheckers: true
        }

        rightButtons: [
            StatusButton {
                text: root.acceptButtonText

                enabled: bannerCropper.sourceSize.width > 0 && bannerCropper.sourceSize.height > 0

                onClicked: {
                    root.imageCropped(bannerCropper.source, bannerCropper.cropRect)
                    imageCropperModal.close()
                }
            }
        ]
    } // StatusModal
} // Item

