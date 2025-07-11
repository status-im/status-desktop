import QtQuick

Loader {
    sourceComponent: hotComponent.component

    property alias source: hotComponent.source
    property alias rethrowErrors: hotComponent.rethrowErrors
    readonly property alias errors: hotComponent.errors

    HotComponentFromSource {
        id: hotComponent
    }
}
