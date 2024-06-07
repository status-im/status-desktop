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
import StatusQ.Core.Utils 0.1 as SQUtils

import Models 1.0
import Storybook 1.0

import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.services.dapps 1.0

import SortFilterProxyModel 0.2

import AppLayouts.Wallet.panels 1.0
import AppLayouts.Profile.stores 1.0

import utils 1.0
import shared.stores 1.0

Item {
    id: root

    // qml Splitter
    SplitView {
        anchors.fill: parent

        ColumnLayout {
            SplitView.fillWidth: true

            Rectangle {
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: dappsWorkflow.implicitHeight + 20
                Layout.preferredHeight: dappsWorkflow.implicitHeight + 20

                border.color: "blue"
                border.width: 1

                DAppsWorkflow {
                    id: dappsWorkflow

                    anchors.centerIn: parent

                    spacing: 8

                    wcService: walletConnectService
                }
            }
            ColumnLayout {}
        }

        ColumnLayout {
            id: optionsSpace

            RowLayout {
                Text { text: "projectId" }
                Text {
                    id: projectIdText
                    readonly property string projectId: SystemUtils.getEnvVar("WALLET_CONNECT_PROJECT_ID")
                    text: SQUtils.Utils.elideText(projectId, 3)
                    font.bold: true
                }
            }

            CheckBox {

                text: "Testnet Mode"
                checked: settings.testNetworks
                onCheckedChanged: {
                    settings.testNetworks = checked
                }
            }

            // spacer
            ColumnLayout {}

            RowLayout {
                Text { text: "URI" }
                TextField {
                    id: pairUriInput

                    placeholderText: "Enter WC Pair URI"
                    text: settings.pairUri
                    onTextChanged: {
                        settings.pairUri = text
                    }

                    Layout.fillWidth: true
                }
            }

            ComboBox {
                model: [{testCase: d.noTestCase, name: "No Test Case"},
                        {testCase: d.openDappsTestCase, name: "Open dApps"},
                        {testCase: d.openPairTestCase, name: "Open Pair"}
                ]
                textRole: "name"
                valueRole: "testCase"
                currentIndex: settings.testCase
                onCurrentValueChanged: {
                    settings.testCase = currentValue
                    if (currentValue !== d.noTestCase) {
                        d.startTestCase()
                    }
                }

                Connections {
                    target: dappsWorkflow

                    // If Open Pair workflow if selected in the side bar
                    function onDappsListReady() {
                        if (d.activeTestCase < d.openPairTestCase)
                            return

                        let items = InspectionUtils.findVisualsByTypeName(dappsWorkflow, "DAppsListPopup")
                        if (items.length === 1) {
                            let buttons = InspectionUtils.findVisualsByTypeName(items[0], "StatusButton")
                            if (buttons.length === 1) {
                                buttons[0].clicked()
                            }
                        }
                    }

                    function onPairWCReady() {
                        if (d.activeTestCase < d.openPairTestCase)
                            return

                        if (pairUriInput.text.length > 0) {
                            let items = InspectionUtils.findVisualsByTypeName(dappsWorkflow, "StatusBaseInput")
                            if (items.length === 1) {
                                items[0].text = pairUriInput.text

                                clickDoneIfSDKReady()
                            }
                        }
                    }

                    function clickDoneIfSDKReady() {
                        if (d.activeTestCase < d.openPairTestCase) {
                            return
                        }

                        let modals = InspectionUtils.findVisualsByTypeName(dappsWorkflow, "PairWCModal")
                        if (modals.length === 1) {
                            let buttons = InspectionUtils.findVisualsByTypeName(modals[0].footer, "StatusButton")
                            if (buttons.length === 1 && walletConnectService.wcSDK.sdkReady) {
                                d.activeTestCase = d.noTestCase
                                buttons[0].clicked()
                                return
                            }
                        }

                        Backpressure.debounce(dappsWorkflow, 250, clickDoneIfSDKReady)()
                    }
                }
            }
        }
    }

    WalletConnectService {
        id: walletConnectService

        wcSDK: WalletConnectSDK {
            active: true

            projectId: projectIdText.projectId
        }

        store: DAppsStore {
            signal dappsListReceived(string dappsJson)

            function addWalletConnectSession(sessionJson) {
                console.info("Persist Session", sessionJson)

                let session = JSON.parse(sessionJson)

                let firstIconUrl = session.peer.metadata.icons.length > 0 ? session.peer.metadata.icons[0] : ""
                let persistedDapp = {
                    "name": session.peer.metadata.name,
                    "url": session.peer.metadata.url,
                    "iconUrl": firstIconUrl
                }
                d.persistedDapps.push(persistedDapp)
            }

            function getDapps() {
                this.dappsListReceived(JSON.stringify(d.persistedDapps))
                return true
            }
        }

        walletStore: WalletStore {
            property var flatNetworks: SortFilterProxyModel {
                sourceModel: NetworksModel.flatNetworks
                filters: ValueFilter { roleName: "isTest"; value: settings.testNetworks; }
            }
            property var accounts:  WalletAccountsModel{}
        }
    }


    QtObject {
        id: d

        property int activeTestCase: noTestCase

        function startTestCase() {
            d.activeTestCase = settings.testCase
            if(root.visible) {
                dappsWorkflow.clicked()
            }
        }

        readonly property int noTestCase: 0
        readonly property int openDappsTestCase: 1
        readonly property int openPairTestCase: 2

        property var persistedDapps: [
            {"name":"Test dApp 1", "url":"https://dapp.test/1","iconUrl":"https://se-sdk-dapp.vercel.app/assets/eip155:1.png"},
            {"name":"Test dApp 2", "url":"https://dapp.test/2","iconUrl":"https://react-app.walletconnect.com/assets/eip155-1.png"},
            {"name":"Test dApp 3", "url":"https://dapp.test/3","iconUrl":"https://react-app.walletconnect.com/assets/eip155-1.png"},
            {"name":"Test dApp 4 - very long name !!!!!!!!!!!!!!!!", "url":"https://dapp.test/4","iconUrl":"https://react-app.walletconnect.com/assets/eip155-1.png"},
            {"name":"Test dApp 5 - very long url", "url":"https://dapp.test/very_long/url/unusual","iconUrl":"https://react-app.walletconnect.com/assets/eip155-1.png"},
            {"name":"Test dApp 6", "url":"https://dapp.test/6","iconUrl":"https://react-app.walletconnect.com/assets/eip155-1.png"}
        ]
    }

    onVisibleChanged: {
        if (visible && d.activeTestCase !== d.noTestCase) {
            d.startTestCase()
        }
    }

    Settings {
        id: settings

        property int testCase: d.noTestCase
        property string pairUri: ""
        property bool testNetworks: false
    }
}

// category: Wallet
