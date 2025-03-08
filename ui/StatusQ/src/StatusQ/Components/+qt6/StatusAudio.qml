import QtQuick 2.15
import QtMultimedia 6.5

Item {
    id: root

    readonly property int playingState: MediaPlayer.PlayingState
    readonly property int stoppedState: MediaPlayer.StoppedState
    readonly property int pausedState: MediaPlayer.PausedState

    readonly property int logarithmicVolumeScale: MediaPlayer.LogarithmicVolumeScale
    readonly property int linearVolumeScale: MediaPlayer.LinearVolumeScale

    readonly property int playbackState: mediaPlayer.playbackState

    property alias muted: mediaPlayer.audioOutput.muted
    property alias volume: mediaPlayer.audioOutput.volume
    property alias source: mediaPlayer.source

    property int duration: mediaPlayer.duration
    property int position: mediaPlayer.position
    // Notify interval it's no longer necessary in QT6 since the property change is propagated when it occurs.
    // Source: https://forum.qt.io/topic/139028/where-did-qmediaplayer-setnotifyinterval-go/6
    property int notifyInterval
    property int error: mediaPlayer.error
    property string errorString: mediaPlayer.errorString

    // There's no audio role in qt6.
    property bool isNotification: true // Not used, only interface to keep compatibility. Can be removed after migration to qt6.

    function play() {
        mediaPlayer.play()
    }

    function pause() {
        mediaPlayer.pause()
    }

    function stop() {
        mediaPlayer.stop()
    }

    // TO REVIEW
    function seek(offset) {
        mediaPlayer.position = offset
    }

    function convertVolume(volume, fromScale, toScale) {
        return 0.5
        // TODO
        // return QtMultimedia.convertVolume(volume, fromScale, toScale)
    }

    MediaPlayer {
        id: mediaPlayer

        audioOutput: AudioOutput {}
    }
}
