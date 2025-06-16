import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

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
        color: Theme.palette.transparent
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
