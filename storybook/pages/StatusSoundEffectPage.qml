import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Components 0.1

import Storybook 1.0

SplitView {
    id: root

    orientation: Qt.Vertical
    Logs { id: logs }

    StatusSoundEffect {
        id: sound

        volume: convertVolume(volumeSlider.value * 0.01)
        muted: mutedCheckbox.checked
        source: "qrc:/testData/audio_file_example.wav"

        onMutedChanged: logs.logEvent("StatusSoundEffect::muted -> " + muted)
        onVolumeChanged: logs.logEvent("StatusSoundEffect::volume -> " + volume)
        onPlayingChanged: {
            if(playing) {
                logs.logEvent("StatusSoundEffect::playing")
            } else {
                logs.logEvent("StatusSoundEffect::not playing")
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
                onClicked: sound.play()
            }

            Button {
                text: "Stop"
                onClicked: sound.stop()
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

                width: 400
                from: 1
                to: 100
                stepSize: 1
                value: 50
            }
        }
    }
}

// category: Components
// status: good
