import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.15

import Models 1.0

import AppLayouts.TradingCenter 1.0

SplitView {
    orientation: Qt.Vertical

    TradingCenterTokensModel {
        id: tradingTokensModel
    }

    TradingCenterLayout {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        tokensModel: tradingTokensModel
        formatCurrencyAmount: function(cryptoValue) {
            return "%L1 %2".arg(cryptoValue).arg("USD")
        }
        loading: loadingCheckbox.checked
        totalTokensCount: 5679
        onRequestLaunchSwap: console.warn("Request Launch Swap")
        onFetchTradingCenterTokens: console.warn("Fetch Trading Center Tokens with PageSize: %1 and PageNumber:%2".arg(pageSize).arg(pageNumber))
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
