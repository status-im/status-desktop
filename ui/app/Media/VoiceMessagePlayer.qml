import QtQuick 2.0
import QtWebEngine 1.10
import QtWebChannel 1.0

WebEngineView {
    id: root
    property alias playback: playbackContext
    property alias audioSrc: playbackContext.audioSrc
    property color waveColor
    property color progressColor

    url: "qrc:/app/Media/web/playback.html"
    settings.playbackRequiresUserGesture: false
    onLoadingChanged: {
        if (loadRequest.errorString) {
            console.error(loadRequest.errorString)
        }
    }
    onJavaScriptConsoleMessage: {
        console.log("JavaScript: (" + sourceID + ":" + lineNumber + ") " + message)
    }
    onFeaturePermissionRequested: {
        grantFeaturePermission(securityOrigin, feature, true)
    }
    onContextMenuRequested: {
        request.accepted = true
    }
    webChannel: WebChannel {
        registeredObjects: [
            QtObject {
                id: playbackContext
                WebChannel.id: "playbackContext"

                property real volume: appSettings.volume
                property string audioSrc: ""
                property color backgroundColor: root.backgroundColor
                property color waveColor: root.waveColor
                property color progressColor: root.progressColor
                property real position: 0
                property bool playing: false
                property string error: ""

                signal play()
                signal pause()
            }
        ]
    }
}
