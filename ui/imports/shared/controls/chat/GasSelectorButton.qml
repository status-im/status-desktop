import QtQuick 2.13
import QtQuick.Layouts 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusRadioButton {
    id: gasRectangle

    property string primaryText: qsTr("Low")
    property string gasLimit
    property string defaultCurrency: "USD"
    property double price: 1
    property var getGasEthValue: function () {}
    property var getFiatValue: function () {}

    function formatDec(num, dec){
       return Math.round((num + Number.EPSILON) * Math.pow(10, dec)) / Math.pow(10, dec)
    }

    QtObject {
        id: d
        property double fiatValue: getFiatValue(ethValue, "ETH", defaultCurrency)
        property double ethValue: {
            if (!gasLimit) {
                return 0
            }
            return formatDec(parseFloat(getGasEthValue(gasRectangle.price, gasLimit)), 6)
        }
    }

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
                font.pixelSize: 13
                font.weight: Font.Medium
                text: d.ethValue + " ETH"
                color: Theme.palette.primaryColor1
            }
            StatusBaseText {
                id: tertiaryText
                font.pixelSize: 10
                text: d.fiatValue + " " + gasRectangle.defaultCurrency.toUpperCase()
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
