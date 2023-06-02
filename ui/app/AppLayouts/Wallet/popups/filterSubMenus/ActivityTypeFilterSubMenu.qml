import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Popups 0.1

import "../../controls"

StatusMenu {
    id: root

    property var typeFilters:[]

    signal back()
    signal actionTriggered(int action, bool checked)

    property bool allChecked: {
        let allCheckedIs = true
        for(var i=0;i< root.contentChildren.length;i++) {
            if(root.contentChildren[i].checkState === Qt.Unchecked)
                allCheckedIs = false
        }
        return allCheckedIs
    }

    enum TxType {
        Send,
        Receive,
        Buy,
        Swap,
        Bridge
    }

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
        title: qsTr("Send")
        asset.name: "send"
        checked: typeFilters.includes(ActivityTypeFilterSubMenu.Send)
        buttonGroup: typeButtonGroup
        onActionTriggered: root.actionTriggered(ActivityTypeFilterSubMenu.Send, checked)
        allChecked: root.allChecked
    }
    ActivityTypeCheckBox {
        title: qsTr("Receive")
        asset.name: "receive"
        buttonGroup: typeButtonGroup
        checked: typeFilters.includes(ActivityTypeFilterSubMenu.Receive)
        onActionTriggered: root.actionTriggered(ActivityTypeFilterSubMenu.Receive, checked)
        allChecked: root.allChecked
    }
    ActivityTypeCheckBox {
        title: qsTr("Buy")
        asset.name: "token"
        buttonGroup: typeButtonGroup
        checked: typeFilters.includes(ActivityTypeFilterSubMenu.Buy)
        onActionTriggered: root.actionTriggered(ActivityTypeFilterSubMenu.Buy, checked)
        allChecked: root.allChecked
    }
    ActivityTypeCheckBox {
        title: qsTr("Swap")
        asset.name: "swap"
        buttonGroup: typeButtonGroup
        checked: typeFilters.includes(ActivityTypeFilterSubMenu.Swap)
        onActionTriggered: root.actionTriggered(ActivityTypeFilterSubMenu.Swap, checked)
        allChecked: root.allChecked
    }
    ActivityTypeCheckBox {
        title: qsTr("Bridge")
        asset.name: "bridge"
        buttonGroup: typeButtonGroup
        checked: typeFilters.includes(ActivityTypeFilterSubMenu.Bridge)
        onActionTriggered: root.actionTriggered(ActivityTypeFilterSubMenu.Bridge, checked)
        allChecked: root.allChecked
    }
}
