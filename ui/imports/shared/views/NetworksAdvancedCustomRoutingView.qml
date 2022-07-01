import QtQuick 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "../controls"

ColumnLayout {
    id: networksAdvancedCustomView

    property var store
    property var assets
    property var selectedNetwork: ""
    property var selectedAccount
    property double amountToSend: 0
    property double requiredGasInEth: 0
    property bool customMode: false
    property var selectedAsset
    property var suggestedRoutes
    property bool errorMode: networksLoader.item ? networksLoader.item.errorMode : false

    signal reCalculateSuggestedRoute(var disabledChainIds)

    onSelectedNetworkChanged:  {
            networksLoader.active = false
            networksLoader.active = true
    }

    RowLayout {
        spacing: 10

        StatusRoundIcon {
            Layout.alignment: Qt.AlignTop
            radius: 8
            icon.name: "flash"
        }
        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            RowLayout {
                Layout.maximumWidth: 410
                StatusBaseText {
                    Layout.maximumWidth: 410
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    color: Theme.palette.directColor1
                    text: qsTr("Networks")
                    wrapMode: Text.WordWrap
                }
                StatusButton {
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredHeight: 22
                    defaultTopPadding: 0
                    defaultBottomPadding: 0
                    size: StatusBaseButton.Size.Small
                    icon.name: "hide"
                    text: qsTr("Show Unpreferred Networks")
                }
            }
            StatusBaseText {
                Layout.maximumWidth: 410
                font.pixelSize: 15
                color: Theme.palette.baseColor1
                text: qsTr("The networks where the receipient will receive tokens. Amounts calculated automatically for the lowest cost.")
                wrapMode: Text.WordWrap
            }
            Loader {
                id: networksLoader
                Layout.topMargin: Style.current.padding
                active: false
                visible: active
                sourceComponent: NetworkCardsComponent {
                    store: networksAdvancedCustomView.store
                    selectedNetwork: networksAdvancedCustomView.selectedNetwork
                    selectedAccount: networksAdvancedCustomView.selectedAccount
                    allNetworks: networksAdvancedCustomView.store.allNetworks
                    amountToSend: networksAdvancedCustomView.amountToSend
                    customMode: networksAdvancedCustomView.customMode
                    requiredGasInEth: networksAdvancedCustomView.requiredGasInEth
                    assets: networksAdvancedCustomView.assets
                    selectedAsset: networksAdvancedCustomView.selectedAsset
                    locale: networksAdvancedCustomView.store.locale
                    suggestedRoutes: networksAdvancedCustomView.suggestedRoutes
                    onReCalculateSuggestedRoute: networksAdvancedCustomView.reCalculateSuggestedRoute(disabled)
                }
            }
        }
    }
}
