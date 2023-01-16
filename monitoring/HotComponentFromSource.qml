import QtQuick 2.14

QtObject {
    id: root

    property string source
    property bool rethrowErrors: true
    readonly property alias component: d.component
    readonly property alias errors: d.errors // QQmlError

    onSourceChanged: d.createComponent()

    readonly property QtObject _d: QtObject {
        id: d

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
    }

    Component.onCompleted: {
        if (root.source)
            d.createComponent()
    }
}
