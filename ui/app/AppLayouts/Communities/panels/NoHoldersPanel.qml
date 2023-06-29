import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Control {
    id: root

    signal airdropRequested

    verticalPadding: 40
    horizontalPadding: 56

    background: Rectangle {
        color: Theme.palette.statusListItem.backgroundColor
        radius: Style.current.radius
        border.color: Theme.palette.baseColor2
    }

    contentItem: ColumnLayout {
        StatusBaseText {
            Layout.fillWidth: true

            wrapMode: Text.Wrap
            font.pixelSize: Style.current.primaryTextFontSize + 2
            font.weight: Font.Bold

            horizontalAlignment: Text.AlignHCenter
            color: Theme.palette.directColor1
            text: qsTr("No hodlers just yet")
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.topMargin: Style.current.halfPadding
            Layout.bottomMargin: Style.current.padding

            wrapMode: Text.Wrap
            font.pixelSize: Style.current.primaryTextFontSize

            horizontalAlignment: Text.AlignHCenter
            color: Theme.palette.baseColor1
            text: qsTr("You can Airdrop tokens to deserving Community members or to give individuals token-based permissions.")
        }

        StatusButton {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Airdrop")

            onClicked: root.airdropRequested()
        }
    }
}
