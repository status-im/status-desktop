import QtQuick 2.13
import QtMultimedia 5.15

Rectangle {
    id: root

    readonly property bool isLoading: player.playbackState !== MediaPlayer.PlayingState
    readonly property bool isError: player.status === MediaPlayer.InvalidMedia

    property alias player: player
    property alias output: output

    MediaPlayer {
        id: player
        autoPlay: true
        muted: true
        loops: MediaPlayer.Infinite
    }

    VideoOutput {
        id: output
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectFit
        source: player
    }
}
