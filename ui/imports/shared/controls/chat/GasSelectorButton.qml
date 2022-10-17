import QtQuick 2.13
import QtQuick.Layouts 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusRadioButton {
    id: gasRectangle

    property string primaryText
    property string timeText
    property string totalGasFiatValue
    property double totalGasEthValue

    width: contentItem.implicitWidth

    // To-do Use StatusCard instead. It crashes if I use StatusCard and
    // already spent 2 days on this, so leaving it out for now
    contentItem: Rectangle {
        id: card

        implicitHeight: 76
        implicitWidth: 128

        radius: 8
        color: gasRectangle.checked || mouseArea.containsMouse ? "transparent": Theme.palette.baseColor4
        border.color: gasRectangle.checked || mouseArea.containsMouse ? Theme.palette.primaryColor2: Theme.palette.baseColor4

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.topMargin: 8
            StatusBaseText {
                id: primaryText
                font.pixelSize: 15
                font.weight: Font.Medium
                elide: Text.ElideRight
                text: gasRectangle.primaryText
                color: Theme.palette.directColor1
            }
            StatusBaseText {
                id: secondaryLabel
                Layout.maximumWidth: card.width - Style.current.smallPadding
                font.pixelSize: 13
                font.weight: Font.Medium
                text: gasRectangle.totalGasFiatValue
                color: Theme.palette.primaryColor1
                elide: Text.ElideRight
            }
            StatusBaseText {
                id: tertiaryText
                font.pixelSize: 10
                text: gasRectangle.timeText
                color: Theme.palette.directColor5
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: gasRectangle.toggle()
        }
    }

    indicator: Item {
        width:card.width
        height: card.height
    }
}
