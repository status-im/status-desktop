import QtQuick 2.15

import QtWebEngine 1.10
import QtWebChannel 1.15

// Helper to load and setup an instance of \c WebEngineView
//
// The \c webChannelObjects property is used to register specific objects
//
// Loading qrc:/StatusQ/Components/private/qwebchannel/qwebchannel.js and
// qrc:/StatusQ/Components/private/qwebchannel/helpers.js will provide
// access to window.statusq APIs used to exchange data between the internal
// web engine and the QML application
Item {
    id: root

    required property url url
    required property var webChannelObjects

    property alias active: loader.active
    property alias instance: loader.item

    signal engineLoaded(WebEngineView instance)
    signal engineUnloaded()
    signal pageLoaded()
    signal pageLoadingError(string errorString)

    Loader {
        id: loader

        active: false

        onStatusChanged: function() {
            if (status === Loader.Ready) {
                root.engineLoaded(loader.item)
            } else if (status === Loader.Null) {
                root.engineUnloaded()
            }
        }

        sourceComponent: WebEngineView {
            id: webEngineView

            anchors.fill: parent

            visible: false

            url: root.url
            webChannel: statusChannel

            onLoadingChanged: function(loadRequest) {
                switch(loadRequest.status) {
                case WebEngineView.LoadSucceededStatus:
                    root.pageLoaded()
                    break
                case WebEngineView.LoadFailedStatus:
                    root.pageLoadingError(loadRequest.errorString)
                    break
                }
            }

            WebChannel {
                id: statusChannel
                registeredObjects: root.webChannelObjects
            }
        }
    }
}