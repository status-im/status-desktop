import QtQml 2.14

QtObject {
    property alias model: d.target

    readonly property alias revision: d.revision

    function reset() {
        d.revision = 0
    }

    readonly property Connections _d: Connections {
        id: d

        property int revision: 0

        function onRowsInserted() {
            revision++
        }

        function onRowsMoved() {
            revision++
        }

        function onRowsRemoved() {
            revision++
        }

        function onLayoutChanged() {
            revision++
        }

        function onModelReset() {
            revision++
        }

        function onDataChanged() {
            revision++
        }
    }
}
