import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1

import Storybook 1.0
import Models 1.0

import shared.controls 1.0
import shared.stores 1.0

import utils 1.0

SplitView {
    id: root

    orientation: Qt.Vertical

    CurrenciesStore {
        id: currencyStore
    }

    AssetsDetailsHeader {
        SplitView.fillWidth: true
        asset.name: Constants.tokenIcon("ETH")
        asset.isImage: true
        primaryText: "ETH"
        secondaryText: "5.39 ETH"
        tertiaryText: "2.510,47 USD"
        decimals: 18
        balances: ListModel {
            readonly property var data:[
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", chainId: 10, balance: "559133758939097000" },
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", chainId: 11155420, balance: "0" },
                { account: "0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7240", chainId: 11155111, balance: "0" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", chainId: 11155420, balance: "123456789123456789" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", chainId: 11155111, balance: "123456789123456789" },
                { account: "0x7F47C2e98a4BBf5487E6fb082eC2D9Ab0E6d8881", chainId: 42161, balance: "45123456789123456789" },
            ]
            Component.onCompleted: append(data)
        }
        networksModel: NetworksModel.flatNetworks
        isLoading: loadingCheckbox.checked
        formatBalance: function(balance){
            return LocaleUtils.currencyAmountToLocaleString(currencyStore.getCurrencyAmount(balance, "ETH"))
        }
        communityTag.visible: false
    }

    ColumnLayout {
        SplitView.maximumHeight: 300
        CheckBox {
            id: loadingCheckbox
            text: "loading"
        }
    }
}

// category: Controls
