import QtQuick 2.15
import StatusQ.Controls 0.1

Item {
    id: root

    property url source: ""
    readonly property bool _useNative: Qt.platform.os === "ios" || Qt.platform.os === "android" || Qt.platform.os === "osx"
    property var _implItem: null

    Component {
        id: nativeImplComponent
        NativeIndicatorNative {
            x: root.x
            y: root.y
            width: root.width
            height: root.height
            visible: root.visible
            enabled: root.enabled
            source: root.source
        }
    }

    Component {
        id: qmlImplComponent
        NativeIndicatorImpl {
            anchors.fill: parent
            visible: root.visible
            enabled: root.enabled
            source: root.source
        }
    }

    function _destroyImpl() {
        if (_implItem) {
            _implItem.destroy()
            _implItem = null
        }
    }

    function _createImpl() {
        const component = _useNative ? nativeImplComponent : qmlImplComponent
        const p = _useNative ? root.parent : root
        if (!p) return

        // Avoid double-create during startup.
        if (_implItem && _implItem.parent === p) return

        _destroyImpl()
        _implItem = component.createObject(p)
    }

    Component.onCompleted: _createImpl()
    onParentChanged: _createImpl()
    on_UseNativeChanged: _createImpl()
    Component.onDestruction: _destroyImpl()
}


