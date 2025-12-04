import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme

import utils

Control {
    id: root

    property alias primaryText: primaryText.text
    property alias primaryLabel: primaryText
    property alias content: content.sourceComponent

    padding: 12

    background: Rectangle {
        radius: Theme.radius
        border.width: 1
        border.color: Theme.palette.baseColor2
        color: StatusColors.transparent
    }

    contentItem: ColumnLayout {
        spacing: 4
        StatusBaseText {
            id: primaryText
            Layout.fillWidth: true
            font.pixelSize: Theme.additionalTextSize
            lineHeight: 18
            lineHeightMode: Text.FixedHeight
            color: Theme.palette.directColor5
            visible: text
            elide: Text.ElideRight
        }
        Loader {
            id: content
        }
    }
}
