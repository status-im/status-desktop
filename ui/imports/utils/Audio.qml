import QtQuick 2.14
import QtMultimedia 5.14 as T

T.Audio {
    id: audio

    property var store

    audioRole: Audio.NotificationRole
    volume: store.volume
    muted: !store.notificationSoundsEnabled
    onError: console.warn("Audio error:", errorString, "; code:", error)
}
