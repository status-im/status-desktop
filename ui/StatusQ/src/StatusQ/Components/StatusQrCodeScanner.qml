import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Backpressure
import StatusQ.Core.Theme

Item {
    id: root

    property rect captureRectangle: Qt.rect(0, 0, 1, 1)

    // Use this property to clip capture rectangle to biggest possible square
    readonly property rect squareCaptureRectangle: {
        const size = Math.min(contentSize.width, contentSize.height)
        const w = size / contentSize.width
        const h = size / contentSize.height
        const x = (1 - w) / 2
        const y = (1 - h) / 2
        return Qt.rect(x, y, w, h)
    }

    property bool highlightContentZone: false
    property bool highlightCaptureZone: false

    readonly property alias cameraAvailable: capture.cameraAvailable
    readonly property size sourceSize: capture.sourceSize
    readonly property size contentSize: capture.contentSize
    readonly property real sourceRatio: capture.sourceRatio

    // Frames of the running camera, for the host's frame tap / decoder.
    readonly property var videoSink: capture.videoSink

    // The scan corners in this item's pixels and how the preview shows the
    // video: what a frame tap needs to crop each frame as shown, from that
    // frame's own size and rotation (NimQtCamera FrameTap.setPreviewRoi).
    readonly property var captureArea: ({
        x: scanCorners.x, y: scanCorners.y,
        width: scanCorners.width, height: scanCorners.height,
        previewWidth: capture.width, previewHeight: capture.height,
        fillMode: capture.fillMode, mirrored: capture.mirrored
    })

    // The camera runs while this is true, the scanner is visible and the
    // application is active (not in the background, not lost focus).
    property bool active: true

    // Whether the camera is running; hosts gate frame taps / decoding on it.
    readonly property bool capturing: root.active && root.visible
                                      && Qt.application.state === Qt.ApplicationActive

    property int state: StatusQrCodeScanner.State.None

    property bool imagePickerVisible: false
    property bool imagePickerEnabled: true

    property bool flashlightAvailable: capture.cameraAvailable && capture.torchSupported

    property bool flashlightOn: false

    signal imagePickerRequested()

    onCapturingChanged: {
        if (!capturing)
            flashlightOn = false
    }

    enum State {
        None,
        Success,
        Error
    }

    implicitWidth: sourceSize.width
    implicitHeight: sourceSize.height

    QtObject {
        id: d

        readonly property int radius: 16
    }

    Item {
        anchors.fill: parent
        visible: capture.cameraAvailable
        clip: true

        StatusQrCodeCapture {
            id: capture

            anchors.fill: parent
            visible: true
            clip: true
            objectName: "qrCodeCapture"
            active: root.capturing
            torchOn: root.flashlightOn
        }

        Loader {
            active: root.state === StatusQrCodeScanner.State.Success || root.state === StatusQrCodeScanner.State.Error
            sourceComponent: Rectangle {
                color: {
                    if (root.state === StatusQrCodeScanner.State.Success) {
                        return Theme.palette.successColor2
                    }
                    if (root.state === StatusQrCodeScanner.State.Error) {
                        return Theme.palette.dangerColor3
                    }
                }
                x: capture.contentRect.x
                y: capture.contentRect.y
                width: capture.contentRect.width
                height: capture.contentRect.height
            }
        }
    }

    StatusScanCorners {
        id: scanCorners
        visible: !cameraUnavailableText.visible
        width: Math.min(root.width, root.height) / 1.4
        height: width
        anchors.centerIn: parent
        color: {
            if (root.state === StatusQrCodeScanner.State.Success) {
                return Theme.palette.successColor3
            }
            if (root.state === StatusQrCodeScanner.State.Error) {
                return Theme.palette.dangerColor2
            }
            return Theme.palette.baseColor4
        }
    }

    StatusButton {
        id: flashlightButton
        objectName: "qrFlashlightButton"

        anchors {
            left: parent.left
            bottom: parent.bottom
            margins: 12
        }

        width: 40
        height: 40
        normalColor: root.flashlightOn ? StatusColors.white : Theme.palette.baseColor2
        hoverColor: Theme.palette.hoverColor(normalColor)
        opacity: cameraComboBox.opacity
        visible: root.flashlightAvailable
        icon.name: root.flashlightOn ? "flashlight-on" : "flashlight-off"
        icon.color: root.flashlightOn ? Theme.palette.primaryColor1 : Theme.palette.directColor1
        tooltip.text: root.flashlightOn ? qsTr("Turn off the flashlight")
                                        : qsTr("Turn on the flashlight")
        onClicked: root.flashlightOn = !root.flashlightOn
    }

    StatusButton {
        id: qrUploadImageButton
        objectName: "qrUploadImageButton"

        anchors {
            left: flashlightButton.visible ? flashlightButton.right : parent.left
            bottom: parent.bottom
            leftMargin: 12
            bottomMargin: 12
        }

        width: 40
        height: 40
        normalColor: Theme.palette.baseColor2
        hoverColor: Theme.palette.hoverColor(normalColor)
        opacity: cameraComboBox.opacity
        visible: root.imagePickerVisible
        enabled: root.imagePickerEnabled
        icon.name: "select-image"
        icon.color: Theme.palette.directColor1
        tooltip.text: qsTr("Upload image")
        onClicked: root.imagePickerRequested()
    }

    StatusComboBox {
        id: cameraComboBox
        objectName: "qrCameraComboBox"

        anchors {
            right: parent.right
            verticalCenter: qrUploadImageButton.verticalCenter
            rightMargin: 12
        }

        width: Math.min(implicitWidth, parent.width / 2)
        height: 40
        visible: !cameraUnavailableText.visible && capture.availableCameras.length > 0
        opacity: 0.7
        model: capture.availableCameras
        control.textRole: "displayName"
        control.valueRole: "deviceId"
        control.padding: 8
        control.spacing: 8
        onCurrentValueChanged: {
            // Debounce to close combobox first
            Backpressure.debounce(this, 50, () => { capture.setCameraDevice(currentValue) })()
        }
    }

    ColumnLayout {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        spacing: 10

        StatusBaseText {
            id: cameraUnavailableText
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: Theme.palette.dangerColor1
            visible: !capture.cameraAvailable
            text: qsTr("Camera is not available")
            wrapMode: Text.WordWrap
        }

        StatusBaseText {
            visible: cameraUnavailableText.visible && capture.cameraError
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: Theme.palette.directColor5
            text: capture.cameraError
            wrapMode: Text.WordWrap
        }
    }

    Loader {
        id: loadingOverlay
        active: true
        anchors.fill: parent

        sourceComponent: Rectangle {
            anchors.fill: parent
            color: Theme.palette.baseColor4
            radius: d.radius
            visible: !capture.cameraAvailable

            StatusLoadingIndicator {
                anchors.centerIn: parent
            }

            Timer {
                interval: 2000
                running: true
                repeat: false
                onTriggered: {
                    loadingOverlay.active = false
                }
            }
        }
    }
}
