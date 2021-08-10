import QtQuick 2.0
import QtWebEngine 1.10

WebEngineView {
    id: root
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
}
