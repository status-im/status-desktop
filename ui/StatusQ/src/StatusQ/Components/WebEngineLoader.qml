import QtQuick 2.15

import QtWebEngine 1.10
import QtWebChannel 1.15

import StatusQ 0.1

// Helper to load and setup an instance of \c WebEngineView
//
// The \c webChannelObjects property is used to register specific objects
//
// Loading qrc:/StatusQ/Components/private/qwebchannel/qwebchannel.js and
// qrc:/StatusQ/Components/private/qwebchannel/helpers.js will provide
// access to window.statusq APIs used to exchange data between the internal
// web engine and the QML application
//
// It doesn't load the web engine until NetworkChecker detects and active internet
// connection to avoid the corner case of initializing the web engine without
// network connectivity. If the web engine is initialized without network connectivity
// it won't restore the connectivity when it's available on Mac OS
Item {
    id: root

    required property url url
    required property var webChannelObjects
    property string profileName: "Default"

    // Used to control the loading of the web engine
    property bool active: false
    // Useful to monitor the loading state of the web engine (depends on active and internet connectivity)
    readonly property bool isActive: loader.active
    property alias instance: loader.item
    property bool waitForInternet: true

    signal engineLoaded(WebEngineView instance)
    signal engineUnloaded()
    signal pageLoaded()
    signal pageLoadingError(string errorString)

    Component {
        id: webEngineViewComponent

        WebEngineView {
            id: webEngineView

            anchors.fill: parent

            visible: false

            url: root.url
            webChannel: statusChannel
            profile.storageName: root.profileName

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

    Loader {
        id: loader

        active: root.active && (!root.waitForInternet || (d.passedFirstTimeInitialization || networkChecker.isOnline))

        onStatusChanged: function() {
            if (status === Loader.Ready) {
                root.engineLoaded(loader.item)
                d.passedFirstTimeInitialization = true
            } else if (status === Loader.Null) {
                root.engineUnloaded()
            }
        }

        sourceComponent: webEngineViewComponent
    }

    NetworkChecker {
        id: networkChecker

        // Deactivate searching for network connectivity after the web engine is loaded
        active: !d.passedFirstTimeInitialization
    }

    QtObject {
        id: d

        // Used to hold the loading of the web engine until internet connectivity is available
        property bool passedFirstTimeInitialization: false
    }
}