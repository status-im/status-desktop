import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import Sandbox 0.1

import "../demoapp/data" 1.0

Item {

    property int cntSelectedTags: 0
    property int maxSelectedTags: 4
    property ListModel tagsModel: ListModel {}

    Component.onCompleted: {
        tagsModel.clear();
        for (const key of Object.keys(Models.communityTags)) {
            tagsModel.append({ name: key, emoji: Models.communityTags[key], selected: false });
        }
    }

    ColumnLayout {
        id: column
        anchors.centerIn: parent
        width: 600
        height: 500
        spacing: 20

        StatusInput {
            id: tagsFilter
            leftPadding: 0
            rightPadding: 0
            label: qsTr("Select tags that will fit your Community")
            input.icon.name: "search"
            placeholderText: qsTr("Search tags")
            Layout.fillWidth: true
        }

        StatusCommunityTags {
            filterString: tagsFilter.text
            model: tagsModel
            enabled: cntSelectedTags < maxSelectedTags
            onClicked: {
                cntSelectedTags++;
                item.selected = true;
            }
            Layout.fillWidth: true
        }

        RowLayout {
            StatusBaseText {
                text: qsTr("Selected tags")
                font.pixelSize: 15
                Layout.fillWidth: true
            }

            StatusBaseText {
                text: cntSelectedTags + "/" + maxSelectedTags
                color: Theme.palette.baseColor1
                font.pixelSize: 13
            }
        }

        StatusCommunityTags {
            model: tagsModel
            showOnlySelected: true
            onClicked: {
                cntSelectedTags--;
                item.selected = false;
            }
            Layout.fillWidth: true
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
