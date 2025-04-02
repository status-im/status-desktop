import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1

import SortFilterProxyModel 0.2

Item {
    id: root

    readonly property string intro:
        "The example uses two source models. The first model contains networks"
        + " (id and metadata such as name and color), visible on the left. The"
        + " second model contains tokens metadata and their balances per"
        + " network in the submodel (network id, balance).\n"
        + "The ObjectProxyModel wrapping the tokens model joins the submodels"
        + " to the network model. It also provides filtering and sorting via"
        + " SFPM (slider and checkbox below). Additionally, ObjectProxyModel"
        + " calculates the summary balance and issues it as a role in the"
        + " top-level model (via SumAggregator). This sum is then used to"
        + " dynamically sort the tokens model.\nClick on balances to increase"
        + " the amount."

    readonly property int numberOfTokens: 2000

    readonly property var colors: [
        "purple", "lightgreen", "red", "blue", "darkgreen"
    ]

    function getRandomInt(max) {
      return Math.floor(Math.random() * max);
    }

    ListModel {
        id: networksModel

        ListElement {
            chainId: "1"
            name: "Mainnet"
            color: "purple"
        }
        ListElement {
            chainId: "2"
            name: "Optimism"
            color: "lightgreen"
        }
        ListElement {
            chainId: "3"
            name: "Status"
            color: "red"
        }
        ListElement {
            chainId: "4"
            name: "Abitrum"
            color: "blue"
        }
        ListElement {
            chainId: "5"
            name: "Sepolia"
            color: "darkgreen"
        }
    }

    ListModel {
        id: tokensModel

        Component.onCompleted: {
            // Populate model with given number of tokens containing random
            // balances
            const numberOfTokens = root.numberOfTokens
            const tokens = []

            const chainIds = []

            for (let n = 0; n < networksModel.count; n++)
                chainIds.push(networksModel.get(n).chainId)

            for (let i = 0; i < numberOfTokens; i++) {
                const balances = []
                const numberOfBalances = 1 + getRandomInt(networksModel.count)
                const chainIdsCpy = [...chainIds]

                for (let i = 0; i < numberOfBalances; i++) {
                    const chainId = chainIdsCpy.splice(
                                      getRandomInt(chainIdsCpy.length), 1)[0]

                    balances.push({
                        chainId: chainId,
                        balance: 1 + getRandomInt(200)
                    })
                }

                tokens.push({ name: `Token ${i + 1}`, balances })
            }

            append(tokens)
        }
    }

    // Proxy model joining networksModel to submodels under "balances" role.
    // Additionally submodel is filtered and sorted via SFPM. All roles declared
    // as "expectedRoles" are accessible via "model" context property.
    ObjectProxyModel {
        id: objectProxyModel

        sourceModel: tokensModel

        delegate: SortFilterProxyModel {
            id: delegateRoot

            // properties exposed as roles to the top-level model
            readonly property var balancesCount: model.balances.count
            readonly property int sum: aggregator.value
            readonly property SortFilterProxyModel balances: this

            sourceModel: joinModel

            filters: FastExpressionFilter {
                expression: balance >= thresholdSlider.value

                expectedRoles: "balance"
            }

            sorters: RoleSorter {
                roleName: "name"
                enabled: sortCheckBox.checked
            }

            readonly property LeftJoinModel joinModel: LeftJoinModel {
                leftModel: model.balances
                rightModel: networksModel

                joinRole: "chainId"
            }

            readonly property SumAggregator aggregator: SumAggregator {
                id: aggregator

                model: delegateRoot
                roleName: "balance"
            }
        }

        exposedRoles: ["balances", "balancesCount", "sum"]
        expectedRoles: ["balances"]
    }

    SortFilterProxyModel {
        id: sortBySumProxy

        sourceModel: objectProxyModel

        sorters: RoleSorter {
            roleName: "sum"
            ascendingOrder: false
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            lineHeight: 1.2
            text: root.intro
        }

        MenuSeparator {
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                Layout.preferredWidth: 110
                Layout.leftMargin: 10
                Layout.fillHeight: true

                spacing: 20

                model: networksModel

                delegate: ColumnLayout {
                    width: ListView.view.width

                    Label {
                        Layout.fillWidth: true
                        text: model.name
                        font.bold: true
                    }

                    Rectangle {
                        Layout.preferredWidth: changeColorButton.width
                        Layout.preferredHeight: 10

                        color: model.color
                    }

                    Button {
                        id: changeColorButton

                        text: "Change color"

                        onClicked: {
                            const currentIdx = root.colors.indexOf(model.color)
                            const numberOfColors = root.colors.length
                            const nextIdx = (currentIdx + 1) % numberOfColors

                            networksModel.setProperty(model.index, "color",
                                                      root.colors[nextIdx])
                        }
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                Layout.rightMargin: 20

                color: "lightgray"
            }

            // ListView consuming model don't have to do any transformation
            // of the submodels internally because it's handled externally via
            // ObjectProxyModel.
            ListView {
                id: listView

                Layout.fillWidth: true
                Layout.fillHeight: true

                reuseItems: true

                ScrollBar.vertical: ScrollBar {}

                clip: true
                spacing: 18

                model: sortBySumProxy

                delegate: ColumnLayout {
                    id: delegateRoot

                    width: ListView.view.width
                    height: 46
                    spacing: 0

                    readonly property var balances: model.balances

                    Label {
                        id: tokenLabel

                        Layout.fillWidth: true
                        text: model.name
                        font.bold: true
                    }

                    RowLayout {
                        spacing: 14

                        Layout.fillWidth: true

                        Repeater {
                            model: delegateRoot.balances

                            Rectangle {
                                width: label.implicitWidth * 1.5
                                height: label.implicitHeight * 2

                                color: "transparent"
                                border.width: 2
                                border.color: model.color

                                Label {
                                    id: label

                                    anchors.centerIn: parent

                                    text: `${model.name} (${model.balance})`
                                    font.pixelSize: 10
                                }

                                StatusMouseArea {
                                    anchors.fill: parent

                                    onClicked: {
                                        const item = ModelUtils.getByKey(
                                                       tokensModel, "name", tokenLabel.text)
                                        const index = ModelUtils.indexOf(
                                                        item.balances, "chainId", model.chainId)

                                        item.balances.setProperty(
                                                    index, "balance",
                                                    item.balances.get(index).balance + 1)
                                    }
                                }
                            }
                        }

                        Label {
                            text: model.balancesCount + " / " + model.sum
                        }
                    }
                }
            }
        }

        MenuSeparator {
            Layout.fillWidth: true
        }

        RowLayout {
            Label {
                text: `Number of tokens: ${listView.count}, minimum balance:`
            }

            Slider {
                id: thresholdSlider

                from: 0
                to: 201
                stepSize: 1
            }

            Label {
                text: thresholdSlider.value
            }

            CheckBox {
                id: sortCheckBox

                text: "sort networks by name"
            }
        }
    }
}
