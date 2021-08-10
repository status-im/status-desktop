import QtQuick 2.0
import QtWebEngine 1.10
import QtWebChannel 1.0

BaseWebEngineView {
    id: root
    property alias recording: recordingContext

    url: "qrc:/app/Media/web/recording.html"

    webChannel: WebChannel {
        registeredObjects: [
            QtObject {
                id: recordingContext
                WebChannel.id: "recordingContext"

                property real micLevel: appSettings.micLevel
                property real duration

                signal stop()
                signal recorded(string data64, real duration)
                signal error(string error)

                function handleRecorded(audioBase64, duration) {
                    recorded(audioBase64, duration)
                }

                function handleError(err) {
                    error(err)
                }
            }
        ]
    }
}
