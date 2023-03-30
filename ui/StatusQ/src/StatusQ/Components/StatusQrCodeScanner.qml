import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QtMultimedia 5.15
import QtGraphicalEffects 1.0

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Backpressure 1.0
import StatusQ.Core.Theme 0.1

import QZXing 3.3

/*
    NOTE:   I'm doing some crazy workarounds here. Tested on MacOS.
            What I wanted to achieve:

            1. User only gets a OS "allow camera access" popup
               when a page with QR code scanner is opened.
            2. Mimize UI freezes, or at least make it obvious
               that something is going on.

    Camera component uses main UI thread to request OS for available devices.
    Therefore, we can't simply use Loader with `asyncronous` flag.
    Neiter we can set `loading: loader.status === Loader.Loading` to this button.

    To achieve desired points, I manually set `loading` property of the button
    and delay the camera loading for 250ms. UI quickly shows loading indicator,
    then it will freeze until the camera is loaded.

    I think this can only be improved by moving the OS requests to another thread from C++.

    We also don't yet have ability to auto-detect if the camera access was already enabled.
    So we show `Enable camera` button everytime.
*/

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

    readonly property alias camera: d.camera
    readonly property size sourceSize: Qt.size(videoOutput.sourceRect.width, videoOutput.sourceRect.height)
    readonly property size contentSize: Qt.size(videoOutput.contentRect.width, videoOutput.contentRect.height)
    readonly property real sourceRatio: videoOutput.sourceRect.width / videoOutput.sourceRect.height

    readonly property int failsCount: d.failsCount
    readonly property int tagsCount: d.tagsCount
    readonly property int decodeTime: d.decodeTime
    readonly property string lastTag: d.lastTag
    readonly property string currentTag: d.currentTag

    signal tagFound(string tag)

    implicitWidth: sourceSize.width
    implicitHeight: sourceSize.height

    QtObject {
        id: d

        readonly property int radius: 16

        function setCameraDevice(deviceId) {
            if (!d.camera)
                return
            d.camera.deviceId = "" // Workaround for Qt bug. Without this the device changes only first time.
            d.camera.deviceId = deviceId
        }

        property QtObject camera: null

        //  NOTE:   QtMultimedia.availableCameras also makes a request to OS, if not made previously.
        //          So we postpone this call until the `Camera` component is loaded
        property var availableCameras: []

        function onCameraLoaded() {
            d.camera = loader.item
            d.availableCameras = QtMultimedia.availableCameras
            button.loading = false
        }

        property int failsCount: 0
        property int tagsCount: 0
        property int decodeTime: 0
        property string lastTag
        property string currentTag

    }

    Loader {
        id: loader
        active: false
        visible: status == Loader.Ready
        sourceComponent: Camera {
            focus {
                focusMode: CameraFocus.FocusContinuous
                focusPointMode: CameraFocus.FocusPointAuto
            }
        }
        onLoaded: {
            d.onCameraLoaded()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.palette.baseColor4
        radius: d.radius
    }

    Item {
        anchors.fill: parent
        implicitWidth: videoOutput.contentRect.width
        implicitHeight: videoOutput.contentRect.height
        visible: d.camera && d.camera.availability === Camera.Available
        clip: true

        VideoOutput {
            id: videoOutput
            anchors.fill: parent
            visible: false
            source: d.camera
            filters: [ qzxingFilter ]
            fillMode: VideoOutput.PreserveAspectCrop
        }

        Rectangle {
            id: mask
            anchors.fill: parent
            radius: 16
            visible: false
            color: "black"
        }

        OpacityMask {
            anchors.fill: parent
            source: videoOutput
            maskSource: mask
        }

        Loader {
            active: root.highlightContentZone
            sourceComponent: Rectangle {
                color: "blue"
                opacity: 0.2
                border.width: 3
                border.color: "blue"
                x: videoOutput.contentRect.x
                y: videoOutput.contentRect.y
                width: videoOutput.contentRect.width
                height: videoOutput.contentRect.height
            }
        }

        Loader {
            active: root.highlightCaptureZone
            sourceComponent:  Rectangle {
                color: "hotpink"
                opacity: 0.2
                border.width: 3
                border.color: "hotpink"
                x: videoOutput.contentRect.x + root.captureRectangle.x * videoOutput.contentRect.width
                y: videoOutput.contentRect.y + root.captureRectangle.y * videoOutput.contentRect.height
                width: videoOutput.contentRect.width * root.captureRectangle.width
                height: videoOutput.contentRect.height * root.captureRectangle.height
            }
        }

        QZXingFilter {
            id: qzxingFilter
            orientation: videoOutput.orientation
            captureRect: {
                videoOutput.contentRect; videoOutput.sourceRect // bindings
                const normalizedRectangle = root.captureRectangle
                const rectangle = videoOutput.mapNormalizedRectToItem(normalizedRectangle)
                return videoOutput.mapRectToSource(rectangle);
            }

            decoder {
                enabledDecoders: QZXing.DecoderFormat_QR_CODE
                onTagFound: {
                    d.currentTag = tag
                    d.lastTag = tag
                    root.tagFound(tag)
                }
            }

            onDecodingFinished: {
                if (succeeded) {
                    ++d.tagsCount
                } else {
                    ++d.failsCount
                    d.currentTag = ""
                }
                d.decodeTime = decodeTime
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        visible: loader.status !== Loader.Ready || loader.status === Loader.Error
        spacing: 20

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        StatusBaseText {
            Layout.fillWidth: true
            text: qsTr('Enable access to your camera')
            leftPadding: 48
            rightPadding: 48
            font.pixelSize: 15
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        StatusBaseText {
            Layout.fillWidth: true
            text: qsTr("To scan a QR, Status needs\naccess to your webcam")
            leftPadding: 48
            rightPadding: 48
            font.pixelSize: 15
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            color: Theme.palette.directColor4
        }

        StatusButton {
            id: button
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Enable camera access")
            onClicked: {
                loading = true
                Backpressure.debounce(this, 250, () => { loader.active = true })()
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    StatusComboBox {
        id: cameraComboBox

        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 10
        }

        width: Math.min(implicitWidth, parent.width / 2)
        visible: Array.isArray(d.availableCameras) && d.availableCameras.length > 0
        opacity: 0.7
        model: d.availableCameras
        control.textRole: "displayName"
        control.valueRole: "deviceId"
        control.padding: 8
        control.spacing: 8
        onCurrentValueChanged: {
            // Debounce to close combobox first
            Backpressure.debounce(this, 50, () => { d.setCameraDevice(currentValue) })()
        }
    }

    ColumnLayout {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        spacing: 10

        StatusBaseText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: Theme.palette.dangerColor1
            visible: d.camera && d.camera.availability !== Camera.Available
            text: qsTr("Camera is not available")
        }

        StatusBaseText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: Theme.palette.directColor5
            visible: d.camera && d.camera.errorCode !== Camera.NoError
            text: d.camera ? d.camera.errorString : ""
        }
    }
}

