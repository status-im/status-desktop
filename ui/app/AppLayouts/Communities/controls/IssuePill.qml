import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

Control {
    id: root

    enum Type {
        Warning,
        Error,
        Primary
    }
    property int type: IssuePill.Type.Warning

    property int count
    property string text: {
        switch(type) {
        case IssuePill.Type.Warning:
            return qsTr("%n warning(s)", "", root.count)
        case IssuePill.Type.Error:
            return qsTr("%n error(s)", "", root.count)
        case IssuePill.Type.Primary:
        default:
            return qsTr("%n message(s)", "", root.count)
        }
    }

    property alias bgCornerRadius: background.radius
    property string icon: "warning"

    font.family: Fonts.baseFont.family
    font.pixelSize: Theme.tertiaryTextFontSize

    horizontalPadding: 8
    verticalPadding: 4

    readonly property color baseColor: {
        switch(type) {
        case IssuePill.Type.Warning:
            return Theme.palette.pinColor1
        case IssuePill.Type.Error:
            return Theme.palette.dangerColor1
        case IssuePill.Type.Primary:
        default:
            return Theme.palette.primaryColor1
        }
    }

    property Component iconLoaderComponent: Component {
        StatusIcon {
            width: 20
            height: 20
            icon: root.icon
            color: root.baseColor
        }
    }

    background: Rectangle {
        id: background
        radius: 100
        color: StatusColors.alphaColor(root.baseColor, 0.03)
        border.width: 1
        border.color: StatusColors.alphaColor(root.baseColor, 0.3)
    }

    contentItem: RowLayout {
        spacing: 4
        Loader {
            sourceComponent: root.iconLoaderComponent
        }
        StatusBaseText {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            verticalAlignment: Qt.AlignVCenter
            text: root.text
            font.family: root.font.family
            font.pixelSize: root.font.pixelSize
            color: root.baseColor
            wrapMode: Text.WordWrap
            maximumLineCount: 3
            elide: Text.ElideRight
        }
    }
}
