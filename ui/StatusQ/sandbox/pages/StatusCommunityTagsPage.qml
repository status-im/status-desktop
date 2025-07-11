import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components

import "../demoapp/data"

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
            input.asset.name: "search"
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
                font.pixelSize: Theme.primaryTextFontSize
                Layout.fillWidth: true
            }

            StatusBaseText {
                text: cntSelectedTags + "/" + maxSelectedTags
                color: Theme.palette.baseColor1
                font.pixelSize: Theme.additionalTextSize
            }
        }

        StatusCommunityTags {
            model: tagsModel
            mode: StatusCommunityTags.ShowSelectedOnly
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
