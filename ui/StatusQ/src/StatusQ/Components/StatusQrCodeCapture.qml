import QtQuick

import QtMultimedia
import QZXing

Item {
    id: root

    readonly property size sourceSize: Qt.size(videoOutput.sourceRect.width,
                                               videoOutput.sourceRect.height)
    readonly property size contentSize: Qt.size(videoOutput.contentRect.width,
                                                videoOutput.contentRect.height)
    readonly property real sourceRatio: videoOutput.sourceRect.width
                                        / videoOutput.sourceRect.height

    readonly property int failsCount: d.failsCount
    readonly property int tagsCount: d.tagsCount
    readonly property int decodeTime: d.decodeTime
    readonly property string lastTag: d.lastTag
    readonly property string currentTag: d.currentTag

    readonly property alias contentRect: videoOutput.contentRect

    readonly property var availableCameras: {
        return mediaDevices.videoInputs.map(d => ({
            deviceId: d.id.toString(),
            displayName: d.description
        }))
    }

    readonly property bool cameraAvailable: camera.active
    readonly property string cameraError: camera.errorString

    signal tagFound(string tag)

    function setCameraDevice(deviceId: string) {
        camera.cameraDevice = mediaDevices.videoInputs.find(
                    d => d.id.toString() === deviceId)
    }

    MediaDevices {
        id: mediaDevices
    }

    QtObject {
        id: d

        property int failsCount: 0
        property int tagsCount: 0
        property int decodeTime: 0
        property string lastTag
        property string currentTag
    }

    Camera {
        id: camera

        active: true
        focusMode: Camera.FocusModeAutoNear

        Component.onDestruction: camera.active = false
    }

    CaptureSession {
        camera: camera
        videoOutput: videoOutput
    }

    VideoOutput {
        id: videoOutput

        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
    }

    QZXingFilter {
        id: zxingFilter
        videoSink: videoOutput.videoSink
        orientation: videoOutput.orientation

        captureRect: videoOutput.sourceRect

        decoder {
            enabledDecoders: QZXing.DecoderFormat_EAN_13 | QZXing.DecoderFormat_CODE_39 | QZXing.DecoderFormat_QR_CODE
            onTagFound: (tag) => {
                d.currentTag = tag
                d.lastTag = tag
                root.tagFound(tag)
            }
            tryHarder: false
        }

        onDecodingFinished: (succeeded, decodeTime) => {
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
