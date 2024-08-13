import QtQuick 2.14
import QtQuick.Layouts 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1
import StatusQ.Components 0.1
import StatusQ.Components.private 0.1

import AppLayouts.Wallet.controls 1.0

import utils 1.0

ColumnLayout {
    id: root

    // required properties
    required property var assetsModel
    required property var selectedProvider
    required property string selectedTokenKey
    required property int selectedNetworkChainId
    required property var filteredFlatNetworksModel

    // exposed api
    property alias searchString: holdingSelector.searchString
    signal networkSelected(int chainId)
    signal tokenSelected(string tokensKey)

    QtObject {
        id: d
        function updateTokenSelector() {
            Qt.callLater(()=> {
                             if(!!holdingSelector.model && !!root.selectedTokenKey && root.selectedNetworkChainId !== -1) {
                                 holdingSelector.selectToken(root.selectedTokenKey)
                             }
                         })
        }
    }

    onSelectedTokenKeyChanged: d.updateTokenSelector()
    onSelectedNetworkChainIdChanged: d.updateTokenSelector()

    spacing: 20

    StatusListItem {
        objectName: "selectParamsForBuyCryptoPanelHeader"
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignLeft
        leftPadding: 0
        rightPadding: 0

        title: qsTr("Buy via %1").arg(!!root.selectedProvider ? root.selectedProvider.name: "")
        subTitle: qsTr("Select which network and asset")
        statusListItemTitle.color: Theme.palette.directColor1
        asset.name: !!root.selectedProvider ? root.selectedProvider.logoUrl: ""
        asset.isImage: true
        color: Theme.palette.transparent
        enabled: false
    }
    StatusMenuSeparator {
        Layout.fillWidth: true
    }
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8
        StatusBaseText {
            text: qsTr("Select network")
            color: Theme.palette.directColor1
            font.pixelSize: 15
            lineHeight: 22
            lineHeightMode: Text.FixedHeight
            verticalAlignment: Text.AlignVCenter
        }
        NetworkFilter {
            objectName: "networkFilter"
            Layout.fillWidth: true
            control.popup.width: parent.width
            multiSelection: false
            showSelectionIndicator: false
            flatNetworks: root.filteredFlatNetworksModel
            selection: [root.selectedNetworkChainId]
            onSelectionChanged: root.networkSelected(selection[0])
        }
    }
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 8
        StatusBaseText {
            text: qsTr("Select asset")
            color: Theme.palette.directColor1
            font.pixelSize: 15
            lineHeight: 22
            lineHeightMode: Text.FixedHeight
            verticalAlignment: Text.AlignVCenter
        }
        TokenSelector {
            id: holdingSelector
            objectName: "tokenSelector"
            Layout.fillWidth: true
            model: root.assetsModel
            popup.width: parent.width
            contentItem:  Loader {
                height: 40 // by design
                sourceComponent: !!holdingSelector.currentTokensKey ? selectedTokenCmp : nothingSelectedCmp
            }
            background: StatusComboboxBackground {
                border.width: 1
                color: Theme.palette.transparent
            }
            onTokenSelected: root.tokenSelected(tokensKey)
        }
    }

    Component {
        id: nothingSelectedCmp
        StatusBaseText {
            objectName: "tokenSelectorContentItemText"
            font.pixelSize: Style.current.additionalTextSize
            font.weight: Font.Medium
            color: Theme.palette.primaryColor1
            text: qsTr("Select asset")
        }
    }

    Component {
        id: selectedTokenCmp
        RowLayout {
            objectName: "selectedTokenItem"
            spacing: Style.current.halfPadding
            StatusRoundedImage {
                objectName: "tokenSelectorIcon"
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                image.source: ModelUtils.getByKey(holdingSelector.model, "tokensKey", holdingSelector.currentTokensKey, "iconSource")
            }
            StatusBaseText {
                objectName: "tokenSelectorContentItemName"
                font.pixelSize: 15
                color: Theme.palette.directColor1
                text: ModelUtils.getByKey(holdingSelector.model, "tokensKey", holdingSelector.currentTokensKey, "name")
            }
            StatusBaseText {
                Layout.fillWidth: true
                objectName: "tokenSelectorContentItemSymbol"
                font.pixelSize: 15
                color: Theme.palette.baseColor1
                text: ModelUtils.getByKey(holdingSelector.model, "tokensKey", holdingSelector.currentTokensKey, "symbol")
            }
        }
    }
}
