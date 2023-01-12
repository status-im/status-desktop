import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0

import AppLayouts.Chat.controls.community 1.0

Pane {
    id: root

    function openFlow(flowType) {
        holdingsDropdown.close()
        holdingsDropdown.openFlow(flowType)
    }

    RowLayout {
        Label {
            text: "Open flow:"
        }

        Button {
            text: "Add"
            onClicked: openFlow(HoldingsDropdown.FlowType.Add)
        }

        Button {
            text: "Update"
            onClicked: openFlow(HoldingsDropdown.FlowType.Update)
        }
    }

    HoldingsDropdown {
        id: holdingsDropdown

        parent: root
        anchors.centerIn: root

        store: QtObject {
            readonly property ListModel collectiblesModel: ListModel {

                Component.onCompleted: {
                    const collectibles = []

                    for (let i = 0; i < 20; i++) {
                        collectibles.push({
                            key: "key " + (i + 1),
                            iconSource: "",
                            name: "Collectible " + (i + 1),
                            category: "Community collectibles, cat "
                                      + (Math.floor(i / 4) + 1)
                        })
                    }

                    const subitems = []
                    for (let j = 0; j < 20; j++) {

                        subitems.push({
                            key: "subkey " + (j + 1),
                            iconSource: "",
                            name: "Collectible (sub) " + (j + 1)//,
                        })
                    }

                    collectibles[1].subItems = subitems;

                    append(collectibles)
                }
            }

            readonly property ListModel tokensModel: ListModel {
                ListElement {
                    key: "socks"; iconSource: ""; name: "Unisocks"; shortName: "SOCKS"; category: "Community tokens"
                }
                ListElement {
                    key: "zrx"; iconSource: ""; name: "Ox"; shortName: "ZRX"; category: "Listed tokens"
                }
                ListElement {
                    key: "1inch"; iconSource: ""; name: "1inch"; shortName: "ZRX"; category: "Listed tokens"
                }
                ListElement {
                    key: "Aave"; iconSource: ""; name: "Aave"; shortName: "AAVE"; category: "Listed tokens"}

                ListElement {
                    key: "Amp"; iconSource: ""; name: "Amp"; shortName: "AMP"; category: "Listed tokens"
                }
            }
        }

        onOpened: contentItem.parent.parent = root
        Component.onCompleted: openFlow(HoldingsDropdown.FlowType.Add)
    }
}
