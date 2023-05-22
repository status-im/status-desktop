import QtQuick 2.14
import QtWebEngine 1.10
import shared.status 1.0
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import utils 1.0

import AppLayouts.Profile.stores 1.0

Column {
    id: root

    property WalletStore walletStore

    Repeater {
        id: permissionsList
        model: walletStore.dappList
        delegate: Item {
            property string dappName: model.name
            width: parent.width
            height: listItem.height + spacer.height
            WebEngineView {
                id: webView
                url: dappName.startsWith("http") ? dappName : `http://${dappName}`
                visible: false
            }
            StatusListItem {
                id: listItem
                title: webView.title !== "" ? webView.title : dappName
                subTitle: dappName
                asset.name: webView.icon != "" ? webView.icon : Style.svg("compassActive")
                asset.isImage: true
                width: parent.width
                highlighted: true
                sensor.enabled: false
                components: [
                    StatusButton {
                        text: model.accounts.count > 1 ? qsTr("Disconnect All") : qsTr("Disconnect")
                        size: StatusBaseButton.Size.Small
                        type: StatusBaseButton.Type.Danger
                        onClicked: {
                            walletStore.disconnect(dappName)
                        }
                    }
                ]
                bottomModel: model.accounts
                bottomDelegate: StatusListItemTag {
                    property int outerIndex: listItem.index || 0

                    title: model.name

                    asset.emoji: !!model.emoji ? model.emoji: ""
                    asset.color: Utils.getColorForId(model.colorId)
                    asset.name: !model.emoji ? "filled-account": ""
                    asset.letterSize: 14
                    asset.isLetterIdenticon: !!model.emoji
                    asset.bgColor: Theme.palette.indirectColor1
                    onClicked: {
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
