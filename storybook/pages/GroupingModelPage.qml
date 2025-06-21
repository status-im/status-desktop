import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QtModelsToolkit 1.0
import SortFilterProxyModel 0.2

Pane {
    id: root

    ListModel {
        id: collectiblesModel

        Component.onCompleted: {
            const randomInt = max => Math.floor(Math.random() * max)
            const data = []

            for (let i = 0; i < 1000; i++) {
                const collectionName = "collection_" + i
                const tokensCount = randomInt(10) + 1

                for (let j = 0; j < tokensCount; j++) {
                    data.push({
                        collectionName,
                        tokenName: "token_" + j,
                        tokenValue: randomInt(200)
                    })
                }
            }

            append(data)
        }
    }

    SortFilterProxyModel {
        id: sfpm

        sourceModel: collectiblesModel

        filters: RangeFilter {
            roleName: "tokenValue"
            minimumValue: slider.value
        }
    }

    GroupingModel {
        id: groupingModel

        sourceModel: sfpm
        groupingRoleName: "collectionName"
        submodelRoleName: "collectibles"
    }

    ColumnLayout {
        anchors.fill: parent

        Label {
            Layout.fillWidth: true
            Layout.bottomMargin: 10

            wrapMode: Text.Wrap
            text: "<b>Description</b>: flat model with roles 'collectionName',"
                  + " 'tokenName' and 'tokenValue' is filtered by token value"
                  + " and grouped by collection name"
        }

        Label {
            text: "source model count: " + collectiblesModel.count
        }

        Label {
            text: "filtered model count: " + sfpm.count
        }

        Label {
            text: "grouped model count: " + listView.count
        }

        RowLayout {
            Layout.fillHeight: false

            Label {
                text: "Token value threshold"
            }

            Slider {
                id: slider

                stepSize: 1
                value: 100
                from: 0
                to: 200
            }

            Label {
                text: slider.value
            }
        }

        ListView {
            id: listView

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: groupingModel
            spacing: 5
            clip: true

            ScrollBar.vertical: ScrollBar {}

            delegate: RowLayout {
                id: delegateRoot

                width: ListView.view.width

                readonly property var collectibles: model.collectibles

                Label {
                    text: model.collectionName
                }

                ListView {
                    clip: true
                    orientation: ListView.Horizontal

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    model: delegateRoot.collectibles

                    delegate: Label {
                        text: `${model.tokenName} (val: ${model.tokenValue})`
                        color: "darkred"
                    }
                }
            }
        }
    }
}

// category: Models
