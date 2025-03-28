import QtQuick 2.15
import QtMultimedia 5.15

Item {
    id: root

    property alias muted: audio.muted
    property alias volume: audio.volume
    property alias source: audio.source

    readonly property bool playing: audio.playbackState === Audio.PlayingState
    readonly property bool isError: audio.error !== Audio.NoError
    readonly property string statusString: audio.errorString

    function play() {
        audio.play()
    }

    function stop() {
        audio.stop()
    }

    function convertVolume(volume) {
        return QtMultimedia.convertVolume(volume,
                                          QtMultimedia.LogarithmicVolumeScale,
                                          QtMultimedia.LinearVolumeScale)
    }

    Audio {
        id: audio

        audioRole: Audio.NotificationRole
    }
}
