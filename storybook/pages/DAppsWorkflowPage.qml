import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15
import Qt.labs.settings 1.0
import QtTest 1.15
import QtQml.Models 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Backpressure 0.1
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
import AppLayouts.Wallet.services.dapps.types 1.0

import SortFilterProxyModel 0.2

import AppLayouts.Wallet.panels 1.0
import AppLayouts.Profile.stores 1.0

import mainui 1.0
import shared.stores 1.0
import utils 1.0

Item {
    id: root

    // Needed for DAppsWorkflow->PairWCModal to open its instructions popup
    Popups {
        popupParent: root
        rootStore: QtObject {}
        communityTokensStore: QtObject {}
    }

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
                    loginType: Constants.LoginType.Biometrics
                    selectedAccountAddress: ""
                }
            }
            ColumnLayout {}
        }

        ColumnLayout {
            id: optionsSpace

            RowLayout {
                StatusBaseText { text: "projectId" }
                StatusBaseText {
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

            StatusBaseText { text: "Custom Accounts" }
            StatusTextArea {
                text: settings.customAccounts
                onTextChanged: {
                    settings.customAccounts = text
                    customAccountsModel.clear()
                    let customData = JSON.parse(text)
                    customData.forEach(function(account) {
                        customAccountsModel.append(account)
                    })
                }
                Layout.fillWidth: true
                Layout.maximumHeight: 300
                clip: true
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "grey"
            }

            StatusBaseText { text: "Requests Queue" }

            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(50, contentHeight)
                model: walletConnectService.requestHandler.requestsModel
                delegate: RowLayout {
                    StatusBaseText {
                        text: SQUtils.Utils.elideAndFormatWalletAddress(model.topic, 6, 4)
                        Layout.fillWidth: true
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "grey"
            }

            StatusBaseText { text: "Persisted Sessions" }

            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(100, contentHeight)
                model: sessionsModel
                delegate: RowLayout {
                    StatusBaseText {
                        text: SQUtils.Utils.elideAndFormatWalletAddress(model.topic, 6, 4)
                        Layout.fillWidth: true
                    }
                }
            }

            StatusButton {
                text: qsTr("Clear Persistance")
                visible: sessionsModel.count > 0
                onClicked: {
                    settings.persistedSessions = "[]"
                    d.updateSessionsModelAndAddNewIfNotNull(null)
                }
            }

            // spacer
            ColumnLayout {}

            CheckBox {

                text: "Enable SDK"
                checked: settings.enableSDK
                onCheckedChanged: {
                    settings.enableSDK = checked
                }
            }

            RowLayout {
                StatusBaseText { text: "URI" }
                StatusInput {
                    id: pairUriInput

                    //placeholderText: "Enter WC Pair URI"
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

                        let buttons = InspectionUtils.findVisualsByTypeName(dappsWorkflow.popup, "StatusButton")
                        if (buttons.length === 1) {
                            buttons[0].clicked()
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
                            if (buttons.length === 1 && buttons[0].enabled &&  walletConnectService.wcSDK.sdkReady) {
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

    StatusDialog {
        id: authMockDialog
        title: "Authenticate user"
        visible: false

        property string topic: ""
        property string id: ""

        ColumnLayout {
            RowLayout {
                StatusBaseText { text: "Topic" }
                StatusBaseText { text: authMockDialog.topic }
                StatusBaseText { text: "ID" }
                StatusBaseText { text: authMockDialog.id }
            }
        }
        footer: StatusDialogFooter {
            rightButtons: ObjectModel {
                StatusButton {
                    text: qsTr("Reject")
                    onClicked: {
                        walletConnectService.store.userAuthenticationFailed(authMockDialog.topic, authMockDialog.id)
                        authMockDialog.close()
                    }
                }
                StatusButton {
                    text: qsTr("Authenticate")
                    onClicked: {
                        walletConnectService.store.userAuthenticated(authMockDialog.topic, authMockDialog.id, "0x1234567890", "123")
                        authMockDialog.close()
                    }
                }
            }
        }
    }

    WalletConnectService {
        id: walletConnectService

        wcSDK: WalletConnectSDK {
            active: settings.enableSDK

            projectId: projectIdText.projectId
        }

        store: DAppsStore {
            signal dappsListReceived(string dappsJson)
            signal userAuthenticated(string topic, string id, string password, string pin)
            signal userAuthenticationFailed(string topic, string id)

            function addWalletConnectSession(sessionJson) {
                console.info("Persist Session", sessionJson)

                let session = JSON.parse(sessionJson)
                d.updateSessionsModelAndAddNewIfNotNull(session)

                return true
            }

            function deactivateWalletConnectSession(topic) {
                console.info("Deactivate Persisted Session", topic)

                let sessions = JSON.parse(settings.persistedSessions)
                let newSessions = sessions.filter(function(session) {
                    return session.topic !== topic
                })
                settings.persistedSessions = JSON.stringify(newSessions)
                d.updateSessionsModelAndAddNewIfNotNull(null)
                return true
            }

            function updateWalletConnectSessions(activeTopicsJson) {
                console.info("Update Persisted Sessions", activeTopicsJson)

                let activeTopics = JSON.parse(activeTopicsJson)
                let sessions = JSON.parse(settings.persistedSessions)
                let newSessions = sessions.filter(function(session) {
                    return activeTopics.includes(session.topic)
                })
                settings.persistedSessions = JSON.stringify(newSessions)
                d.updateSessionsModelAndAddNewIfNotNull(null)
                return true
            }

            function getDapps() {
                let dappsJson = JSON.stringify(d.persistedDapps)
                this.dappsListReceived(dappsJson)
                return true
            }

            function authenticateUser(topic, id, address) {
                authMockDialog.topic = topic
                authMockDialog.id = id
                authMockDialog.open()
                return true
            }

            // hardcoded for https://react-app.walletconnect.com/
            function signMessageUnsafe(topic, id, address, password, message) {
                console.info(`calling mocked DAppsStore.signMessageUnsafe(${topic}, ${id}, ${address}, ${password}, ${message})`)
                return "0xc8f39cb4cffa5c4659e0ccc7c417cc61d0cfc9e59de310368ac734065164f5515bfbaf4550d409896f7e2210b82a1cf65edcd77f696b4d3d24477fb81a90af8a1c"
            }

            // hardcoded for https://react-app.walletconnect.com/
            function signMessage(topic, id, address, password, message) {
                console.info(`calling mocked DAppsStore.signMessage(${topic}, ${id}, ${address}, ${password}, ${message})`)
                return "0x0b083acc1b3b612dd38e8e725b28ce9b2dd4936b4cf7922da4e4a3c6f44f7f4f6d3050ccb41455a2b85093f1bfadb10fc6a75d83bb590b2eb70e3447653459701c"
            }

            // hardcoded for https://react-app.walletconnect.com/
            function safeSignTypedData(topic, id, address, password, typedDataJson, chainId, legacy) {
                console.info(`calling mocked DAppsStore.safeSignTypedData(${topic}, ${id}, ${address}, ${password}, ${typedDataJson}, ${chainId}, ${legacy})`)
                return "0xf8ceb3468319cc215523b67c24c4504b3addd9bf8de31c278038d7478c9b6de554f7d8a516cd5d6a066b7d48b81f03d9d6bb7d5d754513c08325674ebcc7efbc1b"
            }

            // hardcoded for https://react-app.walletconnect.com/
            function signTransaction(topic, id, address, chainId, password, tx) {
                console.info(`calling mocked DAppsStore.signTransaction(${topic}, ${id}, ${address}, ${chainId}, ${password}, ${tx})`)
                return "0xf8672a8402fb7acf82520894e2d622c817878da5143bbe06866ca8e35273ba8a80808401546d71a04fc89c2f007c3b27d0fcff07d3e69c29f940967fab4caf525f9af72dadb48befa00c5312a3cb6f50328889ad361a0c88bb9d1b1a4fc510f6783b287930b4e187b5"
            }

            function sendTransaction(topic, id, address, chainId, password, tx) {
                console.info(`calling mocked DAppsStore.sendTransaction(${topic}, ${id}, ${address}, ${chainId}, ${password}, ${tx})`)
                return "0xf8672a8402fb7acf82520894e2d622c817878da5143bbe068"
            }

            function getEstimatedTime(chainId, maxFeePerGas) {
                return Constants.TransactionEstimatedTime.LessThanThreeMins
            }

            function hexToDec(hex) {
                if (hex.length > "0xfffffffffffff".length) {
                    console.warn(`Beware of possible loss of precision converting ${hex}`)
                }
                return parseInt(hex, 16).toString()
            }
        }

        walletRootStore: QObject {
            property var filteredFlatModel: SortFilterProxyModel {
                sourceModel: NetworksModel.flatNetworks
                filters: ValueFilter { roleName: "isTest"; value: settings.testNetworks; }
            }
            property var accounts: customAccountsModel.count > 0 ? customAccountsModel : defaultAccountsModel
            readonly property ListModel nonWatchAccounts: accounts

            function getNetworkShortNames(chainIds) {
                return "eth:oeth:arb"
            }
            readonly property CurrenciesStore currencyStore: CurrenciesStore {}
        }

        onDisplayToastMessage: (message, isErr) => {
            if(isErr) {
                console.log(`Storybook.displayToastMessage(${message}, "", "warning", false, Constants.ephemeralNotificationType.danger, "")`)
                return
            }
            console.log(`Storybook.displayToastMessage(${message}, "", "checkmark-circle", false, Constants.ephemeralNotificationType.success, "")`)
        }
    }


    QObject {
        id: d

        property int activeTestCase: noTestCase

        function startTestCase() {
            d.activeTestCase = settings.testCase
            if(root.visible) {
                dappsWorkflow.popup.open()
            }
        }

        readonly property int noTestCase: 0
        readonly property int openDappsTestCase: 1
        readonly property int openPairTestCase: 2

        ListModel {
            id: sessionsModel
        }

        function updateSessionsModelAndAddNewIfNotNull(newSession) {
            var sessions = JSON.parse(settings.persistedSessions)
            if (!!newSession) {
                sessions.push(newSession)
                settings.persistedSessions = JSON.stringify(sessions)
            }

            sessionsModel.clear()
            d.persistedDapps = []
            sessions.forEach(function(session) {
                sessionsModel.append(session)

                let firstIconUrl = session.peer.metadata.icons.length > 0 ? session.peer.metadata.icons[0] : ""
                let persistedDapp = {
                    "name": session.peer.metadata.name,
                    "url": session.peer.metadata.url,
                    "iconUrl": firstIconUrl,
                    "topic": session.topic
                }
                var found = false
                for (var i = 0; i < d.persistedDapps.length; i++) {
                    if (d.persistedDapps[i].url == persistedDapp.url) {
                        found = true
                        break
                    }
                }
                if (!found) {
                    d.persistedDapps.push(persistedDapp)
                }
            })
        }

        property var persistedDapps: []
        ListModel {
            id: customAccountsModel
        }
        WalletAccountsModel{
            id: defaultAccountsModel
        }
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
        property bool enableSDK: true
        property bool pending : false
        property string customAccounts: "[]"
        property string persistedSessions: "[]"
    }

    Component.onCompleted: {
        d.updateSessionsModelAndAddNewIfNotNull(null)
    }
}

// category: Wallet
// https://www.figma.com/design/HrmZp1y4S77QJezRFRl6ku/dApp-Interactions---Milestone-1?node-id=3649-30334&t=t5qqtR3RITR4yCOx-0
