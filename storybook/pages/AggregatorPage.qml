import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1

Item {
    id: root

    QtObject {
        id: d

        readonly property string balanceRoleName: "balance"
        property string roleName: balanceRoleName
    }

    ListModel {
        id: srcModel

        ListElement {
            key: "ETH"

            balances: [
                ListElement { chainId: "1"; balance: 3 },
                ListElement { chainId: "2"; balance: 4 },
                ListElement { chainId: "31"; balance: 2 }
            ]
        }

        ListElement {
            key: "SNT"

            balances: [
                ListElement { chainId: "2"; balance: 42 }
            ]
        }

        ListElement {
            key: "DAI"

            balances: [
                ListElement { chainId: "1";  balance: 4 },
                ListElement { chainId: "3"; balance: 9 }
            ]
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            border.color: "gray"

            ListView {
                anchors.fill: parent
                anchors.margins: 10

                model: srcModel
                spacing: 10

                header: Label {
                    height: implicitHeight * 2
                    text: `Source model (${srcModel.count})`

                    font.bold: true
                    color: "blue"

                    verticalAlignment: Text.AlignVCenter
                }

                ScrollBar.vertical: ScrollBar {}

                delegate: ColumnLayout {
                    height: implicitHeight
                    spacing: 0

                    Label {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 4

                        text: `KEY: ${model.key}`
                        font.bold: true
                    }
                    Label {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 4

                        text: `Total balances: ${aggregator.value}`
                        font.bold: true
                        color: "red"
                    }
                    ListView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: childrenRect.height

                        model: balances
                        delegate: Label {
                            height: implicitHeight
                            width: ListView.view.width
                            text: `chainID: ${model.chainId}, balance: ${model.balance}`
                        }


                    }
                    SumAggregator {
                        id: aggregator

                        model: balances
                        roleName: d.roleName
                    }
                }
            }
        }

        RowLayout {
            Button {
                id: addRows
                text: "Add rows"
                onClicked: {
                    srcModel.get(0).balances.append( {"chainId": "1",  "balance": Math.random()} )
                    srcModel.get(1).balances.append( {"chainId": "22",  "balance": Math.random()} )
                    srcModel.get(2).balances.append( {"chainId": "34",  "balance": Math.random()} )
                }
            }
            Button {
                id: removeRows
                text: "Remove rows"
                onClicked: {
                    if(srcModel.get(0).balances.count > 1)
                        srcModel.get(0).balances.remove(0)
                    if(srcModel.get(1).balances.count > 1)
                        srcModel.get(1).balances.remove(0)
                    if(srcModel.get(2).balances.count > 1)
                        srcModel.get(2).balances.remove(0)
                }
            }
            Button {
                id: resetModel
                text: "Reset model"
                onClicked: {
                    srcModel.get(0).balances.clear()
                    srcModel.get(1).balances.clear()
                    srcModel.get(2).balances.clear()
                }
            }
            Button {
                id: changeData
                text: "Change data"
                onClicked: {
                    srcModel.get(0).balances.get(0).balance = Math.random()
                    srcModel.get(1).balances.get(0).balance = Math.random()
                    srcModel.get(2).balances.get(0).balance = Math.random()
                }
            }
            Button {
                id: changeRoleName
                text: "Change role name"

                onClicked: {
                    if(d.roleName === d.balanceRoleName)
                        d.roleName = "chainId"
                    else
                        d.roleName = d.balanceRoleName
                }
            }
        }
    }
}

// category: Models
