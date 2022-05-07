import QtQuick 2.14
import shared.status 1.0
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import utils 1.0

import "../../stores"

Column {
    id: root

    property WalletStore walletStore

    Repeater {
        id: permissionsList
        model: walletStore.dappList
        delegate: Item {
            width: parent.width
            height: listItem.height + spacer.height
            StatusListItem {
                id: listItem
                title: model.name
                icon.isLetterIdenticon: true
                width: parent.width
                highlighted: true
                sensor.enabled: false
                components: [
                    StatusButton {
                        text: model.accounts.count > 1 ? qsTr("Disconnect All") : qsTr("Disconnect")
                        size: StatusBaseButton.Size.Small
                        type: StatusBaseButton.Type.Danger
                        onClicked: {
                            walletStore.disconnect(model.name)
                        }
                    }
                ]
                bottomModel: model.accounts
                bottomDelegate: StatusListItemTag {
                    property int outerIndex: listItem.index

                    title: model.name
                    icon.isLetterIdenticon: true
                    icon.color: model.color
                    onClicked: {
                        const dappName = walletStore.dappList.rowData(outerIndex, 'name')
                        walletStore.disconnectAddress(dappName, model.address)
                    }
                }
            }

            Item {
                id: spacer
                height: Style.current.bigPadding
                width: parent.width
            }
        } // Item
    } // Repeater
} // Column
