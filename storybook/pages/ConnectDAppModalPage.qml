import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15
import Qt.labs.settings 1.0
import QtTest 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1

import Models 1.0
import Storybook 1.0

import shared.popups.walletconnect 1.0

import SortFilterProxyModel 0.2

import AppLayouts.Wallet.panels 1.0

import utils 1.0
import shared.stores 1.0

Item {
    id: root

    // qml Splitter
    SplitView {
        anchors.fill: parent

        PopupBackground {
            SplitView.fillWidth: true

            Button {
                text: "Open"
                onClicked: modal.open()
                anchors.centerIn: parent
            }

            ConnectDAppModal {
                id: modal

                anchors.centerIn: parent

                modal: false
                closePolicy: Popup.NoAutoClose

                visible: true

                spacing: 8

                accounts: WalletAccountsModel {}

                flatNetworks: SortFilterProxyModel {
                    sourceModel: NetworksModel.flatNetworks
                    filters: ValueFilter { roleName: "isTest"; value: false; }
                }

                dAppUrl: dAppUrlField.text
                dAppName:  dAppNameField.text
                dAppIconUrl: hasIconCheckbox.checked ? "https://avatars.githubusercontent.com/u/37784886" : ""
                dAppConnectorBadge: Constants.dappImageByType[dAppBadgeComboBox.currentIndex]
                connectionStatus: pairedCheckbox.checked ? pairedStatusCheckbox.checked ? connectionSuccessfulStatus : connectionFailedStatus : notConnectedStatus
            }
        }

        ColumnLayout {
            id: optionsSpace

            CheckBox {
                id: pairedCheckbox

                text: "Report Paired"

                checked: true
            }
            CheckBox {
                id: pairedStatusCheckbox

                text: "Paired Successful"

                checked: true
            }
            CheckBox {
                id: hasIconCheckbox

                text: "Has Icon"

                checked: true
            }
            Label {
                text: "DappName"
            }
            TextField {
                id: dAppNameField

                text: "React App"
            }
            Label {
                text: "DApp URL"
            }
            TextField {
                id: dAppUrlField

                text: "https://react-app.walletconnect.com"
            }
            Label {
                text: "Dapp badge"
            }
            ComboBox {
                id: dAppBadgeComboBox
                model: ["none", "WalletConnect", "BrowserConnect"]
                currentIndex: 1
            }
            Item { Layout.fillHeight: true }
        }
    }

    Timer {
        id: pairedResultTimer

        interval: 1000
        running: false
        repeat: false
        onTriggered: {

        }
    }
}

// category: Wallet
