import QtQuick 2.14
import QtQuick.Layouts 1.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1

ColumnLayout {
    id: root

    property string tags
    property string selectedTags

    signal pick()

    onSelectedTagsChanged: {
        const obj = JSON.parse(tags);
        const array = selectedTags.length ? JSON.parse(selectedTags) : [];

        d.tagsModel.clear();
        for (const key of Object.keys(obj)) {
            if (array.indexOf(key) != -1) {
                d.tagsModel.append({ name: key, emoji: obj[key], selected: false });
            }
        }
    }

    implicitHeight: childrenRect.height
    spacing: 8

    QtObject {
        id: d

        property ListModel tagsModel: ListModel {}
    }

    StatusBaseText {
        text: qsTr("Tags")
        font.pixelSize: 15
        color: Theme.palette.directColor1
    }

    StatusPickerButton {
        bgColor: root.selectedTags == "" ? Theme.palette.baseColor2 : "transparent"
        text: root.selectedTags == "" ? qsTr("Choose tags describing the community") : ""
        onClicked: root.pick()
        Layout.fillWidth: true

        StatusCommunityTags {
            anchors.centerIn: parent
            model: d.tagsModel
            active: false
            width: parent.width
        }
    }
}
