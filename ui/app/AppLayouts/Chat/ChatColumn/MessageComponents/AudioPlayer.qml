import QtQuick 2.3
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.13
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import "../../../../Media"
import "../../../../../imports"


Rectangle {
    id: root
    property string audioSource: ""

    width: 320
    height: 32
    radius: 20
    color: Theme.palette.baseColor2

    StatusBaseText {
        visible: !!player.playback.error
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: Theme.palette.dangerColor1
        font.weight: Font.DemiBold
        font.pixelSize: 13
        text: qsTr("Unsupported audio format")
    }

    RowLayout {
        visible: !player.playback.error
        anchors.fill: parent
        anchors.leftMargin: Style.current.halfPadding / 2
        anchors.rightMargin: Style.current.halfPadding
        spacing: Style.current.halfPadding / 2

        StatusFlatRoundButton {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            Layout.alignment: Qt.AlignVCenter
            radius: 12
            icon.name: player.playback.playing ? "pause" : "play"
            icon.color: Theme.palette.directColor1
            icon.width: 18
            icon.height: 18
            onClicked: {
                if (player.playback.playing) {
                    player.playback.pause()
                } else {
                    player.playback.play()
                }
            }
        }

        VoiceMessagePlayer {
            id: player
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: 32
            Layout.preferredWidth: 240
            backgroundColor: root.color
            waveColor: Theme.palette.baseColor1
            progressColor: Theme.palette.directColor1
            audioSrc: root.audioSource
        }

        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            text: formatDuration(player.playback.position)
            font.weight: Font.DemiBold
            font.pixelSize: 13
            color: Theme.palette.directColor1

            function formatDuration(sec) {
                let t = new Date(1970, 0, 1); // Epoch
                t.setSeconds(sec)
                return Qt.formatTime(t, sec >= 3600 ? "h:mm:ss" : "m:ss")
            }
        }
    }
}
