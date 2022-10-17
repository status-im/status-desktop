import QtQuick 2.14
import QtQuick.Layouts 1.14

import utils 1.0
import shared.panels 1.0

import StatusQ.Core 0.1
import StatusQ.Components 0.1

StatusRollArea {
    id: root

    property string tags
    property var selectedTagsNames: []

    onTagsChanged: {
        var obj = JSON.parse(tags);

        d.tagsModel.clear();
        for (const key of Object.keys(obj)) {
            d.tagsModel.append({ name: key, emoji: obj[key], selected: false });
        }

        d.evaluateSelectedTags()
    }

    QtObject {
        id: d

        property ListModel tagsModel: ListModel {}

        function evaluateSelectedTags() {
            let selectedTagsNames = []
            for(let i = 0; i < tagsModel.count; i++) {
                let tag = tagsModel.get(i)
                if (tag.selected) selectedTagsNames.push(tag.name)
            }
            root.selectedTagsNames = selectedTagsNames
        }
    }

    content: StatusCommunityTags {
        id: tagsFlow
        model: d.tagsModel
        mode: StatusCommunityTags.Highlight

        onClicked: {
            item.selected = !item.selected
            d.evaluateSelectedTags()
        }
    }
}
