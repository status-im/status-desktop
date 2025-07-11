import QtQuick

import StatusQ.Popups

StatusMenu {
    id: root

    property bool sendEnabled: true
    property bool swapEnabled: true

    property bool swapVisible: true
    property bool hideVisible: true
    property bool communityHideVisible: true

    signal sendRequested
    signal receiveRequested
    signal swapRequested
    signal hideRequested
    signal communityHideRequested
    signal manageTokensRequested

    StatusAction {
        objectName: "sendMenuItem"
        enabled: root.sendEnabled
        visibleOnDisabled: true
        icon.name: "send"
        text: qsTr("Send")
        onTriggered: root.sendRequested()
    }
    StatusAction {
        objectName: "receiveMenuItem"
        icon.name: "receive"
        text: qsTr("Receive")
        onTriggered: root.receiveRequested()
    }
    StatusAction {
        icon.name: "swap"
        text: qsTr("Swap")
        enabled: root.swapEnabled && root.swapVisible
        visibleOnDisabled: root.swapVisible
        onTriggered: root.swapRequested()
    }
    StatusMenuSeparator {}
    StatusAction {
        icon.name: "settings"
        text: qsTr("Manage tokens")
        onTriggered: root.manageTokensRequested()
    }
    StatusAction {
        enabled: root.hideVisible
        type: StatusAction.Type.Danger
        icon.name: "hide"
        text: qsTr("Hide asset")
        onTriggered: root.hideRequested()
    }
    StatusAction {
        enabled: root.communityHideVisible
        type: StatusAction.Type.Danger
        icon.name: "hide"
        text: qsTr("Hide all assets from this community")
        onTriggered: root.communityHideRequested()
    }
}
