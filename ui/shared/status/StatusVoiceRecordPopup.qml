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
    property real recordingLimitSec: 120

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

    onOpened: {
        popupItem.state = "recording"
    }

    QtObject {
        id: d
        property string audioBase64
        property real audioDurationSec
    }

    contentItem: RowLayout {
        id: popupItem
        anchors.fill: parent
        anchors.leftMargin: Style.current.smallPadding
        anchors.rightMargin: Style.current.smallPadding
        spacing: Style.current.smallPadding

        state: "recording"
        states: [
            State {
                name: "limit"
                PropertyChanges {
                    target: errorText
                    visible: true
                }
                PropertyChanges {
                    target: recordingText
                    visible: false
                }
            },
            State {
                name: "error"
                PropertyChanges {
                    target: errorText
                    visible: true
                    text: qsTr("Recording error")
                }
                PropertyChanges {
                    target: recordingText
                    visible: false
                }
                PropertyChanges {
                    target: timerText
                    visible: false
                }
                PropertyChanges {
                    target: sendButton
                    enabled: false
                }
            }
        ]

        StatusBaseText {
            id: errorText
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            visible: false
            color: Style.current.danger
            font.weight: Font.DemiBold
            font.pixelSize: 13
            text: qsTr("Recording limit reached")
        }

        StatusBaseText {
            id: recordingText
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            color: Style.current.danger
            font.weight: Font.DemiBold
            font.pixelSize: 13
            text: qsTr("Recording") + ".".repeat(recTimer.count)
        }

        StatusBaseText {
            id: timerText
            Layout.alignment: Qt.AlignVCenter
            font.weight: Font.DemiBold
            font.pixelSize: 13
            text: {
                if (!recorderLoader.active) {
                    return ""
                }
                let t = new Date(1970, 0, 1); // Epoch
                let sec = recorderLoader.item.recording.duration
                t.setMilliseconds(sec * 1000.0)
                return Qt.formatTime(t, sec >= 3600 ? "h:mm:ss" : "m:ss")
            }
        }

        StatusIconButton {
            id: sendButton
            Layout.alignment: Qt.AlignVCenter
            icon.name: "send"
            type: "primary"
            onClicked: {
                if (popupItem.state === "limit") {
                    root.close()
                    chatsModel.sendAudio(d.audioBase64, d.audioDurationSec, false)
                    d.audioBase64 = ""
                } else {
                    recorderLoader.item.recording.stop()
                }
            }
        }

        Timer {
            id: recTimer
            property int count: 0
            running: root.opened && popupItem.state === "recording"
            interval: 300
            repeat: true
            onTriggered: {
                if (recorderLoader.item.recording.duration >= root.recordingLimitSec) {
                    popupItem.state = "limit"
                    recorderLoader.item.recording.stop()
                } else {
                    count++
                    if (count > 3) {
                        count = 0
                    }
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
                        if (popupItem.state === "recording") {
                            root.close()
                            chatsModel.sendAudio(data64, duration, false)
                        } else {
                            d.audioBase64 = data64
                            d.audioDurationSec = duration
                        }
                    }
                    function onError(err) {
                        console.error(err)
                        popupItem.state = error
                    }
                }
            }
        }
    }
}

