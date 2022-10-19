import QtQuick 2.14

import Storybook 1.0

QtObject {
    id: root

    property string source
    property bool rethrowErrors: true
    readonly property alias component: d.component
    readonly property alias errors: d.errors // QQmlError

    onSourceChanged: d.createComponent()

    readonly property Connections _d: Connections {
        id: d

        target: SourceWatcher

        property Component component
        property var errors: null

        function createComponent() {
            if (component) {
                component.destroy()
                component = null
            }

            try {
                component = Qt.createQmlObject(root.source,
                    this,
                    "HotComponentFromSource_dynamicSnippet"
                )
                d.errors = null
            } catch (e) {
                d.errors = e

                if (root.rethrowErrors)
                    throw e
            }
        }

        function onChanged() {
            CacheCleaner.clearComponentCache()
            createComponent()
        }
    }

    Component.onCompleted: {
        if (root.source)
            d.createComponent()
    }
}
