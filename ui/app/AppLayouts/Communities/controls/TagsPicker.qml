import QtQuick
import QtQuick.Layouts

import utils

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Popups
import StatusQ.Controls

ColumnLayout {
    id: root

    property string tags
    property string selectedTags

    readonly property bool hasSelectedTags: localAppSettings.testEnvironment || selectedTags !== ""

    signal pick()

    spacing: 8

    onSelectedTagsChanged: d.handleSelectedTags()
    Component.onCompleted: d.handleSelectedTags()

    function validate() {
        pickerButton.isError = !hasSelectedTags
    }

    QtObject {
        id: d

        property ListModel tagsModel: ListModel {}
        function handleSelectedTags() {
            const obj = JSON.parse(tags);
            const array = selectedTags.length ? JSON.parse(selectedTags) : [];

            d.tagsModel.clear();
            for (const key of Object.keys(obj)) {
                if (array.indexOf(key) !== -1) {
                    d.tagsModel.append({ name: key, emoji: obj[key], selected: false });
                }
            }
        }
    }

    StatusBaseText {
        text: qsTr("Tags")
        color: Theme.palette.directColor1
    }

    StatusPickerButton {
        id: pickerButton
        bgColor: d.tagsModel.count === 0 ? Theme.palette.baseColor2 : "transparent"
        text: d.tagsModel.count === 0 ? qsTr("Choose tags describing the community") : ""
        onClicked: root.pick()
        font.weight: Font.Normal
        icon.width: 24
        icon.height: 24
        Layout.fillWidth: true
        Layout.preferredHeight: 44

        StatusCommunityTags {
            anchors.verticalCenter: parent.verticalCenter
            model: d.tagsModel
            active: false
            width: parent.width
            contentWidth: width
        }
    }

    StatusBaseText {
        Layout.fillWidth: true
        visible: pickerButton.isError
        text: qsTr("Add at least 1 tag")
        font.pixelSize: Theme.tertiaryTextFontSize
        color: Theme.palette.dangerColor1
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignRight
    }
}
