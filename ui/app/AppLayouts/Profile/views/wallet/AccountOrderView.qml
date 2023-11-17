import QtQuick 2.15
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

ColumnLayout {
    id: root

    property WalletStore walletStore

    signal goBack

    spacing: Style.current.padding

    QtObject {
        id: d

        readonly property string walletAccountDnDKey: "status-wallet-account-item"
        property int indexMoveFrom: -1
        property int indexMoveTo: -1
    }

    StatusBaseText {
        Layout.fillWidth: true
        text: accountsList.count > 1? qsTr("Move your most frequently used accounts to the top of your wallet list") :
                                      qsTr("This account looks a little lonely. Add another account to enable re-ordering.")
        color: Theme.palette.baseColor1
    }

    StatusListView {
        id: accountsList
        Layout.fillWidth: true
        Layout.preferredHeight: contentHeight
        interactive: false
        model: walletStore.accounts

        displaced: Transition {
            NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
        }

        delegate: DropArea {
            id: delegateRoot

            property int visualIndex: index

            width: ListView.view.width
            height: draggableDelegate.height

            keys: [d.walletAccountDnDKey]

            onEntered: function(drag) {
                const from = drag.source.visualIndex
                const to = draggableDelegate.visualIndex
                if (to === from)
                    return
                if (d.indexMoveFrom === -1)
                    d.indexMoveFrom = from
                d.indexMoveTo = to
                root.walletStore.moveAccount(from, to)
                drag.accept()
            }

            onDropped: function(drop) {
                let from = d.indexMoveFrom
                let to = d.indexMoveTo
                d.indexMoveFrom = -1
                d.indexMoveTo = -1
                root.walletStore.moveAccountFinally(from, to)
            }

            StatusDraggableListItem {
                id: draggableDelegate
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: implicitHeight

                dragParent: accountsList
                visualIndex: delegateRoot.visualIndex
                draggable: accountsList.count > 1
                Drag.keys: [d.walletAccountDnDKey]
                title: model.name
                secondaryTitle: model.address
                secondaryTitleIcon: model.walletType === Constants.watchWalletType? "show" :
                                                                                    model.keycardAccount ? "keycard" : ""
                hasEmoji: true
                icon.width: 40
                icon.height: 40
                icon.name: model.emoji
                icon.color: Utils.getColorForId(model.colorId)
            }
        }
    }
}
