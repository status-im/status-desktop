import QtQuick
import QtTest

import AppLayouts.Wallet.panels

import StatusQ.Core.Theme

import Storybook

import utils

Item {
    id: root

    width: 600
    height: 400

    Component {
        id: panelCmp

        SearchableAssetsPanel {
            id: panel

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
                        },
                        {
                            balanceAsString: "0,22",
                            iconUrl: "network/Network=Arbitrum"
                        },
                        {
                            balanceAsString: "0,12",
                            iconUrl: "network/Network=Optimism"
                        }
                    ],

                    sectionName: ""
                },
                {
                    tokensKey: "dai_key",
                    communityId: "",
                    name: "Dai Stablecoin",
                    currencyBalanceAsString: "45,92 USD",
                    symbol: "DAI",
                    iconSource: Constants.tokenIcon("DAI"),
                    balances: [],

                    sectionName: "Popular assets"
                },
                {
                    tokensKey: "zrx_key",
                    communityId: "",
                    name: "0x",
                    currencyBalanceAsString: "41,22 USD",
                    symbol: "ZRX",
                    iconSource: Constants.tokenIcon("ZRX"),
                    balances: [],

                    sectionName: "Popular assets"
                }
            ]

            model: ListModel {
                Component.onCompleted: append(panel.assetsData)
            }

            readonly property SignalSpy selectedSpy: SignalSpy {
                target: panel
                signalName: "selected"
            }
        }
    }

    TestCase {
        name: "SearchableAssetsPanel"
        when: windowShown

        function test_sections() {
            const control = createTemporaryObject(panelCmp, root)

            const listView = findChild(control, "assetsListView")
            waitForRendering(listView)

            compare(listView.count, 3)

            const delegate1 = listView.itemAtIndex(0)
            const delegate2 = listView.itemAtIndex(1)
            const delegate3 = listView.itemAtIndex(2)

            verify(delegate1)
            verify(delegate2)
            verify(delegate3)

            compare(delegate1.ListView.section, "")
            compare(delegate2.ListView.section, "Popular assets")
            compare(delegate3.ListView.section, "Popular assets")

            const sectionDelegate = TestUtils.findTextItem(listView, "Popular assets")
            verify(sectionDelegate)
        }

        function test_withNoSectionsModel() {
            const model = createTemporaryQmlObject("import QtQml.Models; ListModel {}", root)
            const control = createTemporaryObject(panelCmp, root, { model })

            model.append(control.assetsData.map(
                e => ({
                        tokensKey: e.tokensKey,
                        communityId: e.communityId,
                        name: e.name,
                        currencyBalanceAsString: e.currencyBalanceAsString,
                        symbol: e.symbol,
                        iconSource: e.iconSource,
                        balances: e.balances
                    })
                )
            )

            const listView = findChild(control, "assetsListView")
            waitForRendering(listView)
            compare(listView.count, 3)

            const delegate1 = listView.itemAtIndex(0)
            const delegate2 = listView.itemAtIndex(1)
            const delegate3 = listView.itemAtIndex(2)

            verify(delegate1)
            verify(delegate2)
            verify(delegate3)

            compare(delegate1.ListView.section, "")
            compare(delegate2.ListView.section, "")
            compare(delegate3.ListView.section, "")
        }

        function test_search() {
            const control = createTemporaryObject(panelCmp, root)

            const listView = findChild(control, "assetsListView")
            waitForRendering(listView)

            const searchBox = findChild(control, "searchBox")

            {
                searchBox.text = "Status"
                waitForRendering(listView)

                compare(listView.count, 1)
                const delegate1 = listView.itemAtIndex(0)
                verify(delegate1)
                compare(delegate1.name, "Status Test Token")
                verify(delegate1.isAutoHovered)
                compare(delegate1.background.color, Theme.palette.baseColor2)
            }
            {
                searchBox.text = "zrx"
                waitForRendering(listView)

                compare(listView.count, 1)
                const delegate1 = listView.itemAtIndex(0)
                verify(delegate1)
                compare(delegate1.name, "0x")
                verify(delegate1.isAutoHovered)
                compare(delegate1.background.color, Theme.palette.baseColor2)
            }
            {
                control.clearSearch()
                waitForRendering(listView)

                compare(searchBox.text, "")
                compare(listView.count, 3)
            }
        }

        function test_highlightedKey() {
            const control = createTemporaryObject(panelCmp, root)
            control.highlightedKey = "dai_key"

            const listView = findChild(control, "assetsListView")
            waitForRendering(listView)

            compare(listView.count, 3)

            const delegate1 = listView.itemAtIndex(0)
            const delegate2 = listView.itemAtIndex(1)
            const delegate3 = listView.itemAtIndex(2)

            verify(delegate1)
            verify(delegate2)
            verify(delegate3)

            compare(delegate1.highlighted, false)
            compare(delegate2.highlighted, true)
            compare(delegate3.highlighted, false)
        }

        function test_nonInteractiveKey() {
            const control = createTemporaryObject(panelCmp, root)
            control.nonInteractiveKey = "dai_key"

            const listView = findChild(control, "assetsListView")
            waitForRendering(listView)

            compare(listView.count, 3)

            const delegate1 = listView.itemAtIndex(0)
            const delegate2 = listView.itemAtIndex(1)
            const delegate3 = listView.itemAtIndex(2)

            verify(delegate1)
            verify(delegate2)
            verify(delegate3)

            compare(delegate1.enabled, true)
            compare(delegate2.enabled, false)
            compare(delegate3.enabled, true)

            mouseClick(delegate1)
            compare(control.selectedSpy.count, 1)

            mouseClick(delegate2)
            compare(control.selectedSpy.count, 1)

            mouseClick(delegate3)
            compare(control.selectedSpy.count, 2)
        }
    }
}
