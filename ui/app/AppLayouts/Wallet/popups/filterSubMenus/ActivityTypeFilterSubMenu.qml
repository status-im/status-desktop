import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Popups 0.1

import utils 1.0

import "../../controls"

StatusMenu {
    id: root

    property var typeFilters: []
    readonly property bool allChecked: typeFilters.length === 0
    readonly property int allFiltersCount: typeButtonGroup.buttons.length

    signal back()
    signal actionTriggered(int type)

    MenuBackButton {
        width: parent.width
        onClicked: {
            close()
            back()
        }
    }

    ButtonGroup {
        id: typeButtonGroup
        exclusive: false
    }

    ActivityTypeCheckBox {
        id: sendCheckbox
        title: qsTr("Send")
        assetSettings.name: "send"
        buttonGroup: typeButtonGroup
        allChecked: root.allChecked
        type: Constants.TransactionType.Send
        checked: root.allChecked || typeFilters.includes(type)
        onActionTriggered: root.actionTriggered(type)
    }

    ActivityTypeCheckBox {
        id: receiveCheckbox
        title: qsTr("Receive")
        assetSettings.name: "receive"
        buttonGroup: typeButtonGroup
        allChecked: root.allChecked
        type: Constants.TransactionType.Receive
        checked: root.allChecked || typeFilters.includes(type)
        onActionTriggered: root.actionTriggered(type)
    }

    ActivityTypeCheckBox {
        id: buyCheckbox
        title: qsTr("Buy")
        assetSettings.name: "token"
        buttonGroup: typeButtonGroup
        allChecked: root.allChecked
        type: Constants.TransactionType.Buy
        checked: root.allChecked || typeFilters.includes(type)
        onActionTriggered: root.actionTriggered(type)
    }

    ActivityTypeCheckBox {
        id: swapCheckbox
        title: qsTr("Swap")
        assetSettings.name: "swap"
        buttonGroup: typeButtonGroup
        allChecked: root.allChecked
        type: Constants.TransactionType.Swap
        checked: root.allChecked || typeFilters.includes(type)
        onActionTriggered: root.actionTriggered(type)
    }

    ActivityTypeCheckBox {
        id: bridgeCheckbox
        title: qsTr("Bridge")
        assetSettings.name: "bridge"
        buttonGroup: typeButtonGroup
        allChecked: root.allChecked
        type: Constants.TransactionType.Bridge
        checked: root.allChecked || typeFilters.includes(type)
        onActionTriggered: root.actionTriggered(type)
    }
}
