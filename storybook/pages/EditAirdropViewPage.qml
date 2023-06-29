import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Communities.views 1.0
import AppLayouts.Communities.controls 1.0

import Storybook 1.0
import Models 1.0

import SortFilterProxyModel 0.2
import utils 1.0

SplitView {
    orientation: Qt.Vertical
    SplitView.fillWidth: true

    property bool globalUtilsReady: false
    property bool mainModuleReady: false

    Logs { id: logs }

    QtObject {
        function isCompressedPubKey(publicKey) {
            return true
        }

        function getCompressedPk(publicKey) {
            return "compressed_" + publicKey
        }

        function getColorId(publicKey) {
            return Math.floor(Math.random() * 10)
        }

        Component.onCompleted: {
            Utils.globalUtilsInst = this
            globalUtilsReady = true

        }
        Component.onDestruction: {
            globalUtilsReady = false
            Utils.globalUtilsInst = {}
        }
    }

    QtObject {
        function getContactDetailsAsJson() {
            return JSON.stringify({ ensVerified: true })
        }

        Component.onCompleted: {
            mainModuleReady = true
            Utils.mainModuleInst = this
        }
        Component.onDestruction: {
            mainModuleReady = false
            Utils.mainModuleInst = {}
        }
    }

    ListModel {
        id: members

        property int counter: 0

        function addMember() {
            const i = counter++
            const key = `pub_key_${i}`

            const firstLetters = ["a", "b", "c", "d"]
            const firstLetterIdx = Math.min(Math.floor(i / firstLetters.length),
                                            firstLetters.length - 1)
            const firstLetter = firstLetters[firstLetterIdx]

            append({
                alias: "",
                colorId: "1",
                displayName: `${firstLetter}contact ${i}`,
                ensName: "",
                icon: "",
                isContact: true,
                localNickname: "",
                onlineStatus: 1,
                pubKey: key,
                isVerified: true,
                isUntrustworthy: false
            })
        }

        Component.onCompleted: {
            for (let i = 0; i < 33; i++)
                addMember()
        }
    }

    Timer {
        id: feesCalculationTimer

        interval: 2000

        property var response

        function requestMockedFees(contractKeysAndAmounts) {
            const fees = []

            function createAmount(amount, symbol, decimals) {
                return {
                    amount, symbol,
                    displayDecimals: decimals, stripTrailingZeroes: false
                }
            }

            contractKeysAndAmounts.forEach(entry => {
                fees.push({
                    ethFee: createAmount(0.0002120115, "ETH", 4),
                    fiatFee: createAmount(123.15, "USD", 2),
                    errorCode: 0,
                    contractUniqueKey: entry.contractUniqueKey
                })
            })

            response = {
                fees, errorCode: feesErrorsButtonGroup.checkedButton.code,
                totalEthFee: createAmount(0.0002120115 * fees.length, "ETH", 4),
                totalFiatFee: createAmount(123.15 * fees.length, "USD", 2)
            }

            restart()
        }

        onTriggered: {
            if (!loader.item)
                return

            const view = loader.item
            view.airdropFees = response
        }
    }

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Loader {
            id: loader

            anchors.fill: parent
            active: globalUtilsReady && mainModuleReady

            sourceComponent: EditAirdropView {
                id: editAirdropView

                CollectiblesModel {
                    id: collectiblesModel
                }

                SortFilterProxyModel {
                    id: collectiblesModelWithSupply

                    sourceModel: collectiblesModel

                    proxyRoles: [
                        ExpressionRole {
                            name: "supply"
                            expression: ((model.index + 1) * 115).toString()
                        },
                        ExpressionRole {
                            name: "infiniteSupply"
                            expression: !(model.index % 4)
                        },
                        ExpressionRole {
                            name: "accountName"
                            expression: "StatusAccount"
                        },
                        ExpressionRole {
                            name: "contractUniqueKey"
                            expression: "contractUniqueKey_" + model.index
                        },
                        ExpressionRole {
                            name: "chainName"
                            expression: model.index ? "Optimism" : "Arbitrum"
                        },
                        ExpressionRole {
                            readonly property string icon1: "network/Network=Optimism"
                            readonly property string icon2: "network/Network=Arbitrum"

                            name: "chainIcon"
                            expression: model.index ? icon1 : icon2
                        }
                    ]

                    filters: ValueFilter {
                        roleName: "category"
                        value: TokenCategories.Category.Community
                    }

                    Component.onCompleted: {
                        Qt.callLater(() => editAirdropView.collectiblesModel = this)
                    }
                }

                AssetsModel {
                    id: assetsModel
                }

                SortFilterProxyModel {
                    id: assetsModelWithSupply

                    sourceModel: assetsModel

                    proxyRoles: [
                        ExpressionRole {
                            name: "supply"
                            expression: ((model.index + 1) * 258).toString()
                        },
                        ExpressionRole {
                            name: "infiniteSupply"
                            expression: !(model.index % 4)
                        },
                        ExpressionRole {
                            name: "accountName"
                            expression: "StatusAccount"
                        },
                        ExpressionRole {
                            name: "contractUniqueKey"
                            expression: "contractUniqueKey_" + model.index
                        },
                        ExpressionRole {
                            name: "chainName"
                            expression: model.index ? "Ethereum Mainnet" : "Goerli"
                        },
                        ExpressionRole {
                            readonly property string icon1: "network/Network=Ethereum"
                            readonly property string icon2: "network/Network=Testnet"

                            name: "chainIcon"
                            expression: model.index ? icon1 : icon2
                        }
                    ]

                    filters: ValueFilter {
                        roleName: "category"
                        value: TokenCategories.Category.Community
                    }

                    Component.onCompleted: {
                        Qt.callLater(() => editAirdropView.assetsModel = this)
                    }
                }

                assetsModel: AssetsModel {}
                collectiblesModel: CollectiblesModel {}
                membersModel: members
                communityDetails: QtObject {
                    readonly property string name: "Socks"
                    readonly property string id: "SOCKS"
                    readonly property string image: ModelsData.icons.socks
                    readonly property string color: "red"
                    readonly property bool owner: true
                }

                onAirdropClicked: {
                    logs.logEvent("EditAirdropView::airdropClicked",
                                  ["airdropTokens", "addresses", "membersPubKeys"],
                                  arguments)
                }

                onAirdropFeesRequested: {
                    logs.logEvent("EditAirdropView::airdropFeesRequested",
                                  ["contractKeysAndAmounts", "addresses"],
                                  arguments)

                    feesCalculationTimer.requestMockedFees(contractKeysAndAmounts)
                }
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 160

        logsView.logText: logs.logText

        ColumnLayout {
            TextEdit {
                readOnly: true
                selectByMouse: true
                text: "valid address: 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc4"
            }

            MenuSeparator {}

            ButtonGroup {
                id: feesErrorsButtonGroup

                buttons: feesErrorsRow.children
            }

            RowLayout {
                id: feesErrorsRow

                Label {
                    text: "Fees calculation errors:"
                }

                RadioButton {
                    readonly property int code: Constants.ComputeFeeErrorCode.Success
                    text: `Success (${code})`
                    checked: true
                }

                RadioButton {
                    readonly property int code: Constants.ComputeFeeErrorCode.Infura
                    text: `Infura (${code})`
                }

                RadioButton {
                    readonly property int code: Constants.ComputeFeeErrorCode.Balance
                    text: `Balance (${code})`
                }

                RadioButton {
                    readonly property int code: Constants.ComputeFeeErrorCode.Other
                    text: `Other (${code})`
                }
            }
        }
    }
}
