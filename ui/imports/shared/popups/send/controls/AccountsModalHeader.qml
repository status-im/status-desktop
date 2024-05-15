import QtQuick 2.15

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import utils 1.0

import shared.controls 1.0

StatusComboBox {
    id: root

    property var selectedAccount
    property var getNetworkShortNames: function(chainIds){}
    property var formatCurrencyAmount: function(balance, symbol){}
    property int selectedIndex: -1

    objectName: "accountsModalHeader"
    popupContentItemObjectName: "accountSelectorList"

    control.padding: 0
    control.spacing: 0
    control.leftPadding: 8
    control.rightPadding: 8
    control.topPadding: 10

    control.popup.width: 430
    control.indicator: null

    control.background: Rectangle {
        objectName: "headerBackground"

        width: contentItem.childrenRect.width + control.leftPadding + control.rightPadding
        height: 32
        radius: 8
        color: !!selectedAccount ? hoverHandler.hovered ?
                                       Utils.getHoveredColor(selectedAccount.colorId) :
                                       Utils.getColorForId(selectedAccount.colorId) : "transparent"
        HoverHandler {
            id: hoverHandler
            cursorShape: Qt.PointingHandCursor
        }
    }

    contentItem: Row {
        anchors.verticalCenter: parent.verticalCenter
        width: childrenRect.width
        spacing: 8
        Padding {}
        StatusEmoji {
            objectName: "headerContentItemEmoji"
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16
            emojiId: StatusQUtils.Emoji.iconId(!!selectedAccount && !!selectedAccount.emoji ? selectedAccount.emoji : "", StatusQUtils.Emoji.size.verySmall) || ""
            visible: !!emojiId
        }
        StatusBaseText {
            objectName: "headerContentItemText"
            anchors.verticalCenter: parent.verticalCenter
            text: !!selectedAccount && !!selectedAccount.name ? selectedAccount.name : ""
            font.pixelSize: 15
            color: Theme.palette.indirectColor1
        }
        StatusIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: width
            visible: !!root.model && root.model.count > 1
            icon: "chevron-down"
            color: Theme.palette.indirectColor1
        }
        Padding {}
    }

    delegate: WalletAccountListItem {
        width: ListView.view.width
        modelData: model
        getNetworkShortNames: root.getNetworkShortNames
        formatCurrencyAmount: root.formatCurrencyAmount
        color: sensor.containsMouse || highlighted ?
                   Theme.palette.baseColor2 :
                   !!selectedAccount && selectedAccount.name === model.name ? Theme.palette.statusListItem.highlightColor : "transparent"
        onClicked: {
            selectedIndex = index
            control.popup.close()
        }
        Component.onCompleted:{
            if(!!selectedAccount && selectedAccount.address === model.address)
                selectedIndex = index
        }
    }
}

