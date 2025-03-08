import QtQuick 2.15
import QtMultimedia 5.14

Item {
    id: root

    readonly property int playingState: Audio.PlayingState
    readonly property int stoppedState: Audio.StoppedState
    readonly property int pausedState: Audio.PausedState

    readonly property int logarithmicVolumeScale: QtMultimedia.LogarithmicVolumeScale
    readonly property int linearVolumeScale: QtMultimedia.LinearVolumeScale

    readonly property int playbackState: audio.playbackState

    property alias muted: audio.muted
    property alias volume: audio.volume
    property alias source: audio.source

    property int duration: audio.duration
    property int position: audio.position
    property int notifyInterval: audio.notifyInterval
    property int error: audio.error
    property string errorString: audio.errorString

    // Only possible to set up as Notification or Unknown audio role.
    property bool isNotification: true

    function play() {
        audio.play()
    }

    function pause() {
        audio.pause()
    }

    function stop() {
        audio.stop()
    }

    function seek(offset) {
        audio.seek(offset)
    }

    function convertVolume(volume, fromScale, toScale) {
        return QtMultimedia.convertVolume(volume, fromScale, toScale)
    }

    Audio {
        id: audio

        audioRole: root.isNotification ? Audio.NotificationRole : Audio.UnknownRole
    }
}
