import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Popups 0.1

import utils 1.0

import "../../controls"

StatusMenu {
    id: root

    property var statusFilters: []
    readonly property bool allChecked: statusFilters.length === 0
    readonly property int allFiltersCount: typeButtonGroup.buttons.length

    signal back()
    signal actionTriggered(int status)

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
        title: qsTr("Failed")
        assetSettings.name: Style.svg("transaction/failed")
        assetSettings.color: "transparent"
        buttonGroup: typeButtonGroup
        allChecked: root.allChecked
        type: Constants.TransactionStatus.Failed
        checked: root.allChecked || statusFilters.includes(type)
        onActionTriggered: root.actionTriggered(type)
    }

    ActivityTypeCheckBox {
        id: receiveCheckbox
        title: qsTr("Pending")
        assetSettings.name: Style.svg("transaction/pending")
        assetSettings.color: "transparent"
        buttonGroup: typeButtonGroup
        allChecked: root.allChecked
        type: Constants.TransactionStatus.Pending
        checked: root.allChecked || statusFilters.includes(type)
        onActionTriggered: root.actionTriggered(type)
    }

    ActivityTypeCheckBox {
        id: buyCheckbox
        title: qsTr("Complete")
        assetSettings.name: Style.svg("transaction/verified")
        assetSettings.color: "transparent"
        buttonGroup: typeButtonGroup
        allChecked: root.allChecked
        type: Constants.TransactionStatus.Complete
        checked: root.allChecked || statusFilters.includes(type)
        onActionTriggered: root.actionTriggered(type)
    }

    ActivityTypeCheckBox {
        id: swapCheckbox
        title: qsTr("Finalised")
        assetSettings.name: Style.svg("transaction/finished")
        assetSettings.color: "transparent"
        buttonGroup: typeButtonGroup
        allChecked: root.allChecked
        type: Constants.TransactionStatus.Finished
        checked: root.allChecked || statusFilters.includes(type)
        onActionTriggered: root.actionTriggered(type)
    }
}
