import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.panels 1.0

import AppLayouts.Profile.controls 1.0

import QtModelsToolkit 1.0

ProfileShowcasePanel {
    id: root

    required property bool addAccountsButtonVisible

    property var formatCurrencyAmount: function(amount, symbol){}

    signal navigateToAccountsTab()

    emptyInShowcasePlaceholderText: qsTr("Assets here will show on your profile")
    emptyHiddenPlaceholderText: qsTr("Assets here will be hidden from your profile")
    emptySearchPlaceholderText: qsTr("No assets matching search")
    searchPlaceholderText: qsTr("Search asset name, symbol or community")
    delegate: ProfileShowcasePanelDelegate {

        readonly property double totalValue: !!model && !!model.decimals ? balancesAggregator.value/(10 ** model.decimals): 0

        title: !!model && !!model.name ? model.name : ""
        secondaryTitle: !!model && !!model.enabledNetworkBalance ?
                        LocaleUtils.currencyAmountToLocaleString(model.enabledNetworkBalance) :
                        !!model && !!model.symbol ? root.formatCurrencyAmount(totalValue, model.symbol) : Qt.locale().zeroDigit

        hasImage: true
        icon.source: !!model ? Constants.tokenIcon(model.symbol) : ""

        SumAggregator {
            id: balancesAggregator
            model: !!model && !!model.balances ? model.balances: null
            roleName: "balance"
        }
    }

    additionalFooterComponent: root.addAccountsButtonVisible ? addMoreAccountsComponent : null

    Component {
        id: addMoreAccountsComponent

        AddMoreAccountsLink {
             visible: root.addAccountsButtonVisible
             text: qsTr("Don’t see some of your assets?")
             onClicked: root.navigateToAccountsTab()
        }
    }
}
