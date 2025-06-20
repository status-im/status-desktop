import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import shared.controls 1.0
import utils 1.0

StatusScrollView {
    id: root

    property string tags
    property string selectedTags
    property int maxSelectedTags: 3

    property string title: qsTr("Community Tags")

    property var rightButtons: StatusButton {
        objectName: "confirmCommunityTagsButton"
        text: qsTr("Confirm Community Tags")
        enabled: d.countSelectedTags > 0
        onClicked: {
            var selectedTags = [];
            for (let i = 0; i < d.tagsModel.count; ++i) {
                let item = d.tagsModel.get(i);
                if (item.selected)
                    selectedTags.push(item.name);
            }
            root.accepted(selectedTags.length ? JSON.stringify(selectedTags) : "");
        }
    }

    signal accepted(string selectedTags)

    function updateSelectedTags() {
        var array = selectedTags.length ? JSON.parse(selectedTags) : [];

        d.countSelectedTags = 0;
        for (let i = 0; i < d.tagsModel.count; ++i) {
            let item = d.tagsModel.get(i);
            if (array.indexOf(item.name) !== -1) {
                item.selected = true;
                d.countSelectedTags++;
            } else {
                item.selected = false;
            }
            d.tagsModel.set(i, item);
        }
    }

    onTagsChanged: {
        var obj = JSON.parse(tags);

        d.countSelectedTags = 0;
        d.tagsModel.clear();
        for (const key of Object.keys(obj)) {
            d.tagsModel.append({ name: key, emoji: obj[key], selected: false });
        }
    }
    onSelectedTagsChanged: updateSelectedTags()

    contentWidth: availableWidth
    padding: 0
    clip: false

    QtObject {
        id: d

        property int countSelectedTags: 0
        property ListModel tagsModel: ListModel {}
    }

    ColumnLayout {
        id: column
        width: root.availableWidth
        spacing: Theme.padding

        StatusInput {
            id: tagsFilter
            label: qsTr("Select tags that will fit your Community")
            labelPadding: Theme.bigPadding
            input.asset.name: "search"
            placeholderText: qsTr("Search tags")
            Layout.fillWidth: true
        }

        ColumnLayout {
            Layout.topMargin: Theme.padding
            Layout.bottomMargin: Theme.padding

            StatusCommunityTags {
                filterString: tagsFilter.text
                model: d.tagsModel
                enabled: d.countSelectedTags < maxSelectedTags
                onClicked: (item) => {
                    d.countSelectedTags++;
                    item.selected = true;
                }
                Layout.fillWidth: true
            }
        }

        StatusModalDivider {
            Layout.fillWidth: true
        }

        RowLayout {
            StatusBaseText {
                text: qsTr("Selected tags")
                Layout.fillWidth: true
            }

            StatusBaseText {
                text: qsTr("%1 / %2").arg(d.countSelectedTags).arg(maxSelectedTags)
                color: Theme.palette.baseColor1
                font.pixelSize: Theme.additionalTextSize
            }
        }

        StatusCommunityTags {
            model: d.tagsModel
            mode: StatusCommunityTags.ShowSelectedOnly
            onClicked: {
                d.countSelectedTags--;
                item.selected = false;
            }
            Layout.fillWidth: true
            Layout.bottomMargin: Theme.padding
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.bottomMargin: Theme.padding
            text: qsTr("No tags selected yet")
            color: Theme.palette.baseColor1
            visible: d.countSelectedTags === 0
            font.pixelSize: Theme.additionalTextSize
            horizontalAlignment: Qt.AlignHCenter
        }
    }
}
