import QtQuick 2.15

import QtMultimedia 5.15
import QZXing 3.3

Item {
    id: root

    readonly property size sourceSize: Qt.size(videoOutput.sourceRect.width,
                                               videoOutput.sourceRect.height)
    readonly property real sourceRatio: videoOutput.sourceRect.width
                                        / videoOutput.sourceRect.height
    readonly property size contentSize: Qt.size(videoOutput.contentRect.width,
                                                videoOutput.contentRect.height)
    readonly property alias contentRect: videoOutput.contentRect

    readonly property int failsCount: d.failsCount
    readonly property int tagsCount: d.tagsCount
    readonly property int decodeTime: d.decodeTime
    readonly property string lastTag: d.lastTag
    readonly property string currentTag: d.currentTag

    readonly property var availableCameras: d.availableCameras
    readonly property bool cameraAvailable: camera.availability === Camera.Available
    readonly property string cameraError: camera.errorString

    function setCameraDevice(deviceId) {
        camera.deviceId = "" // Workaround for Qt bug. Without this the device changes only first time.
        camera.deviceId = deviceId
    }

    signal tagFound(string tag)

    QtObject {
        id: d

        // NOTE: QtMultimedia.availableCameras also makes a request to OS, if not made previously.
        //       So we postpone this call until the `Camera` component is loaded
        property var availableCameras: []

        property int failsCount: 0
        property int tagsCount: 0
        property int decodeTime: 0
        property string lastTag
        property string currentTag

    }

    VideoOutput {
        id: videoOutput

        anchors.fill: parent

        source: Camera {
            id: camera

            focus {
                focusMode: CameraFocus.FocusContinuous
                focusPointMode: CameraFocus.FocusPointAuto
            }

            Component.onCompleted: {
                d.availableCameras = QtMultimedia.availableCameras
            }
        }

        filters: QZXingFilter {
            id: qzxingFilter
            orientation: videoOutput.orientation
            captureRect: {
                videoOutput.contentRect; videoOutput.sourceRect // bindings
                const normalizedRectangle = Qt.rect(0, 0, 1, 1)
                const rectangle = videoOutput.mapNormalizedRectToItem(normalizedRectangle)

                console.log("CAPTURE RECT:", videoOutput.mapRectToSource(rectangle))

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

        fillMode: VideoOutput.PreserveAspectCrop
    }
}
