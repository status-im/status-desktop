import QtQuick 2.15
import QtQuick.Controls 2.15
import QtTest 1.15

import AppLayouts.Wallet.controls 1.0

import utils 1.0

Item {
    id: root

    width: 600
    height: 600

    readonly property var assetsData: [
        {
            tokensKey: "stt_key",
            communityId: "",
            name: "Status Test Token",
            currencyBalanceAsString: "42,23 USD",
            symbol: "STT",
            iconSource: Constants.tokenIcon("STT"),

            balances: [
                {
                    balanceAsString: "0,56",
                    iconUrl: "network/Network=Ethereum"
                }
            ],

            sectionText: "My assets on Mainnet"
        },
        {
            tokensKey: "eth_key",
            communityId: "",
            name: "Ether",
            currencyBalanceAsString: "4 276,86 USD",
            symbol: "ETH",
            iconSource: Constants.tokenIcon("ETH"),

            balances: [
                {
                    balanceAsString: "0,12",
                    iconUrl: "network/Network=Ethereum"
                }
            ],

            sectionText: "My assets on Mainnet"
        },
        {
            tokensKey: "dai_key",
            communityId: "",
            name: "Dai Stablecoin",
            currencyBalanceAsString: "45,92 USD",
            symbol: "DAI",
            iconSource: Constants.tokenIcon("DAI"),
            balances: [],

            sectionText: "Popular assets"
        }
    ]

    ListModel {
        id: assetsModel

        Component.onCompleted: append(assetsData)
    }

    Component {
        id: selectorCmp

        AssetSelector {
            id: selector

            anchors.centerIn: parent
            model: assetsModel

            readonly property SignalSpy selectedSpy: SignalSpy {
                target: selector
                signalName: "selected"
            }
        }
    }

    TestCase {
        name: "AssetSelector"
        when: windowShown

        function test_basic() {
            const selector  = createTemporaryObject(selectorCmp, root)
            selector.nonInteractiveKey = "eth_key"
            selector.sectionProperty = "sectionText"

            compare(selector.isSelected, false)
            waitForRendering(selector)

            verify(selector.width > 0)
            verify(selector.height > 0)

            mouseClick(selector)

            const panel = findChild(selector.Overlay.overlay, "searchableAssetsPanel")
            compare(panel.model, selector.model)
            compare(panel.nonInteractiveKey, selector.nonInteractiveKey)
            compare(panel.sectionProperty, selector.sectionProperty)
        }

        function test_basicSelection() {
            const selector = createTemporaryObject(selectorCmp, root)
            const button = selector.contentItem

            compare(selector.isSelected, false)
            compare(button.selected, false)
            waitForRendering(selector)

            // click to open popup
            mouseClick(selector)
            compare(selector.isSelected, false)
            compare(button.selected, false)

            const listView = findChild(selector.Overlay.overlay, "assetsListView")
            verify(listView)

            compare(listView.count, root.assetsData.length)
            waitForRendering(listView)

            const delegate1 = listView.itemAtIndex(0)
            const delegate2 = listView.itemAtIndex(1)

            verify(delegate1)
            verify(delegate2)

            // click on delegate to select
            mouseClick(delegate2)
            compare(selector.isSelected, true)
            compare(selector.selectedSpy.count, 1)
            compare(selector.selectedSpy.signalArguments[0][0], "eth_key")
            compare(button.selected, true)
            compare(button.name, "ETH")
            compare(button.icon, Constants.tokenIcon("ETH"))

            // popup should be closed, content not accessible
            verify(!findChild(selector.Overlay.overlay, "searchableAssetsPanel"))

            // reopen popup
            mouseClick(selector)
            const panel = findChild(selector.Overlay.overlay, "searchableAssetsPanel")
            verify(panel)

            compare(panel.highlightedKey, "eth_key")
            compare(panel.nonInteractiveKey, "")
        }

        function test_resetSelection() {
            const selector = createTemporaryObject(selectorCmp, root)
            const button = selector.contentItem

            compare(selector.isSelected, false)
            compare(button.selected, false)
            waitForRendering(selector)

            // click to open popup
            mouseClick(selector)

            const listView = findChild(selector.Overlay.overlay, "assetsListView")
            verify(listView)

            waitForRendering(listView)
            const delegate2 = listView.itemAtIndex(1)

            verify(delegate2)

            // click on delegate to select
            mouseClick(delegate2)
            compare(selector.isSelected, true)

            // reset
            selector.reset()
            compare(selector.isSelected, false)
            compare(button.selected, false)

            // reopen popup
            mouseClick(selector)
            const panel = findChild(selector.Overlay.overlay, "searchableAssetsPanel")
            verify(panel)

            compare(panel.highlightedKey, "")
            compare(panel.nonInteractiveKey, "")
        }

        function test_customSelection() {
            const selector  = createTemporaryObject(selectorCmp, root)
            const button = selector.contentItem

            compare(selector.isSelected, false)
            waitForRendering(selector)

            const imageUrl = Constants.tokenIcon("DAI")
            selector.setCustom("Custom", imageUrl, "custom_key")

            compare(selector.isSelected, true)
            compare(selector.selectedSpy.count, 0)
            compare(button.selected, true)
            compare(button.name, "Custom")
            compare(button.icon, Constants.tokenIcon("DAI"))
        }

        function test_searchNotPersistent() {
            const selector = createTemporaryObject(selectorCmp, root)
            const button = selector.contentItem

            compare(selector.isSelected, false)
            compare(button.selected, false)
            waitForRendering(selector)

            // click to open popup
            mouseClick(selector)

            const panel = findChild(selector.Overlay.overlay, "searchableAssetsPanel")
            verify(panel)

            const searchBox = findChild(panel, "searchBox")
            verify(searchBox)

            compare(searchBox.text, "")
            searchBox.text = "seach string"
            keyClick(Qt.Key_Escape)

            // click to re-open popup
            mouseClick(selector)
            {
                const searchBox = findChild(panel, "searchBox")
                verify(searchBox)
                compare(searchBox.text, "")
            }
        }
    }
}
