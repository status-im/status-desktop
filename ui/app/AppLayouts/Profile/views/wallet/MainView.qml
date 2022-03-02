import QtQuick 2.13

import utils 1.0
import shared.status 1.0
import shared.panels 1.0
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1

import "../../stores"
import "../../controls"


Column {
    id: root

    property WalletStore walletStore

    signal goToNetworksView()


    StatusBaseText {
        id: titleText
        text: qsTr("Wallet")
        font.weight: Font.Bold
        font.pixelSize: 28
        color: Theme.palette.directColor1
    }

    Item {
        height: Style.current.bigPadding
        width: parent.width
    }

    StatusSettingsLineButton {
        text: qsTr("Manage Assets & List")
        height: 64
        onClicked: goToNetworksView()
    }

    Separator {
        height: 17
        anchors.left: parent.left
        anchors.leftMargin: -Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: -Style.current.padding
    }

    StatusSettingsLineButton {
        text: qsTr("DApp Permission")
        height: 64
        onClicked: goToNetworksView()
    }

    Separator {
        height: 17
        anchors.left: parent.left
        anchors.leftMargin: -Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: -Style.current.padding
    }

    StatusSettingsLineButton {
        text: qsTr("Networks")
        height: 64
        onClicked: goToNetworksView()
    }

    Separator {
        height: 17
        anchors.left: parent.left
        anchors.leftMargin: -Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: -Style.current.padding
    }

    Item {
        height: Style.current.bigPadding
        width: parent.width
    }

    StatusBaseText {
        id: accountsText
        text: qsTr("Accounts")
        font.pixelSize: 15
        color: Theme.palette.directColor1
    }

    StatusSectionHeadline {
        text: qsTr("Generated from Your Seed Phrase")
        topPadding: Style.current.bigPadding
        bottomPadding: Style.current.padding
    }

    Repeater {
        model: walletStore.generatedAccounts
        delegate: WalletAccountDelegate {
            account: model
        }
    }

    StatusSectionHeadline {
        text: qsTr("Imported")
        topPadding: Style.current.bigPadding
        bottomPadding: Style.current.padding
    }

    Repeater {
        model: walletStore.importedAccounts
        delegate: WalletAccountDelegate {
            account: model
        }
    }

    StatusSectionHeadline {
        text: qsTr("Watch-Only")
        topPadding: Style.current.bigPadding
        bottomPadding: Style.current.padding
    }

    Repeater {
        model: walletStore.watchOnlyAccounts
        delegate: WalletAccountDelegate {
            account: model
        }
    }
}