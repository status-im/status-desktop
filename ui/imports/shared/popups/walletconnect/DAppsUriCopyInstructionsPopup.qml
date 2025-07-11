import QtQuick
import QtQuick.Layouts

import StatusQ
import StatusQ.Core.Theme
import StatusQ.Popups
import StatusQ.Popups.Dialog

import utils
import shared.controls

StatusDialog {
    width: 440
    title: qsTr("How to copy the dApp URI")
    footer: null
    horizontalPadding: 42
    verticalPadding: 32

    destroyOnClose: true

    ColumnLayout {
        spacing: 4

        Layout.leftMargin: Theme.padding
        Layout.rightMargin: Theme.padding
        Layout.preferredHeight: 348

        DecoratedListItem {
            Layout.preferredHeight: 40
            order: "1. "
            text1: qsTr("Navigate to a dApp with WalletConnect support")
        }

        DecoratedListItem {
            Layout.preferredHeight: 40
            order: "2. "
            text1: qsTr("Click the")
            text2: qsTr("Connect")
            text2Color: Theme.palette.directColor1
            text3: qsTr(" or ")
            text4: qsTr("Connect wallet")
            text4Color: Theme.palette.directColor1
            text5: qsTr("button")
        }

        DecoratedListItem {
            Layout.preferredHeight: 40
            order: "3. "
            text1: qsTr("Select")

            icon: "walletconnect"
            asset.color: "transparent"
            asset.bgColor: "transparent"
            width: 40
            height: 40
            asset.width: 40
            asset.height: 40

            text3: qsTr("WalletConnect")
            text3Color: Theme.palette.directColor1
            text4: qsTr(" from the menu")
        }

        DecoratedListItem {
            Layout.preferredHeight: 40
            order: "4. "
            text1: qsTr("Click the")
            icon: "tiny/copy"
            text3: qsTr("button")
        }

        DecoratedListItem {
            Layout.preferredHeight: 40
            order: "5. "
            text1: qsTr("Head back to Status and paste the URI")
        }
    }
}
