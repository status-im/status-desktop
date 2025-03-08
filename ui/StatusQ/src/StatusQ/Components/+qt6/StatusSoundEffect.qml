import QtQuick 2.15
import QtMultimedia 6.5

import StatusQ 1.0

Item {
    id: root

    property alias muted: soundEffect.muted
    property alias volume: soundEffect.volume
    property alias source: soundEffect.source
    property alias playing: soundEffect.playing

    readonly property bool isError: soundEffect.status === soundEffect.Error
    readonly property string statusString: soundEffect.status

    function play() {
        soundEffect.play()
    }

    function stop() {
        soundEffect.stop()
    }

    function convertVolume(volume) {
        return AudioUtils.convertLogarithmicToLinearVolumeScale(volume);
    }

    SoundEffect {
        id: soundEffect
    }
}
