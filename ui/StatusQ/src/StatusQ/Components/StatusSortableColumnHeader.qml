import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

ItemDelegate {
    id: root

    enum Sorting {
        NoSorting, Descending, Ascending
    }

    property int sorting: StatusSortableColumnHeader.Sorting.NoSorting

    property var traversalOrder: [
        StatusSortableColumnHeader.Sorting.NoSorting,
        StatusSortableColumnHeader.Sorting.Descending,
        StatusSortableColumnHeader.Sorting.Ascending
    ]

    function reset() {
        sorting = traversalOrder[0]
    }

    component TickIcon: StatusIcon {
        color: Theme.palette.baseColor1
        width: 8
        height: 5
    }

    states: [
        State {
            when: root.sorting === StatusSortableColumnHeader.Sorting.NoSorting
        },
        State {
            when: root.sorting === StatusSortableColumnHeader.Sorting.Descending

            PropertyChanges {
                target: label
                color: Theme.palette.directColor1
            }

            PropertyChanges {
                target: tickDown

                color: Theme.palette.miscColor1
            }
        },
        State {
            when: root.sorting === StatusSortableColumnHeader.Sorting.Ascending

            PropertyChanges {
                target: label
                color: Theme.palette.directColor1
            }

            PropertyChanges {
                target: tickUp

                color: Theme.palette.miscColor1
            }
        }
    ]

    QtObject {
        id: internal

        function setNextSortingMode() {
            const currentIdx = root.traversalOrder.indexOf(root.sorting)
            const nextIdx = (currentIdx + 1) % root.traversalOrder.length

            sorting = traversalOrder[nextIdx]
        }
    }

    background: null

    onClicked: {
        internal.setNextSortingMode()
    }

    contentItem: RowLayout {
        spacing: 9

        StatusBaseText {
            id: label

            elide: Qt.ElideRight
            font.weight: Font.Medium

            font.pixelSize: 13
            color: Theme.palette.baseColor1
            text: root.text
        }

        Column {
            spacing: 2

            TickIcon {
                id: tickUp

                icon: "tiny/tick-up"
            }

            TickIcon {
                id: tickDown

                icon: "tiny/tick-down"
            }
        }
    }
}
