import QtQuick 2.15

import StatusQ.Core 0.1

StatusListView {
    id: root

    // expected model structure:
    // tokensKey, name, symbol, decimals, currencyBalanceAsString (computed), iconSource, marketDetails, balances -> [ chainId, address, balance, iconUrl ]

    // output API
    signal tokenSelected(string tokensKey)

    currentIndex: -1

    delegate: TokenSelectorAssetDelegate {
        objectName: "tokenSelectorAssetDelegate_" + model.tokensKey

        required property var model
        required property int index

        width: ListView.view.width
        balancesListInteractive: !ListView.view.moving

        name: model.name
        symbol: model.symbol
        currencyBalanceAsString: model.currencyBalanceAsString ?? ""
        iconSource: model.iconSource
        balancesModel: model.balances

        onClicked: root.tokenSelected(model.tokensKey)
    }
}
