import QtQml
import QtQuick

import Storybook

QtObject {
    id: root

    property bool enabled
    property bool reloading

    signal reloaded

    function forceReload() {
        reloading = true
        CacheCleaner.clearComponentCache()
        reloading = false
        reloaded()
    }

    readonly property Connections _d: Connections {
        target: SourceWatcher
        enabled: root.enabled

        function onChanged() {
            forceReload()
        }
    }
}
