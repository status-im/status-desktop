import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import Models 1.0

import AppLayouts.Chat.controls.community 1.0

Pane {
    id: root

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

        parent: root
        anchors.centerIn: root

        store: QtObject {
            readonly property var collectiblesModel: CollectiblesModel {}
            readonly property var assetsModel: AssetsModel {}
        }

        onOpened: contentItem.parent.parent = root
        Component.onCompleted: {
            holdingsDropdown.close()
            holdingsDropdown.open()
        }
    }
}
