import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QtGraphicalEffects 1.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Backpressure 0.1
import StatusQ.Core.Theme 0.1

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

    readonly property int failsCount: capture.failsCount
    readonly property int tagsCount: capture.tagsCount
    readonly property int decodeTime: capture.decodeTime
    readonly property string lastTag: capture.lastTag
    readonly property string currentTag: capture.currentTag

    signal tagFound(string tag)

    implicitWidth: sourceSize.width
    implicitHeight: sourceSize.height

    QtObject {
        id: d

        readonly property int radius: 16
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.palette.baseColor4
        radius: d.radius
    }

    Item {
        anchors.fill: parent
        visible: capture.cameraAvailable
        clip: true

        StatusQrCodeCapture {
            id: capture

            anchors.fill: parent
            visible: false
            clip: true

            onTagFound: (tag) => root.tagFound(tag)
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
            source: capture
            maskSource: mask
        }

        Loader {
            active: root.highlightContentZone
            sourceComponent: Rectangle {
                color: "blue"
                opacity: 0.2
                border.width: 3
                border.color: "blue"
                x: capture.contentRect.x
                y: capture.contentRect.y
                width: capture.contentRect.width
                height: capture.contentRect.height
            }
        }

        Loader {
            active: root.highlightCaptureZone
            sourceComponent:  Rectangle {
                color: "hotpink"
                opacity: 0.2
                border.width: 3
                border.color: "hotpink"
                x: capture.contentRect.x + root.captureRectangle.x * capture.contentRect.width
                y: capture.contentRect.y + root.captureRectangle.y * capture.contentRect.height
                width: capture.contentRect.width * root.captureRectangle.width
                height: capture.contentRect.height * root.captureRectangle.height
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
        visible: capture.availableCameras.length > 0
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
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: Theme.palette.dangerColor1
            visible: !capture.cameraAvailable
            text: qsTr("Camera is not available")
        }

        StatusBaseText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: Theme.palette.directColor5
            text: capture.cameraError
        }
    }
}

