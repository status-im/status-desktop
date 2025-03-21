import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.15

import Models 1.0

import AppLayouts.TradingCenter 1.0

SplitView {
    orientation: Qt.Vertical

    TradingCenterLayout {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        tokensModel: TokensBySymbolModel{}
        formatCurrencyAmount: function(cryptoValue) {
            return "%L1 %2".arg(cryptoValue).arg("USD")
        }
        loading: loadingCheckbox.checked
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
