import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.popups 1.0
import shared.stores 1.0

Item {
    id: root

    property var tokensModel

    signal mintCollectible(string address, string name, string symbol, string description, int supply,
                           bool infiniteSupply, bool transferable, bool selfDestruct, string network)

    readonly property var transactionStore: TransactionStore{}

    ColumnLayout {
        id: layout
        anchors.left: parent.left

        spacing: Style.current.padding

        StatusInput {
            id: name
            width: 200
            label: qsTr("Name")
        }

        StatusInput {
            id: symbol
            width: 100
            label: qsTr("Symbol")
        }

        StatusInput {
            id: description
            width: 200
            label: qsTr("Description")
        }

        StatusInput {
            id: supply
            width: 100
            label: qsTr("Total finite supply")
            text: "0"
        }

        StatusCheckBox {
            id: transferable
            text: qsTr("Transferable")
        }

        StatusCheckBox {
            id: selfDestruct
            text: qsTr("Remote self-destruct")
        }

        StatusComboBox {
            id: network
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: 200
            label: qsTr("Select network")
            model: ListModel {
                ListElement {
                    name: "Goerli"
                }
                ListElement {
                    name: "Optimism Goerli"
                }
            }
        }

        StatusButton {
            id: mintButton
            text: "Mint"
            //TODO use address from SendModal
            onClicked: root.mintCollectible(root.transactionStore.currentAccount.address, name.text, symbol.text, description.text, parseInt(supply.text),
                                            false, transferable.checked, selfDestruct.checked, network.currentValue)
        }

        StatusBaseText {
            text: "Minted collectibles"
        }

        ListView {
            id: collectibles

            width: 200
            height: 100

            model: root.tokensModel

            delegate: Text {
                text: "name: " + name + ", descr: " + description + ", supply: " + supply
            }
        }
    }
}
