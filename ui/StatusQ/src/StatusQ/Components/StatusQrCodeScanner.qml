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

    readonly property alias camera: camera
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
            if (!camera)
                return
            camera.deviceId = "" // Workaround for Qt bug. Without this the device changes only first time.
            camera.deviceId = deviceId
        }

        property QtObject camera: null

        //  NOTE:   QtMultimedia.availableCameras also makes a request to OS, if not made previously.
        //          So we postpone this call until the `Camera` component is loaded
        property var availableCameras: []

        function onCameraLoaded() {
            d.availableCameras = QtMultimedia.availableCameras
        }

        property int failsCount: 0
        property int tagsCount: 0
        property int decodeTime: 0
        property string lastTag
        property string currentTag

    }

    Camera {
        id: camera
        focus {
            focusMode: CameraFocus.FocusContinuous
            focusPointMode: CameraFocus.FocusPointAuto
        }

        Component.onCompleted: {
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
        visible: camera && camera.availability === Camera.Available
        clip: true

        VideoOutput {
            id: videoOutput
            anchors.fill: parent
            visible: false
            source: camera
            filters: [ qzxingFilter ]
            fillMode: VideoOutput.PreserveAspectCrop
        }

        Rectangle {
            id: mask
            anchors.fill: parent
            radius: d.radius
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
            visible: camera && camera.availability !== Camera.Available
            text: qsTr("Camera is not available")
        }

        StatusBaseText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: Theme.palette.directColor5
            visible: camera && camera.errorCode !== Camera.NoError
            text: camera ? camera.errorString : ""
        }
    }
}

