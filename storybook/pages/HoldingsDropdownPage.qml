import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import Models 1.0

import AppLayouts.Chat.controls.community 1.0

SplitView {
    id: root

    orientation: Qt.Vertical

    Item {
        id: container
        anchors.fill: parent
        anchors.margins: 50

        RowLayout {

            Label {
                text: "Open flow:"
            }

            Button {
                text: "Add"
                onClicked: {
                    holdingsDropdown.close()
                    holdingsDropdown.open()
                }
            }

            Button {
                text: "Update"
                onClicked: {
                    holdingsDropdown.close()
                    holdingsDropdown.setActiveTab(HoldingTypes.Type.Ens)
                    holdingsDropdown.openUpdateFlow()
                }
            }
        }

        HoldingsDropdown {
            id: holdingsDropdown

            parent: container
            anchors.centerIn: container

            collectiblesModel: CollectiblesModel {}
            assetsModel: AssetsModel {}
            isENSTab: isEnsTabChecker.checked
            isCollectiblesOnly: isCollectiblesOnlyChecker.checked

            onOpened: contentItem.parent.parent = container
            Component.onCompleted: {
                holdingsDropdown.close()
                holdingsDropdown.open()
            }
        }
    }


    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 250

        RowLayout {
            CheckBox {
                id: isEnsTabChecker
                text: "Is ENS tab visible?"
                checked: true
            }

            CheckBox {
                id: isCollectiblesOnlyChecker
                text: "Is collectibles only visible?"
                checked: false
            }
        }
    }
}
