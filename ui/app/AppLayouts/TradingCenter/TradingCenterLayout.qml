import QtQuick 2.13
import QtQuick.Layouts 1.15

import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Layout 0.1
import StatusQ.Controls 0.1

StatusSectionLayout {
    id: root

    signal launchSwap()

    centerPanel: ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 64

        spacing: 18

        RowLayout {
            Layout.alignment: Qt.AlignTop
            StatusBaseText {
                text: qsTr("Trading")
                font.weight: Font.Bold
                font.pixelSize: 28
                color: Theme.palette.directColor1
            }
            Item { Layout.fillWidth: true }
            StatusButton {
                Layout.rightMargin: 64
                text: qsTr("Swap")
                icon.name: "swap"
                type: StatusBaseButton.Type.Primary
                onClicked: root.launchSwap()
            }
        }
    }
}
