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

    readonly property int itemsWidth: {
        let result = 0;
        for (let i = 0; i < repeater.count; ++i) {
            result +=  flow.spacing + repeater.itemAt(i).width;
        }
        return result;
    }

    signal clicked(var item)

    implicitWidth: itemsWidth
    implicitHeight: flow.height

    Flow {
        id: flow
        anchors.centerIn: parent
        width: Math.min(parent.width, root.itemsWidth);
        spacing: 10

        Repeater {
            id: repeater

            delegate: StatusCommunityTag {
                emoji: model.emoji
                name: model.name
                visible: (root.showOnlySelected ? model.selected : !model.selected) &&
                         (filterString == 0 || name.toUpperCase().indexOf(filterString.toUpperCase()) !== -1)
                width: visible ? implicitWidth : -flow.spacing
                height: visible ? implicitHeight : 0
                removable: root.showOnlySelected && root.active
                onClicked: root.clicked(model)
            }
        }
    }
}