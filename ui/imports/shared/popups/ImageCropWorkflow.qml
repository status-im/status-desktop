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
    objectName: "imageCropWorkflow"

    property var callback: null
    property alias aspectRatio: imageCropper.aspectRatio
    property alias windowStyle: imageCropper.windowStyle
    /*required*/ property string imageFileDialogTitle: ""
    /*required*/ property string title: ""
    /*required*/ property string acceptButtonText: ""
    property bool roundedImage: true

    signal imageCropped(var image, var cropRect)
    signal done()

    function chooseImageToCrop() {
        fileDialog.open()
    }

    function cropImage(imageUrl) {
        imageCropper.source = imageUrl
        imageCropperModal.open()
    }

    FileDialog {
        id: fileDialog

        title: root.imageFileDialogTitle
        folder: root.userSelectedImage ? imageCropper.source.substr(0, imageCropper.source.lastIndexOf("/")) : shortcuts.pictures
        nameFilters: [qsTr("Supported image formats (%1)").arg(Constants.acceptedDragNDropImageExtensions.map(img => "*" + img).join(" "))]
        onAccepted: {
            if (fileDialog.fileUrls.length > 0) {
                cropImage(fileDialog.fileUrls[0])
            }
        }
    } // FileDialog

    StatusModal {
        id: imageCropperModal

        headerSettings.title: root.title

        width: root.roundedImage ? 480 : 580
        StatusImageCropPanel {
            id: imageCropper
            objectName: "profileImageCropper"

            implicitHeight: root.roundedImage ? 350 : 370

            anchors {
                fill: parent
                leftMargin: Style.current.bigPadding + Style.current.halfPadding / 2
                rightMargin: Style.current.bigPadding + Style.current.halfPadding / 2
                topMargin: Style.current.bigPadding
                bottomMargin: Style.current.bigPadding
            }

            margins: root.roundedImage ? 10 : 20
            windowStyle: root.roundedImage ? StatusImageCrop.WindowStyle.Rounded : StatusImageCrop.WindowStyle.Rectangular
            enableCheckers: true
        }

        rightButtons: [
            StatusButton {
                objectName: "imageCropperAcceptButton"
                text: root.acceptButtonText

                enabled: imageCropper.sourceSize.width > 0 && imageCropper.sourceSize.height > 0

                onClicked: {
                    root.imageCropped(imageCropper.source, imageCropper.cropRect)
                    imageCropperModal.close()
                }
            }
        ]
        onClosed: root.done()
    } // StatusModal
} // Item

