import QtQuick 2.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0
import shared.panels 1.0

Rectangle {
    id: walletDelegate

    property string locale: ""
    property string currency: ""
    property int selectedAccountIndex
    property bool selected: index === selectedAccountIndex
    property bool hovered

    signal clicked(int index)

    height: 64
    color: {
      if (selected) {
          return Style.current.menuBackgroundActive
      }
      if (hovered) {
          return Style.current.backgroundHoverLight
      }
      return Style.current.transparent
    }
    radius: Style.current.radius
    anchors.right: parent.right
    anchors.rightMargin: Style.current.padding
    anchors.left: parent.left
    anchors.leftMargin: Style.current.padding

    SVGImage {
        id: walletIcon
        width: 12
        height: 12
        anchors.top: parent.top
        anchors.topMargin: Style.current.smallPadding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        source: Style.svg("walletIcon")
    }
    ColorOverlay {
        anchors.fill: walletIcon
        source: walletIcon
        color: {
            Utils.getCurrentThemeAccountColor(model.color) || Style.current.accountColors[0]
        }
    }
    StyledText {
        id: walletName
        text: name
        elide: Text.ElideRight
        anchors.right: walletBalance.left
        anchors.rightMargin: Style.current.smallPadding
        anchors.top: parent.top
        anchors.topMargin: Style.current.smallPadding
        anchors.left: walletIcon.right
        anchors.leftMargin: Style.current.smallPadding

        font.pixelSize: 15
        font.weight: Font.Medium
        color: Style.current.textColor
    }
    StyledText {
        id: walletAddress
        font.family: Style.current.fontHexRegular.name
        text: address
        anchors.right: parent.right
        anchors.rightMargin: parent.width/2
        elide: Text.ElideMiddle
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.smallPadding
        anchors.left: walletIcon.left
        font.pixelSize: 15
        font.weight: Font.Medium
        color: Style.current.secondaryText
        opacity: selected ? 0.7 : 1
    }
    StyledText {
        id: walletBalance
        text: {
            Utils.toLocaleString(currencyBalance.toFixed(2), locale, {"currency": true}) + " " + walletDelegate.currency.toUpperCase()
        }
        anchors.top: parent.top
        anchors.topMargin: Style.current.smallPadding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        font.pixelSize: 15
        font.weight: Font.Medium
        color: Style.current.textColor
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: {
            walletDelegate.hovered = true
        }
        onExited: {
            walletDelegate.hovered = false
        }
        onClicked: {
            walletDelegate.clicked(index)
        }
    }
}
