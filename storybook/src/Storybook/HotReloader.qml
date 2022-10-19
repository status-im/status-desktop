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
        CacheCleaner.clearComponentCache()
        d.asyncBlocker.when = false
        d.sourceBlocker.when = false

        reloaded()
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
