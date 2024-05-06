import QtQuick 2.15
import QtTest 1.15

import StatusQ 0.1 // See #10218

import QtQuick.Controls 2.15

import Storybook 1.0

//import AppLayouts.Wallet.panels 1.0

import AppLayouts.Wallet.services.dapps 1.0

import QtQml.Models 2.15

Item {
    id: root
    width: 600
    height: 400

    // TODO: mock WalletConnectSDK
    // Component {
    //     id: componentUnderTest
    //     DAppsWorkflow {
    //     }
    // }

    // TestCase {
    //     name: "DAppsWorkflow"
    //     when: windowShown

    //     property DAppsWorkflow controlUnderTest: null

    //     function init() {
    //         controlUnderTest = createTemporaryObject(componentUnderTest, root)
    //     }

    //     function test_ClickToOpenAndClosePopup() {
    //         verify(!!controlUnderTest)
    //         waitForRendering(controlUnderTest)

    //         mouseClick(controlUnderTest, Qt.LeftButton)
    //         waitForRendering(controlUnderTest)

    //         let popup = findChild(controlUnderTest, "dappsPopup")
    //         verify(!!popup)
    //         verify(popup.opened)

    //         mouseClick(Overlay.overlay, Qt.LeftButton)
    //         waitForRendering(controlUnderTest)

    //         verify(!popup.opened)
    //     }
    // }

    TestCase {
        name: "ServiceHelpers"

        function test_extractChainsAndAccountsFromApprovedNamespaces() {
            let res = Helpers.extractChainsAndAccountsFromApprovedNamespaces(JSON.parse(`{
                "eip155": {
                    "accounts": [
                        "eip155:1:0x1",
                        "eip155:1:0x2",
                        "eip155:2:0x1",
                        "eip155:2:0x2"
                    ],
                    "chains": [
                        "eip155:1",
                        "eip155:2"
                    ],
                    "events": [
                        "accountsChanged",
                        "chainChanged"
                    ],
                    "methods": [
                        "eth_sendTransaction",
                        "personal_sign"
                    ]
                }
            }`))
            verify(res.chains.length === 2)
            verify(res.accounts.length === 2)
            verify(res.chains[0] === 1)
            verify(res.chains[1] === 2)
            verify(res.accounts[0] === "0x1")
            verify(res.accounts[1] === "0x2")
        }

        readonly property ListModel chainsModel: ListModel {
            ListElement { chainId: 1 }
            ListElement { chainId: 2 }
        }

        readonly property ListModel accountsModel: ListModel {
            ListElement { address: "0x1" }
            ListElement { address: "0x2" }
        }

        function test_buildSupportedNamespacesFromModels() {
            let resStr = Helpers.buildSupportedNamespacesFromModels(chainsModel, accountsModel)
            let jsonObj = JSON.parse(resStr)
            verify(jsonObj.hasOwnProperty("eip155"))
            let eip155 = jsonObj.eip155

            verify(eip155.hasOwnProperty("chains"))
            let chains = eip155.chains
            verify(chains.length === 2)
            verify(chains[0] === "eip155:1")
            verify(chains[1] === "eip155:2")

            verify(eip155.hasOwnProperty("accounts"))
            let accounts = eip155.accounts
            verify(accounts.length === 4)
            for (let chainI = 0; chainI < chainsModel.count; chainI++) {
                for (let accountI = 0; accountI < chainsModel.count; accountI++) {
                    var found = false
                    for (let entry of accounts) {
                        if(entry === `eip155:${chainsModel.get(chainI).chainId}:${accountsModel.get(accountI).address}`) {
                            found = true
                            break
                        }
                    }
                    verify(found, `found ${accountsModel.get(accountI).address} for chain ${chainsModel.get(chainI).chainId}`)
                }
            }

            verify(eip155.hasOwnProperty("methods"))
            verify(eip155.methods.length > 0)
            verify(eip155.hasOwnProperty("events"))
            verify(eip155.events.length > 0)
        }
    }
}
