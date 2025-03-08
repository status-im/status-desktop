import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Components 0.1

import Storybook 1.0

SplitView {
    id: root

    orientation: Qt.Vertical
    Logs { id: logs }

    StatusAudio {
        id: audio

        volume: convertVolume(volumeSlider.value,
                              StatusAudio.logarithmicVolumeScale,
                              StatusAudio.linearVolumeScale)
        muted: mutedCheckbox.checked
        source: "qrc:/testData/audio_file_example.wav"

        onMutedChanged: logs.logEvent("StatusAudio::muted -> " + muted)
        onVolumeChanged: logs.logEvent("StatusAudio::volume -> " + volume)
        onPlaybackStateChanged: {
            if(playbackState === playingState) {
                logs.logEvent("StatusAudio::playing")
            } else if(playbackState === pausedState) {
                logs.logEvent("StatusAudio::paused")
            } else if (playbackState === stoppedState) {
                logs.logEvent("StatusAudio::stopped")
            }
        }
    }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Row {
            anchors.centerIn: parent
            spacing: 30

            Button {
                text: "Play"
                onClicked: audio.play()
            }

            Button {
                text: "Pause"
                onClicked: audio.pause()
            }

            Button {
                text: "Stop"
                onClicked: audio.stop()
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200
        SplitView.fillWidth: true

        logsView.logText: logs.logText

        Column {
            CheckBox {
                id: mutedCheckbox

                text: "Muted"
            }

            Label {
                text: "Volume"
            }

            Slider {
                id: volumeSlider


                from: 0.0
                to: 1.0
                stepSize: 0.1
                value: 0.2
            }
        }
    }
}

// category: Components
// status: good
