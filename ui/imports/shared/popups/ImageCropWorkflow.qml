import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1

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

    StatusFileDialog {
        id: fileDialog

        title: root.imageFileDialogTitle
        currentFolder: root.userSelectedImage ? imageCropper.source.substr(0, imageCropper.source.lastIndexOf("/")) : fileDialog.picturesShortcut
        nameFilters: [qsTr("Supported image formats (%1)").arg(UrlUtils.validImageNameFilters)]
        onAccepted: {
            if (fileDialog.selectedFiles.length > 0) {
                const url = fileDialog.selectedFiles[0]
                if (Utils.isValidDragNDropImage(url))
                    cropImage(url)
                else
                    errorDialog.open()
            }
        }
    } // FileDialog

    StatusDialog {
        id: errorDialog
        title: qsTr("Image format not supported")
        width: 480
        contentItem: ColumnLayout {
            StatusBaseText {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: qsTr("Format of the image you chose is not supported. Most probably you picked a file that is invalid, corrupted or has a wrong file extension.")
            }
            StatusBaseText {
                Layout.fillWidth: true
                font.pixelSize: Theme.additionalTextSize
                text: qsTr("Supported image extensions: %1").arg(UrlUtils.allValidImageExtensions)
            }
        }
        standardButtons: Dialog.Ok
    } // StatusDialog

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
                leftMargin: Theme.bigPadding + Theme.halfPadding / 2
                rightMargin: Theme.bigPadding + Theme.halfPadding / 2
                topMargin: Theme.bigPadding
                bottomMargin: Theme.bigPadding
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

