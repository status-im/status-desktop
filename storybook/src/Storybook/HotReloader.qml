import QtQml 2.14
import QtQuick 2.14

import Storybook 1.0

QtObject {
    id: root

    /*required*/ property Loader loader
    property bool enabled: false

    signal reloaded

    function forceReload() {
        // clearing component cache right after removing
        // source from async loader causes undefined behavior
        // and app crashes on Qt 5.14.2. For that reason
        // asynchronous is set to false first and restored
        // to original value after clearing.
        d.asyncBlocker.when = true
        d.sourceBlocker.when = true

        // Starting from Qt 6.8.3 QQmlEngine::clearComponentCache works
        // differently. Components which objects are just removed are not
        // considered as eligible for removal from cache even though there is no
        // alive reference to any instance of that component. For that reason
        // QQmlEngine::clearComponentCache call must be delayed by Qt.callLater
        // to take effect. Within the function executed by Qt.callLater, the
        // QQmlEngine::clearComponentCache actually removes cached version,
        // allowing to reload the page.
        Qt.callLater(() => {
            CacheCleaner.clearComponentCache()
            d.asyncBlocker.when = false
            d.sourceBlocker.when = false

             reloaded()

             // Log to indicate the moment when the page is reloaded
             const fileName = loader.source.toString().split('/').pop();
             console.log("\n\n== Reloaded", fileName, "==")
        })
    }

    readonly property Connections _d: Connections {
        id: d

        target: SourceWatcher

        readonly property Binding asyncBlocker: Binding {
            target: root.loader
            property: "asynchronous"
            value: false
            when: false
        }

        readonly property Binding sourceBlocker: Binding {
            target: root.loader
            property: "source"
            value: ""
            when: false
        }

        function onChanged() {
            if (!root.enabled)
                return

            forceReload()
        }
    }
}
