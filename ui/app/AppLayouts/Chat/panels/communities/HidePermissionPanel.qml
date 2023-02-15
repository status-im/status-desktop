import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Control {
    id: root

    property alias checked: switchItem.checked

    signal toggled

    contentItem: RowLayout {
        spacing: Style.current.padding

        StatusRoundIcon {
            asset.name: "hide"
        }

        ColumnLayout {
            Layout.fillWidth: true

            StatusBaseText {
                text: qsTr("Hide permission")
                color: Theme.palette.directColor1
                font.pixelSize: Style.current.primaryTextFontSize
            }

            StatusBaseText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("Make this permission hidden from members who don’t meet its requirements")
                color: Theme.palette.baseColor1
                font.pixelSize: Style.current.primaryTextFontSize
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
