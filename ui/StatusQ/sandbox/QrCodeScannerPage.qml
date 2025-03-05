import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import QtMultimedia 5.15

Rectangle {
    id: root

    component ValueIndicator: RowLayout {

        property string title
        property alias value: lastTagText.text
        property bool readOnly: true

        spacing: 10

        StatusBaseText {
            text: parent.title
        }

        StatusInput {
            id: lastTagText
            Layout.fillWidth: true
            input.edit.readOnly: parent.readOnly
            input.edit.selectByKeyboard: true
            input.edit.selectByMouse: true
            input.rightPadding: 10
        }
    }

    color: Theme.palette.baseColor3

    QtObject {
        id: d

        function sizeToString(size) {
            return whToString(size.width, size.height)
        }

        function whToString(width, height) {
            return `${width.toFixed(0)}*${height.toFixed(0)}`
        }

        function rectToString(rect) {
            return `${rect.width.toFixed(2)}*${rect.height.toFixed(2)} (${rect.x.toFixed(2)}, ${rect.y.toFixed(2)})`
        }

        function cameraStateString(state) {
            switch (state) {
                case Camera.UnloadedState: return "Unloaded"
                case Camera.LoadedState: return "Loaded"
                case Camera.ActiveState: return "Active"
                default: return "unknown"
            }
        }

        function cameraStatusString(status) {
            switch (status) {
                case Camera.ActiveStatus: return "Active"
                case Camera.StartingStatus: return "Starting"
                case Camera.StoppingStatus: return "Stopping"
                case Camera.StandbyStatus: return "Standby"
                case Camera.LoadedStatus: return "Loaded"
                case Camera.LoadingStatus: return "Loading"
                case Camera.UnloadingStatus: return "Unloading"
                case Camera.UnloadedStatus: return "Unloaded"
                case Camera.UnavailableStatus: return "Unavailable"
                default: return "unknown"
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        StatusQrCodeScanner {
            id: qrScanner
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: width / sourceRatio
        }

        ValueIndicator {
            Layout.fillWidth: true
            title: "Last tag:"
            value: qrScanner.lastTag
        }

        RowLayout {
            Layout.fillWidth: true

            ValueIndicator {
                Layout.fillWidth: true
                title: "Current tag:"
                value: qrScanner.currentTag
            }

            ValueIndicator {
                title: "Last decode time, ms:"
                value: qrScanner.decodeTime
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            ValueIndicator {
                Layout.fillWidth: true
                title: "Source size:"
                value: d.sizeToString(qrScanner.sourceSize)
            }

            ValueIndicator {
                Layout.fillWidth: true
                title: "Source size:"
                value: d.sizeToString(qrScanner.contentSize)
            }

            ValueIndicator {
                Layout.fillWidth: true
                title: "View size:"
                value: d.whToString(qrScanner.width, qrScanner.height)
            }

            ValueIndicator {
                Layout.fillWidth: true
                title: "Capture rect:"
                value: d.rectToString(qrScanner.captureRectangle)
            }
        }
    }
}
