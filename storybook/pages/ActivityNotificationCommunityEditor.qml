import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml

import Models


ColumnLayout {
    spacing: 8
    width: parent.width

    property QtObject communityMock: QtObject {
        readonly property string name: communityName.text
        readonly property string image: communityImage.checked ? "" : ModelsData.banners.status
        readonly property string color: communityColor.checked ? "pink" : "green"
    }

    Label {
        Layout.fillWidth: true
        Layout.topMargin: 8
        text: "Community name"
        font.weight: Font.Bold
    }

    TextField {
        Layout.fillWidth: true
        id: communityName
        text: "Status CCs"
    }

    Label {
        Layout.fillWidth: true
        Layout.topMargin: 8
        text: "Community image"
        font.weight: Font.Bold
    }

    Switch {
        id: communityImage
        text: "Image or Text"
    }

    Label {
        Layout.fillWidth: true
        Layout.topMargin: 8
        text: "Community color"
        font.weight: Font.Bold
    }

    Switch {
        id: communityColor
        text: "Green or Pink"
    }
}
