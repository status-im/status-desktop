import QtQuick 2.15

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import "../controls"

StatusComboBox {
    id: root

    property var selectedAccount
    property string chainShortNames
    property int selectedIndex: -1

    QtObject {
        id: d
        function getTextColorForWhite(color) {
            // The grey is kept for backwards compatibility for accounts already created with grey background
            return color === StatusColors.colors['grey'] || color === StatusColors.colors['white'] ? Theme.palette.black : Theme.palette.white
        }
    }

    control.padding: 0
    control.spacing: 0
    control.leftPadding: 8
    control.rightPadding: 8
    control.topPadding: 10

    control.popup.width: 430
    control.indicator: null

    control.background: Rectangle {
        width: contentItem.childrenRect.width + control.leftPadding + control.rightPadding
        height: 32
        radius: 8
        color: !!selectedAccount ? hoverHandler.containsMouse ?
                                       Theme.palette.walletAccountColors.getHoveredColor(selectedAccount.color) :
                                       selectedAccount.color ?? "transparent" : "transparent"
        HoverHandler {
            id: hoverHandler
            cursorShape: Qt.PointingHandCursor
        }
    }

    contentItem: Row {
        anchors.verticalCenter: parent.verticalCenter
        width: childrenRect.width
        spacing: 8
        StatusEmoji {
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16
            emojiId: StatusQUtils.Emoji.iconId(selectedAccount.emoji ?? "", StatusQUtils.Emoji.size.verySmall) || ""
        }
        StatusBaseText {
            anchors.verticalCenter: parent.verticalCenter
            text: selectedAccount.name ?? ""
            font.pixelSize: 15
            color: d.getTextColorForWhite(selectedAccount.color ?? "")
        }
        StatusIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: width
            icon: "chevron-down"
            color: d.getTextColorForWhite(selectedAccount.color ?? "")
        }
    }

    delegate: WalletAccountListItem {
        width: ListView.view.width
        modelData: model
        chainShortNames: root.chainShortNames
        color: sensor.containsMouse || highlighted ?
                   Theme.palette.baseColor2 :
                   selectedAccount.name === model.name ? Theme.palette.statusListItem.highlightColor : "transparent"
        onClicked: {
            selectedIndex = index
            control.popup.close()
        }
        Component.onCompleted:{
            if(selectedAccount.address === model.address)
                selectedIndex = index
        }
    }
}

