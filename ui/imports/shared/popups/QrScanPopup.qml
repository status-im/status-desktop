import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import QtMultimedia 5.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1

import ZXing 1.0
import utils 1.0

import shared.controls 1.0

import "../stores"

StatusModal {
    id: popup

    header.title: qsTr("Scan QR")
    width: 556
    height: 400

    contentItem: Column {
        id: layout
        width: popup.width

        topPadding: Style.current.smallPadding
        spacing: Style.current.bigPadding

        // Camera {
        //     id: camera

        //     imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash

        //     exposure {
        //         exposureCompensation: -1.0
        //         exposureMode: Camera.ExposurePortrait
        //     }

        //     flash.mode: Camera.FlashRedEyeReduction

        //     imageCapture {
        //         onImageCaptured: {
        //             photoPreview.source = preview  // Show the preview in an Image
        //         }
        //     }

        //     onCameraStateChanged: {
        //     }
        // }

        // Loader {
        //     id: cameraLoader
        //     active: true
        //     sourceComponent: {
        //         if (camera.availability === Camera.Available) {
        //             return cameraAvailable
        //         } else if (camera.availability === Camera.Busy) {
        //             return cameraUnavailable
        //         } else if (camera.availability === Camera.Unavailable) {
        //             return cameraUnavailable
        //         } else if (camera.availability === Camera.ResourceMissing) {
        //             return cameraUnavailable
        //         }
        //     }
        // }
        
        // Component {
        //     id: cameraUnavailable
        //     Rectangle{
        //     }
        // }

        // Component {
        //     id: cameraAvailable
        //     VideoOutput {
        //         id: output
        //         source: camera
        //         anchors.fill: parent
        //         focus : visible // to receive focus and capture key events when visible
        //     }
        // }
    }
}

