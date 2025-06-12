import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QtModelsToolkit 1.0

import Storybook 1.0


Control {
    id: root

    font.pixelSize: 16
    padding: 10

    ListModel {
        id: sourceModel

        ListElement {
            symbol: "SNT"
            balance: "4"
        }
        ListElement {
            symbol: "ETH"
            balance: "14"
        }
        ListElement {
            symbol: "ZRX"
            balance: "24"
        }
        ListElement {
            symbol: "DAI"
            balance: "43"
        }
        ListElement {
            symbol: "UNI"
            balance: "2"
        }
        ListElement {
            symbol: "PEPE"
            balance: "1"
        }
    }

    FunctionAggregator {
        id: totalBalanceAggregator

        model: sourceModel
        initialValue: "0"
        roleName: "balance"

        aggregateFunction: (aggr, value) => AmountsArithmetic.sum(
                               AmountsArithmetic.fromString(aggr),
                               AmountsArithmetic.fromString(value)).toString()
    }

    FunctionAggregator {
        id: maxBalanceAggregator

        model: sourceModel
        initialValue: "0"
        roleName: "balance"

        aggregateFunction: (aggr, value) => AmountsArithmetic.cmp(
                               AmountsArithmetic.fromString(aggr),
                               AmountsArithmetic.fromString(value)) > 0
                           ? aggr : value
    }

    FunctionAggregator {
        id: tokensListAggregator

        model: sourceModel
        initialValue: []
        roleName: "symbol"

        aggregateFunction: (aggr, value) => [...aggr, value]
    }

    contentItem: ColumnLayout {
        Label {
            text: "SUMMARY"
            font.bold: true
        }

        Label {
            text: "Total balance: " + totalBalanceAggregator.value
        }

        Label {
            text: "Max balance: " + maxBalanceAggregator.value
        }

        Label {
            text: "Tokens list: " + tokensListAggregator.value
        }

        Item {
            Layout.preferredHeight: 20
        }

        Label {
            text: "MODEL (click rows to change)"
            font.bold: true
        }

        GenericListView {

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: sourceModel

            onRowClicked: {
                if (role === "balance") {
                    const balance = sourceModel.get(index).balance

                    sourceModel.setProperty(index, "balance",
                                            (Number(balance) + 1).toString())
                } else {
                    const symbol = sourceModel.get(index).symbol

                    sourceModel.setProperty(index, "symbol", symbol + "_")
                }
            }

            insetComponent: Button {
                height: 20
                font.pixelSize: 11
                text: "remove"

                onClicked: {
                    sourceModel.remove(model.index)
                }
            }
        }

        Button {
            text: "Add token"

            property int counter: 1

            onClicked: {
                sourceModel.append({
                    symbol: "NEW_" + counter,
                    balance: "" + counter * 2
                })
                counter++
            }
        }
    }
}

// category: Models
