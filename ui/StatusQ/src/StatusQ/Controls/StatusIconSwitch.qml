import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

Control {
    id: root

    property string title
    property string subTitle
    property string icon
    property alias checked: switchItem.checked

    signal toggled

    contentItem: RowLayout {
        spacing: 16

        StatusRoundIcon {
            asset.name: root.icon
        }

        ColumnLayout {
            Layout.fillWidth: true

            StatusBaseText {
                text: root.title
                color: Theme.palette.directColor1
                font.pixelSize: 15
            }

            Item { Layout.fillWidth: true }

            StatusBaseText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.subTitle
                visible: !!text
                color: Theme.palette.baseColor1
                font.pixelSize: 15
                lineHeight: 1.2
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
            }
        }

        StatusSwitch {
            id: switchItem

            onToggled: root.toggled()
        }
    }
}
