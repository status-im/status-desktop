import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Status.Wallet
import Status.Containers

Item {
    id: root

    required property AccountAssetsController assetController
    required property WalletAccount account

    ListView {
        id: listView

        anchors.fill: parent

        model: root.assetController.assetModel

        delegate: RowLayout {
            required property WalletAsset asset

            Label {
                text: asset.name

                Layout.preferredWidth: listView.width * 0.4
            }
            RowLayout {
                Layout.preferredWidth: listView.width * 0.4

                Label {
                    text: asset.count
                }
                Label {
                    text: asset.symbol
                }
                LayoutSpacer{}
            }
            RowLayout {
                Label {
                    text: asset.value
                }
                Label {
                    //text: asset.currency
                }
            }
            LayoutSpacer{}
        }
    }
}
