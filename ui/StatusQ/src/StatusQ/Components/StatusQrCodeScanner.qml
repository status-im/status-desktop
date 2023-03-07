import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QtMultimedia 5.15
import QtGraphicalEffects 1.0

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import QZXing 3.3

Item {
    id: root

    readonly property alias camera: camera

    readonly property size sourceSize: Qt.size(videoOutput.sourceRect.width, videoOutput.sourceRect.height)
    readonly property size contentSize: Qt.size(videoOutput.contentRect.width, videoOutput.contentRect.height)
    readonly property real sourceRatio: videoOutput.sourceRect.width / videoOutput.sourceRect.height

    property int failsCount: 0
    property int tagsCount: 0
    property int decodeTime: 0

    property string lastTag

    implicitWidth: sourceSize.width
    implicitHeight: sourceSize.height

    signal tagFound(string tag)

    QtObject {
        id: d

        readonly property int radius: 16
    }

    Camera {
        id: camera
        captureMode: Camera.CaptureVideo
        focus {
            focusMode: CameraFocus.FocusContinuous
            focusPointMode: CameraFocus.FocusPointAuto
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
        visible: camera.availability === Camera.Available

        VideoOutput {
            id: videoOutput
            anchors.fill: parent
            visible: false
            source: camera
            filters: [ qzxingFilter ]
            fillMode: VideoOutput.PreserveAspectFit
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

        QZXingFilter {
            id: qzxingFilter
            orientation: videoOutput.orientation
            captureRect: {
                videoOutput.contentRect; videoOutput.sourceRect; // bindings
                const normalizedRectangle = Qt.rect(0, 0, 1, 1)
                const rectangle = videoOutput.mapNormalizedRectToItem(normalizedRectangle)
                return videoOutput.mapRectToSource(rectangle);
            }

            decoder {
                enabledDecoders: QZXing.DecoderFormat_QR_CODE
                tryHarder: true
                onTagFound: {
                    root.lastTag = tag
                    root.tagFound(tag)
                }
            }

            onDecodingFinished: {
                if (succeeded)
                    ++root.tagsCount
                else
                    ++root.failsCount
                root.decodeTime = decodeTime
            }
        }
    }

    // TODO: Implement camera selector
    //       For me it works once. The first switch between 2 cameras is ok.
    //       The second switch doesn't work and behaves different with 2 approaches:
    //       With standard `ComboBox` it throws an exception.
    //       Width `StatusComboBox` it just kinda unbinds from the Camera.
    //
    //    ComboBox {
    //        id: cameraComboBox

    //        anchors {
    //            right: parent.right
    //            bottom: parent.bottom
    //            margins: 10
    //        }

    //        width: implicitWidth
    //        opacity: 0.7
    //        model: QtMultimedia.availableCameras
    //        textRole: "displayName"
    //        valueRole: "deviceId"
    //        onCurrentValueChanged: {
    //            camera.deviceId = currentValue
    //        }
    //    }

    //    StatusComboBox {
    //        id: cameraComboBox
    //        anchors {
    //            right: parent.right
    //            bottom: parent.bottom
    //            margins: 10
    //        }

    //        width: implicitWidth
    //        opacity: 0.7
    //        model: QtMultimedia.availableCameras
    //        control.textRole: "displayName"
    //        control.valueRole: "deviceId"
    //        onCurrentValueChanged: {
    //            console.log("setting deviceId to", currentValue)
    //            camera.deviceId = currentValue
    //        }
    //    }

    ColumnLayout {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width

        spacing: 10

        StatusBaseText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: Theme.palette.dangerColor1
            visible: camera.availability !== Camera.Available
            text: qsTr("Camera is not available")
        }

        StatusBaseText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: Theme.palette.directColor5
            visible: camera.errorCode !== Camera.NoError
            text: "Error comes here" // camera.errorString
        }
    }
}

