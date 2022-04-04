import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1

import "../controls"
import "."

// TODO: replace with StatusModal
ModalPopup {
    property string selectedImage
    property string ratio: "1:1"
    property int aX: 0
    property int aY: 0
    property int bX: 0
    property int bY: 0
    signal cropFinished(aX: int, aY: int, bX: int, bY: int)

    id: cropImageModal
    width: image.width + 50
    height: image.height + 170
    title: qsTr("Crop your image (optional)")

    Image {
        id: image
        width: 400
        source: cropImageModal.selectedImage
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        fillMode: Image.PreserveAspectFit
    }

    ImageCropper {
        id: imageCropper
        x: image.x
        y: image.y
        image: image
        ratio: cropImageModal.ratio
        onReadyChanged: {
            if (ready) {
                // cropImageModal.calculateCrop()
                cropImageModal.aX = Qt.binding(function() {
                    const aXPercent = imageCropper.selectorRectangle.x / image.width
                    return Math.round(aXPercent * image.sourceSize.width)
                })
                cropImageModal.aY = Qt.binding(function() {
                    const aYPercent = imageCropper.selectorRectangle.y / image.height
                    return Math.round(aYPercent * image.sourceSize.height)
                })
                cropImageModal.bX = Qt.binding(function() {
                    const bXPercent = (imageCropper.selectorRectangle.x + imageCropper.selectorRectangle.width) / image.width
                    return Math.round(bXPercent * image.sourceSize.width)
                })
                cropImageModal.bY = Qt.binding(function() {
                    const bYPercent = (imageCropper.selectorRectangle.y + imageCropper.selectorRectangle.height) / image.height
                    return Math.round(bYPercent * image.sourceSize.height)
                })
            }
        }

    }

    footer: StatusButton {
        id: doneBtn
        text: qsTr("Finish")
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        onClicked: {
            const aXPercent = imageCropper.selectorRectangle.x / image.width
            const aYPercent = imageCropper.selectorRectangle.y / image.height
            const bXPercent = (imageCropper.selectorRectangle.x + imageCropper.selectorRectangle.width) / image.width
            const bYPercent = (imageCropper.selectorRectangle.y + imageCropper.selectorRectangle.height) / image.height


            const aX = Math.round(aXPercent * image.sourceSize.width)
            const aY = Math.round(aYPercent * image.sourceSize.height)

            const bX = Math.round(bXPercent * image.sourceSize.width)
            const bY = Math.round(bYPercent * image.sourceSize.height)

            cropImageModal.cropFinished(aX, aY, bX, bY)
            cropImageModal.close()
        }
    }
}
