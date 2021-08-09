import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import StatusQ.Core 0.1
import "../../imports"
import "../../shared"
import "../../shared/status/core"
import "../../shared/status"
import "../../app/Media"

Popup {
    id: root
    modal: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    background: Rectangle {
        radius: Style.current.radius
        color: Style.current.background
        border.color: Style.current.border
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 3
            radius: 8
            samples: 15
            fast: true
            cached: true
            color: "#22000000"
        }
    }

    Connections {
        target: chatsModel
        onOnlineStatusChanged: {
            root.close()
        }
    }

    contentItem: RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Style.current.smallPadding
        anchors.rightMargin: Style.current.smallPadding
        spacing: Style.current.smallPadding

        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            color: Style.current.danger
            font.weight: Font.DemiBold
            font.pixelSize: 13
            text: qsTr("Recording") + ".".repeat(recTimer.count)
        }

        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            font.weight: Font.DemiBold
            font.pixelSize: 13
            text: {
                if (!recorderLoader.active) {
                    return ""
                }
                let t = new Date(1970, 0, 1); // Epoch
                let sec =recorderLoader.item.recording.duration
                t.setSeconds(sec)
                return Qt.formatTime(t, sec >= 3600 ? "h:mm:ss" : "m:ss")
            }
        }

        StatusIconButton {
            Layout.alignment: Qt.AlignVCenter
            icon.name: "send"
            type: "primary"
            onClicked: {
                recorderLoader.item.recording.stop()
            }
        }
    }

    Timer {
        id: recTimer
        property int count: 0
        running: root.opened
        interval: 300
        repeat: true
        onTriggered: {
            count++
            if (count > 3) {
                count = 0
            }
        }
        onRunningChanged: {
            if (running) {
                count = 0
            }
        }
    }

    Loader {
        id: recorderLoader
        active: root.opened
        sourceComponent: VoiceMessageRecorder {
            Connections {
                target: recording
                function onRecorded(data64, duration) {
                    root.close()
                    chatsModel.sendAudio(data64, duration, false)
                }
                function onError(err) {
                    root.close()
                    recordingFailedPopup.error = err
                    recordingFailedPopup.open()
                }
            }            
        }
    }

    MessageDialog {
        id: recordingFailedPopup
        property string error
        standardButtons: StandardButton.Ok
        text: qsTr("Failed to start recording: %1").arg(error)
        icon: StandardIcon.Critical
    }
}

