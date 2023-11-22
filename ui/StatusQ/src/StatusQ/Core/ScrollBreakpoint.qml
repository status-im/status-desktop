import QtQuick 2.15

QtObject {
    id: root

    // The target object to watch for scrolling breakpoints
    required property Flickable target

    // The condition for the breakpoint to be hit
    property var condition: () => false

    // enabled property will toggle the breakpoint on and off
    property bool enabled: true

    // checkOnEnabled will check the condition when enabled is set to true
    property bool checkOnEnabled: false

    // The waitFor property allows you to wait for another event before checking the condition
    property ScrollBreakpoint waitFor: null

    // This signal is emitted when the condition is met
    signal hit()

    property Connections flickableConnections: Connections {
        target: root.target
        enabled: _d.enabled && _d.active
        function onContentYChanged() {
            Qt.callLater(() => _d.check())
        }

        function onOriginYChanged() {
            Qt.callLater(() => _d.check())
        }

        function onContentHeightChanged() {
            Qt.callLater(() => _d.check())
        }
    }

    // Wait for another event before checking the condition
    property Connections waitForConnections: Connections {
        id: _waitForConnections
        target: root.waitFor
        enabled: _d.enabled && !!root.waitFor && !_d.active
        function onHit() {
            _d.active = true
        }
    }

    property QtObject d: QtObject {
        id: _d

        property bool enabled: root.enabled && !!root.target
        property bool active: !root.waitFor

       onEnabledChanged: {
           if(enabled && root.checkOnEnabled)
               Qt.callLater(() => _d.check())
       }

        function check() {
            if(!root.enabled || !root.condition())
                return

            root.hit()
            if(root.waitFor)
                _d.active = false
        }
    }
}
