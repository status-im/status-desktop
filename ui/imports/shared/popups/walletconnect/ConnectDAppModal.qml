import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.14
import SortFilterProxyModel 0.2

import QtGraphicalEffects 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import shared.controls 1.0
// TODO extract the components to StatusQ
import shared.popups.send.controls 1.0
import shared.popups.walletconnect.controls 1.0

import AppLayouts.Wallet.controls 1.0

import utils 1.0
import shared.popups.walletconnect.private 1.0

StatusDialog {
    id: root

    /*
        Accounts model

        Expected model structure:
        name                    [string] - account name e.g. "Piggy Bank"
        address                 [string] - wallet account address e.g. "0x1234567890"
        colorizedChainPrefixes  [string] - chain prefixes with rich text colors e.g. "<font color=\"red\">eth:</font><font color=\"blue\">oeth:</font><font color=\"green\">arb:</font>"
        emoji                   [string] - emoji for account e.g. "🐷"
        colorId                 [string] - color id for account e.g. "1"
        currencyBalance         [var]    - fiat currency balance
            amount              [number] - amount of currency e.g. 1234
            symbol              [string] - currency symbol e.g. "USD"
            optDisplayDecimals  [number] - optional number of decimals to display
            stripTrailingZeroes [bool]   - strip trailing zeroes
        walletType              [string] - wallet type e.g. Constants.watchWalletType. See `Constants` for possible values
        migratedToKeycard       [bool]   - whether account is migrated to keycard
        accountBalance          [var]    - account balance for a specific network
            formattedBalance    [string] - formatted balance e.g. "1234.56B"
            balance             [string] - balance e.g. "123456000000"
            iconUrl             [string] - icon url e.g. "network/Network=Hermez"
            chainColor          [string] - chain color e.g. "#FF0000"
    */
    required property var accounts
    /*
      Networks model
      Expected model structure:
        chainName      [string]          - chain long name. e.g. "Ethereum" or "Optimism"
        chainId        [int]             - chain unique identifier
        iconUrl        [string]          - SVG icon name. e.g. "network/Network=Ethereum"
        layer          [int]             - chain layer. e.g. 1 or 2
        isTest         [bool]            - true if the chain is a testnet
    */
    required property var flatNetworks

    property alias dAppUrl: dappCard.dAppUrl
    property alias dAppName: dappCard.name
    property alias dAppIconUrl: dappCard.iconUrl
    property alias connectionStatus: d.connectionStatus

    /*
        Selected account address holds the initial account address selection for the account selector.
        It is used to preselect the account in the account selector.
    */
    property string selectedAccountAddress: contextCard.selectedAccount.address ?? ""

    readonly property alias selectedAccount: contextCard.selectedAccount
    readonly property alias selectedChains: d.selectedChains

    readonly property int notConnectedStatus: 0
    readonly property int connectionSuccessfulStatus: 1
    readonly property int connectionFailedStatus: 2

    function pairSuccessful(session) {
        d.connectionStatus = root.connectionSuccessfulStatus
    }
    function pairFailed(session, err) {
        d.connectionStatus = root.connectionFailedStatus
    }

    signal connect()
    signal decline()
    signal disconnect()

    width: 480
    implicitHeight: !d.connectionAttempted ? 633 : 681
    
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    title: d.connectionSuccessful ? qsTr("dApp connected") :
                                    qsTr("Connection request")

    padding: 20

    contentItem: ColumnLayout {
        spacing: 20
        clip: true

        DAppCard {
            id: dappCard
            Layout.maximumWidth: root.availableWidth - Layout.leftMargin * 2
            Layout.leftMargin: 12
            Layout.rightMargin: Layout.leftMargin
            Layout.topMargin: 14
            Layout.bottomMargin: Layout.topMargin
        }

        ContextCard {
            id: contextCard
            Layout.maximumWidth: root.availableWidth
            Layout.fillWidth: true

            selectedAccountAddress: root.selectedAccountAddress
            connectionAttempted: d.connectionAttempted
            accountsModel: d.accountsProxy
            chainsModel: root.flatNetworks
            chainSelection: d.selectedChains

            onChainSelectionChanged: {
                if (d.selectedChains !== chainSelection) {
                    d.selectedChains = chainSelection
                }
            }
        }

        PermissionsCard {
            Layout.maximumWidth: root.availableWidth
            Layout.fillWidth: true

            Layout.leftMargin: 16
            Layout.rightMargin: Layout.leftMargin
            Layout.topMargin: 12
            Layout.bottomMargin: Layout.topMargin
            dappName: dappCard.name
        }
    }

    footer: StatusDialogFooter {
        id: footer
        rightButtons: ObjectModel {
            StatusButton {
                objectName: "rejectButton"
                height: 44
                text: qsTr("Reject")

                visible: !d.connectionAttempted

                onClicked: root.decline()
            }
            StatusFlatButton {
                objectName: "disconnectButton"
                height: 44
                text: qsTr("Disconnect")

                visible: d.connectionSuccessful

                type: StatusBaseButton.Type.Danger

                onClicked: root.disconnect()
            }
            StatusButton {
                objectName: "primaryActionButton"
                height: 44
                text: d.connectionAttempted
                            ? qsTr("Close")
                            : qsTr("Connect")
                enabled: {
                    if (!d.connectionAttempted)
                        return root.selectedChains.length > 0
                    return true
                }

                onClicked: {
                    if (!d.connectionAttempted)
                        root.connect()
                    else
                        root.close()
                }
            }
        }
    }

    QtObject {
        id: d

        property SortFilterProxyModel accountsProxy: SortFilterProxyModel {
            sourceModel: root.accounts

            sorters: RoleSorter { roleName: "position"; sortOrder: Qt.AscendingOrder }
        }

        property var selectedChains: allChainIdsAggregator.value

        readonly property FunctionAggregator allChainIdsAggregator: FunctionAggregator {
            model: root.flatNetworks
            initialValue: []
            roleName: "chainId"

            aggregateFunction: (aggr, value) => [...aggr, value]
        } 

        property int connectionStatus: root.notConnectedStatus
        readonly property bool connectionSuccessful: d.connectionStatus === root.connectionSuccessfulStatus
        readonly property bool connectionFailed: d.connectionStatus === root.connectionFailedStatus
        readonly property bool connectionAttempted: d.connectionStatus !== root.notConnectedStatus
    }
}
