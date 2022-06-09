import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0

StatusModal {
    id: root

    property string tags
    property string selectedTags
    property int maxSelectedTags: 4

    signal accepted(string selectedTags)

    function updateSelectedTags() {
        var array = selectedTags.length ? JSON.parse(selectedTags) : [];

        d.cntSelectedTags = 0;
        for (let i = 0; i < d.tagsModel.count; ++i) {
            let item = d.tagsModel.get(i);
            if (array.indexOf(item.name) != -1) {
                item.selected = true;
                d.cntSelectedTags++;
            } else {
                item.selected = false;
            }
            d.tagsModel.set(i, item);
        }
    }

    onTagsChanged: {
        var obj = JSON.parse(tags);

        d.cntSelectedTags = 0;
        d.tagsModel.clear();
        for (const key of Object.keys(obj)) {
            d.tagsModel.append({ name: key, emoji: obj[key], selected: false });
        }
    }
    onSelectedTagsChanged: updateSelectedTags()

    width: 680
    implicitHeight: 820

    header.title: qsTr("Community Tags")

    QtObject {
        id: d

        property int cntSelectedTags: 0
        property ListModel tagsModel: ListModel {}
    }

    rightButtons: [
        StatusButton {
            text: qsTr("Confirm Community Tags")
            onClicked: {
                var selectedTags = [];
                for (let i = 0; i < d.tagsModel.count; ++i) {
                    let item = d.tagsModel.get(i);
                    if (item.selected)
                        selectedTags.push(item.name);
                }
                root.accepted(selectedTags.length ? JSON.stringify(selectedTags) : "");
                root.close();
            }
        }
    ]

    leftButtons: [
        StatusRoundButton {
            id: btnBack
            icon.name: "arrow-left"
            icon.width: 20
            icon.height: 16
            onClicked: {
                root.updateSelectedTags();
                root.close();
            }
        }
    ]

    contentItem: ScrollView {
        id: scroll
        width: parent.width
        topPadding: 30
        leftPadding: 20
        rightPadding: 20
        bottomPadding: 20
        contentHeight: column.height

        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        clip: true

        ColumnLayout {
            id: column
            width: scroll.width - scroll.leftPadding - scroll.rightPadding
            spacing: 20

            StatusInput {
                id: tagsFilter
                leftPadding: 0
                rightPadding: 0
                label: qsTr("Select tags that will fit your Community")
                input.icon.name: "search"
                input.placeholderText: qsTr("Search tags")
                Layout.fillWidth: true
            }

            StatusCommunityTags {
                filterString: tagsFilter.text
                model: d.tagsModel
                enabled: d.cntSelectedTags < maxSelectedTags
                onClicked: {
                    d.cntSelectedTags++;
                    item.selected = true;
                }
                Layout.fillWidth: true
            }

            StatusModalDivider {
                Layout.fillWidth: true
            }

            RowLayout {
                StatusBaseText {
                    text: qsTr("Selected tags")
                    font.pixelSize: 15
                    Layout.fillWidth: true
                }

                StatusBaseText {
                    text: d.cntSelectedTags + "/" + maxSelectedTags
                    color: Theme.palette.baseColor1
                    font.pixelSize: 13
                }
            }

            StatusCommunityTags {
                model: d.tagsModel
                showOnlySelected: true
                onClicked: {
                    d.cntSelectedTags--;
                    item.selected = false;
                }
                Layout.fillWidth: true
            }
        }
    }
}