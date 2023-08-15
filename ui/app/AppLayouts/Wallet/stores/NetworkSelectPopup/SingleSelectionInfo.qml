import QtQml 2.15

/// Inline component was failing on Linux with "Cannot assign to property of unknown type" so we need to use a separate file for it.
QtObject {
    property bool enabled: false
    property var currentModel: root.layer2Networks
    property int currentIndex: 0
}
