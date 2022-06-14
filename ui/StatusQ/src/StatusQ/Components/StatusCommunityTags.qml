import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

Item {
    id: root

    property string filterString
    property bool showOnlySelected: false
    property bool active: true

    property alias model: repeater.model
    property alias contentWidth: flow.width

    signal clicked(var item)

    implicitWidth: flow.implicitWidth
    implicitHeight: flow.implicitHeight

    Flow {
        id: flow
        anchors.centerIn: parent
        width: {
            let itemsWidth = 0;
            for (let i = 0; i < repeater.count; ++i) {
                itemsWidth += spacing + repeater.itemAt(i).width;
            }
            return Math.min(parent.width, itemsWidth);
        }
        spacing: 10

        Repeater {
            id: repeater

            delegate: StatusCommunityTag {
                emoji: model.emoji
                name: model.name
                visible: (root.showOnlySelected ? model.selected : !model.selected) &&
                         (filterString == 0 || name.toUpperCase().indexOf(filterString.toUpperCase()) !== -1)
                width: visible ? implicitWidth : -10
                height: visible ? implicitHeight : 0
                removable: root.showOnlySelected && root.active
                onClicked: root.clicked(model)
            }
        }
    }
}