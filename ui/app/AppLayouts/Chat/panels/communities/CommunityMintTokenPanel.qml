import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

Rectangle {
    id: root

    property var tokensModel

    signal mintCollectible(string name, string description, int supply,
                           bool transferable, bool selfDestruct, string network)

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
            onClicked: root.mintCollectible(name.text, description.text, parseInt(supply.text),
                                            transferable.checked, selfDestruct.checked, network.currentValue)
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
