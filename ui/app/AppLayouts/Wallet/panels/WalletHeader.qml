import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import utils 1.0

import "../controls"
import "../stores"

Item {
    id: root

    property var networkConnectionStore
    property var overview
    property var store
    property var walletStore

    signal launchShareAddressModal()
    signal switchHideWatchOnlyAccounts()

    implicitHeight: 88

    GridLayout {
        width: parent.width
        columns: 2
        rowSpacing: 0

        // account + balance
        RowLayout {
            spacing: Style.current.halfPadding
            StatusBaseText {
                objectName: "accountName"
                Layout.alignment: Qt.AlignVCenter
                verticalAlignment: Text.AlignVCenter
                color: overview.isAllAccounts ? Theme.palette.directColor5 : Utils.getColorForId(overview.colorId)
                lineHeightMode: Text.FixedHeight
                lineHeight: 38
                font.bold: true
                font.pixelSize: 28
                text: overview.isAllAccounts ? qsTr("All Accounts") : overview.name
            }
            StatusEmoji {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                emojiId: StatusQUtils.Emoji.iconId(overview.emoji ?? "", StatusQUtils.Emoji.size.big) || ""
                visible: !overview.isAllAccounts
            }
        }

        RowLayout {
            spacing: 16
            Layout.alignment: Qt.AlignTrailing
            Layout.topMargin: 5

            StatusButton {
                Layout.preferredHeight: 38
                Layout.alignment: Qt.AlignTop

                spacing: 8
                size: StatusBaseButton.Size.Small
                borderColor: Theme.palette.directColor7
                normalColor: Theme.palette.transparent
                hoverColor: Theme.palette.baseColor2

                font.weight: Font.Normal
                textPosition: StatusBaseButton.TextPosition.Left
                textColor: Theme.palette.baseColor1
                text: overview.ens ||  StatusQUtils.Utils.elideText(overview.mixedcaseAddress, 6, 4)

                icon.name: "invite-users"
                icon.height: 16
                icon.width: 16
                icon.color: hovered ? Theme.palette.directColor1 : Theme.palette.baseColor1

                onClicked: launchShareAddressModal()
                visible: !overview.isAllAccounts
            }


            StatusButton {
                objectName: "hideShowWatchOnlyButton"
                Layout.preferredHeight: 38
                Layout.alignment: Qt.AlignTop

                spacing: 8
                size: StatusBaseButton.Size.Small
                borderColor: Theme.palette.directColor7
                normalColor: Theme.palette.transparent
                hoverColor: Theme.palette.baseColor2

                font.weight: Font.Normal
                textColor: Theme.palette.baseColor1
                text: overview.hideWatchAccounts ? qsTr("Show watch-only"):  qsTr("Hide watch-only")

                icon.name: overview.hideWatchAccounts ? "show" : "hide"
                icon.height: 16
                icon.width: 16
                icon.color: Theme.palette.baseColor1

                onClicked: switchHideWatchOnlyAccounts()
                visible: overview.isAllAccounts
            }

            // network filter
            NetworkFilter {
                id: networkFilter

                Layout.alignment: Qt.AlignTop

                allNetworks: walletStore.allNetworks
                layer1Networks: walletStore.layer1Networks
                layer2Networks: walletStore.layer2Networks
                testNetworks: walletStore.testNetworks
                enabledNetworks: walletStore.enabledNetworks

                onToggleNetwork: (network) => {
                                     walletStore.toggleNetwork(network.chainId)
                                 }
            }
        }

        RowLayout {
            spacing: 4
            visible: !networkConnectionStore.accountBalanceNotAvailable
            StatusTextWithLoadingState {
                font.pixelSize: 28
                font.bold: true
                customColor: Theme.palette.directColor1
                text: loading ? Constants.dummyText : LocaleUtils.currencyAmountToLocaleString(root.overview.currencyBalance, {noSymbol: true})
                loading: root.overview.balanceLoading
                lineHeightMode: Text.FixedHeight
                lineHeight: 38
            }
            StatusTextWithLoadingState {
                Layout.alignment: Qt.AlignBottom
                font.pixelSize: 15
                font.bold: true
                customColor: Theme.palette.directColor1
                text: loading ? Constants.dummyText : root.overview.currencyBalance.symbol
                loading: root.overview.balanceLoading
                lineHeightMode: Text.FixedHeight
                lineHeight: 25
            }
        }
    }
}
