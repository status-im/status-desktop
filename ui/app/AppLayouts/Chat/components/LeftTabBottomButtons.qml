import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status/buttons"
import "../../../../shared/status"

Column {
    spacing: 12
    width: parent.width
    height: childrenRect.height

    Rectangle {
        width: 40
        height: 1
        color: Style.current.appBarDividerColor
        anchors.horizontalCenter: parent.horizontalCenter
    }

    StatusNavBarTabButton {
        id: walletBtn
        visible: enabled
        height: enabled ? implicitHeight : 0
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: isExperimental === "1" || appSettings.isWalletEnabled
        icon.name: "wallet"
        checked: sLayout.currentIndex === Utils.getAppSectionIndex(Constants.wallet)
        tooltip.text: qsTr("Wallet")
        onClicked: {
            chatsModel.communities.activeCommunity.active = false
            appMain.changeAppSection(Constants.wallet)
        }
    }

    StatusNavBarTabButton {
        id: browserBtn
        visible: enabled
        height: enabled ? implicitHeight: 0
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: isExperimental === "1" || appSettings.isBrowserEnabled
        icon.name: "browser"
        checked: sLayout.currentIndex === Utils.getAppSectionIndex(Constants.browser)
        tooltip.text: qsTr("Browser")
        onClicked: {
            chatsModel.communities.activeCommunity.active = false
            appMain.changeAppSection(Constants.browser)
        }
    }

    StatusNavBarTabButton {
        id: timelineBtn
        visible: enabled
        height: enabled ? implicitHeight: 0
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: isExperimental === "1" || appSettings.timelineEnabled
        icon.name: "status-update"
        checked: sLayout.currentIndex === Utils.getAppSectionIndex(Constants.timeline)
        tooltip.text: qsTr("Timeline")
        onClicked: {
            chatsModel.communities.activeCommunity.active = false
            appMain.changeAppSection(Constants.timeline)
        }
    }

    StatusNavBarTabButton {
        id: profileBtn
        visible: enabled
        height: enabled ? implicitHeight: 0
        anchors.horizontalCenter: parent.horizontalCenter
        icon.name: "profile"
        checked: sLayout.currentIndex === Utils.getAppSectionIndex(Constants.profile)

        badge.visible: !profileModel.mnemonic.isBackedUp && sLayout.children[sLayout.currentIndex] !== profileLayoutContainer
        badge.anchors.rightMargin: 4
        badge.anchors.topMargin: 5
        badge.border.color: profileBtn.hovered ? Style.current.secondaryBackground : Style.current.mainMenuBackground
        badge.border.width: 2

        tooltip.text: qsTr("Profile")
        onClicked: {
            chatsModel.communities.activeCommunity.active = false
            appMain.changeAppSection(Constants.profile)
        }
    }

    StatusNavBarTabButton {
        id: nodeBtn
        visible: enabled
        height: enabled ? implicitHeight: 0
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: isExperimental === "1" && appSettings.nodeManagementEnabled
        icon.name: "node"
        checked: sLayout.currentIndex === Utils.getAppSectionIndex(Constants.node)
        tooltip.text: qsTr("Node")
        onClicked: {
            chatsModel.communities.activeCommunity.active = false
            appMain.changeAppSection(Constants.node)
        }
    }

    StatusNavBarTabButton {
        id: uiComponentBtn
        visible: enabled
        height: enabled ? implicitHeight: 0
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: isExperimental === "1"
        icon.name: "node"
        checked: sLayout.currentIndex === Utils.getAppSectionIndex(Constants.ui)
        tooltip.text: qsTr("Component Library")
        onClicked: {
            chatsModel.communities.activeCommunity.active = false
            appMain.changeAppSection(Constants.ui)
        }
    }
}
