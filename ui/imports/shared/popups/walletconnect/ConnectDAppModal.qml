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

StatusDialog {
    id: root

    width: 480
    implicitHeight: d.connectionStatus === root.notConnectedStatus ? 633 : 681

    required property var accounts
    required property var flatNetworks

    readonly property alias selectedAccount: d.selectedAccount
    readonly property alias selectedChains: d.selectedChains

    readonly property int notConnectedStatus: 0
    readonly property int connectionSuccessfulStatus: 1
    readonly property int connectionFailedStatus: 2

    function openWithFilter(dappChains, proposer) {
        d.connectionStatus = root.notConnectedStatus
        d.afterTwoSecondsFromStatus = false

        let m = proposer.metadata
        dappCard.name = m.name
        dappCard.url = m.url
        if(m.icons.length > 0) {
            dappCard.iconUrl = m.icons[0]
        } else {
            dappCard.iconUrl = ""
        }

        d.dappChains.clear()
        for (let i = 0; i < dappChains.length; i++) {
            // Convert to int
            d.dappChains.append({ chainId: parseInt(dappChains[i]) })
        }

        root.open()
    }

    function pairSuccessful(session) {
        d.connectionStatus = root.connectionSuccessfulStatus
        closeAndRetryTimer.start()
    }
    function pairFailed(session, err) {
        d.connectionStatus = root.connectionFailedStatus
        closeAndRetryTimer.start()
    }

    Timer {
        id: closeAndRetryTimer

        interval: 2000
        running: false
        repeat: false

        onTriggered: {
            d.afterTwoSecondsFromStatus = true
        }
    }

    signal connect()
    signal decline()
    signal disconnect()

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    title: qsTr("Connection request")

    padding: 20

    contentItem: ColumnLayout {
        spacing: 20
        clip: true

        DAppCard {
            id: dappCard

            afterTwoSecondsFromStatus: d.afterTwoSecondsFromStatus

            isConnectedSuccessfully: d.connectionStatus === root.connectionSuccessfulStatus
            isConnectionFailed: d.connectionStatus === root.connectionFailedStatus
            isConnectionStarted: d.connectionStatus !== root.notConnectedStatus
            isConnectionFailedOrDisconnected: d.connectionStatus !== root.connectionSuccessfulStatus

            Layout.alignment: Qt.AlignHCenter
            Layout.leftMargin: 12
            Layout.rightMargin: Layout.leftMargin
            Layout.topMargin: 20
            Layout.bottomMargin: Layout.topMargin
        }

        ContextCard {
            Layout.fillWidth: true
            accountsProxy: d.accountsProxy
            selectedAccount: d.selectedAccount
            selectedChains: d.selectedChains
            filteredChains: d.filteredChains
            notConnected: d.connectionStatus === root.notConnectedStatus
        }

        PermissionsCard {
            Layout.fillWidth: true

            Layout.leftMargin: 12
            Layout.rightMargin: Layout.leftMargin
            Layout.topMargin: 20
            Layout.bottomMargin: Layout.topMargin
        }
    }

    footer: StatusDialogFooter {
        id: footer
        rightButtons: ObjectModel {
            StatusButton {
                height: 44
                text: qsTr("Decline")

                visible: d.connectionStatus === root.notConnectedStatus

                onClicked: root.decline()
            }
            StatusButton {
                height: 44
                text: qsTr("Disconnect")

                visible: d.connectionStatus === root.connectionSuccessfulStatus

                type: StatusBaseButton.Type.Danger

                onClicked: root.disconnect()
            }
            StatusButton {
                height: 44
                text: d.connectionStatus === root.notConnectedStatus
                            ? qsTr("Connect")
                            : qsTr("Close")

                onClicked: {
                    if (d.connectionStatus === root.notConnectedStatus)
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

        property var selectedAccount: ({})
        property var selectedChains: allChainIdsAggregator.value

        readonly property var filteredChains: LeftJoinModel {
            leftModel: d.dappChains
            rightModel: root.flatNetworks

            joinRole: "chainId"
        }

        readonly property FunctionAggregator allChainIdsAggregator: FunctionAggregator {
            model: d.filteredChains
            initialValue: []
            roleName: "chainId"

            aggregateFunction: (aggr, value) => [...aggr, value]
        } 

        readonly property var dappChains: ListModel {}

        property int connectionStatus: notConnectedStatus
        property bool afterTwoSecondsFromStatus: false
    }
}
