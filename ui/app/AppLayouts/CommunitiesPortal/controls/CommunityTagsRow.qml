import QtQuick 2.14
import QtQuick.Layouts 1.14

import utils 1.0
import shared.panels 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1

Item {
    id: root

    property string tags

    onTagsChanged: {
        var obj = JSON.parse(tags);

        d.tagsModel.clear();
        for (const key of Object.keys(obj)) {
            d.tagsModel.append({ name: key, emoji: obj[key], selected: false });
        }
    }

    QtObject {
        id: d

        property ListModel tagsModel: ListModel {}
    }

    implicitHeight: tagsFlow.height
    clip: true

    StatusScrollView {
        id: scroll
        anchors.fill: parent
        padding: 0
        contentWidth: tagsFlow.width

        StatusScrollBar.horizontal.policy: StatusScrollBar.AlwaysOff

        StatusCommunityTags {
            id: tagsFlow
            model: d.tagsModel
        }
    }

    CommunityTagsRowButton {
        anchors.left: parent.left
        height: parent.height
        visible: scroll.contentX > 0
        onClicked: scroll.flick(scroll.width, 0)
    }

    CommunityTagsRowButton {
        anchors.right: parent.right
        height: parent.height
        visible: scroll.contentX + scroll.width < scroll.contentWidth
        mirrored: true
        onClicked: scroll.flick(-scroll.width, 0)
    }
}
