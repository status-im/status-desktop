import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.15

import Models 1.0

import AppLayouts.Market 1.0

SplitView {
    orientation: Qt.Vertical

    MarketTokensModel {
        id: marketTokensModel
    }

    MarketLayout {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        tokensModel: marketTokensModel
        loading: loadingCheckbox.checked
        totalTokensCount: 5679
        currencySymbol: "$"
        onRequestLaunchSwap: console.warn("Request Launch Swap")
        onFetchMarketTokens: console.warn("Fetch Market Tokens with PageSize: %1 and PageNumber:%2".arg(pageSize).arg(pageNumber))
    }

    ColumnLayout {
        CheckBox {
            id: loadingCheckbox
            text: "loading"
        }
    }

}

// category: Views

// https://www.figma.com/design/mh7hMVynZjL3eiV7e5oEyk/Trading?node-id=243-163195&m=dev
