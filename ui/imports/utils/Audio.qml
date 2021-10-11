import QtQuick 2.13
import QtMultimedia 5.13

Audio {
    id: audio

    property string track: "error.mp3"
    
    source: Qt.resolvedUrl("./../assets/audio" + track)
    audioRole: Audio.NotificationRole
    volume: appSettings.volume
    muted: !appSettings.notificationSoundsEnabled
}