import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.15

import SortFilterProxyModel 0.2

import Models 1.0

import StatusQ.Core 0.1

import AppLayouts.Market 1.0

SplitView {
    orientation: Qt.Vertical

    MarketTokensModel {
        id: marketTokensModel
    }

    SortFilterProxyModel {
        id: filteredModel
        property int startIndex: 0
        property int endIndex: 0
        sourceModel: marketTokensModel
        filters: IndexFilter {
            minimumIndex: filteredModel.startIndex
            maximumIndex: filteredModel.endIndex
        }
    }

    Loader {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        active: marketTokensModel.count === 210
        sourceComponent: MarketLayout {
            anchors.fill: parent
            tokensModel: filteredModel
            loading: loadingCheckbox.checked
            totalTokensCount: marketTokensModel.count
            currencySymbol: "$"
            fnFormatCurrencyAmount: function(amount, options) {
                let abc = ({
                               amount: amount,
                               symbol: "usd".toUpperCase(),
                               displayDecimals: 2,
                               stripTrailingZeroes: false
                           })
                return LocaleUtils.currencyAmountToLocaleString(abc, options)
            }
            currentPage: -1
            onRequestLaunchSwap: console.warn("Request Launch Swap")
            onFetchMarketTokens: {
                console.warn("Fetch Market Tokens with PageSize: %1 and PageNumber:%2".arg(pageSize).arg(pageNumber))
                filteredModel.startIndex = ((pageNumber - 1) * pageSize) + 1
                filteredModel.endIndex = Math.min(pageNumber * pageSize, totalTokensCount)
                currentPage = pageNumber
            }
        }
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
