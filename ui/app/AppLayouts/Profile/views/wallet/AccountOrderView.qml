import QtQuick 2.15
import SortFilterProxyModel 0.2
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import shared.status 1.0

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import "../../stores"
import "../../controls"

StatusListView {
    id: accountsView
    signal goBack

    property WalletStore walletStore

    header: StatusBaseText {
        text: qsTr("Move your most freqently used accounts to the top of your wallet list")
        color: Theme.palette.baseColor1
        font.pixelSize: Style.current.primaryTextFontSize
        bottomPadding: Style.current.padding
    }

    model: SortFilterProxyModel {
        sourceModel: walletStore.accounts
        sorters: [
            RoleSorter {
                roleName: "position"
                priority: 2 
            }
        ]
    }

    displaced: Transition {
        NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
    }

    delegate: DropArea {
        id: delegateRoot

        property int visualIndex: index

        width: ListView.view.width
        height: draggableDelegate.height

        keys: ["x-status-draggable-list-item-internal"]

        onEntered: function(drag) {
            const from = drag.source.visualIndex
            const to = draggableDelegate.visualIndex
            if (to === from)
                return
            drag.accept()
        }

        onDropped: function(drop) {
            walletStore.updateAccountPosition(drop.source.address, draggableDelegate.position)
            drop.accept()
        }

        StatusDraggableListItem {
            id: draggableDelegate

            property int position: model.position
            property string address: model.address
            width: parent.width
            height: implicitHeight
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }

            dragParent: accountsView
            visualIndex: delegateRoot.visualIndex
            draggable: accountsView.count > 1
            title: {
                return model.name
            }
            secondaryTitle: model.address
            hasEmoji: true
            icon.width: 40
            icon.height: 40
            icon.name: model.emoji
            icon.color: Utils.getColorForId(model.colorId)
            actions: []
        }
    }
}
