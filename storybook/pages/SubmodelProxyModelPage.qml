import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import Storybook 1.0

import SortFilterProxyModel 0.2

Item {
    id: root

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
    // Additionally submodel is filtered and sorted via SFPM. Submodel is
    // accessible via "submodel" context property.
    SubmodelProxyModel {
        id: submodelProxyModel

        sourceModel: tokensModel

        delegateModel: SortFilterProxyModel {
            readonly property LeftJoinModel joinModel: LeftJoinModel {
                leftModel: submodel
                rightModel: networksModel

                joinRole: "chainId"
            }

            sourceModel: joinModel

            filters: ExpressionFilter {
                expression: balance >= thresholdSlider.value
            }

            sorters: RoleSorter {
                roleName: "name"
                enabled: sortCheckBox.checked
            }
        }

        submodelRoleName: "balances"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // ListView consuming model don't have to do any transformation
            // of the submodels internally because it's handled externally via
            // SubmodelProxyModel.
            ListView {
                id: listView

                Layout.fillWidth: true
                Layout.fillHeight: true

                reuseItems: true

                ScrollBar.vertical: ScrollBar {}

                clip: true
                spacing: 18

                model: submodelProxyModel

                delegate: ColumnLayout {
                    id: delegateRoot

                    width: ListView.view.width
                    height: 46
                    spacing: 0

                    readonly property var balances: model.balances

                    Label {
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
                            }
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

            ListView {
                Layout.preferredWidth: 150
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

// category: Models
