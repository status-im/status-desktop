import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

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

    padding: 4

    contentItem: RowLayout {
        spacing: Theme.padding

        StatusRoundIcon {
            asset.name: root.icon
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            StatusBaseText {
                Layout.fillWidth: true
                text: root.title
                visible: !!text
                color: Theme.palette.directColor1
                elide: Text.ElideRight
            }

            StatusBaseText {
                Layout.fillWidth: true
                text: root.subTitle
                visible: !!text
                color: Theme.palette.baseColor1
                lineHeight: 1.2
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
            }
        }

        StatusSwitch {
            id: switchItem
            objectName: "switchItem"
            padding: 0

            onToggled: root.toggled()
        }
    }
}
