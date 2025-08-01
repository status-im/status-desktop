import QtQuick
import QtQuick.Controls

import StatusQ.Popups

import utils

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
        id: contractDeploymentCheckbox
        title: qsTr("Contract Deployment")
        assetSettings.name: "contract_deploy"
        buttonGroup: typeButtonGroup
        allChecked: root.allChecked
        type: Constants.TransactionType.ContractDeployment
        checked: root.allChecked || typeFilters.includes(type)
        onActionTriggered: root.actionTriggered(type)
    }

    ActivityTypeCheckBox {
        id: mintCheckbox
        title: qsTr("Mint")
        assetSettings.name: "token"
        buttonGroup: typeButtonGroup
        allChecked: root.allChecked
        type: Constants.TransactionType.Mint
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
