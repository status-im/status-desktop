import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import QtQml

import Qt.labs.platform

import Status.Wallet

import Status.Containers
import Status.Controls.Navigation

/// Drives the wallet workflow
PanelAndContentBase {
    id: root

    implicitWidth: 1232
    implicitHeight: 770

    RowLayout {
        id: mainLayout

        anchors.fill: parent

        AssetsPanel {
            id: panel

            Layout.preferredWidth: root.panelWidth
            Layout.fillHeight: true

            controller: WalletController
        }

        WalletContentView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            account: WalletController.currentAccount
            assetController: panel.currentAssetController
        }
    }
}
