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

    StatusIconTabButton {
        id: walletBtn
        visible: enabled
        height: enabled ? implicitHeight: 0
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: isExperimental === "1" || appSettings.isWalletEnabled
        icon.name: "wallet"
        checked: sLayout.currentIndex === Utils.getAppSectionIndex(Constants.wallet)
        onClicked: {
            chatsModel.communities.activeCommunity.active = false
            appMain.changeAppSection(Constants.wallet)
        }
    }

    StatusIconTabButton {
        id: browserBtn
        visible: enabled
        height: enabled ? implicitHeight: 0
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: isExperimental === "1" || appSettings.isBrowserEnabled
        icon.name: "browser"
        checked: sLayout.currentIndex === Utils.getAppSectionIndex(Constants.browser)
        onClicked: {
            chatsModel.communities.activeCommunity.active = false
            appMain.changeAppSection(Constants.browser)
        }
    }

    StatusIconTabButton {
        id: timelineBtn
        visible: enabled
        height: enabled ? implicitHeight: 0
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: isExperimental === "1" || appSettings.timelineEnabled
        icon.name: "status-update"
        checked: sLayout.currentIndex === Utils.getAppSectionIndex(Constants.timeline)
        onClicked: {
            chatsModel.communities.activeCommunity.active = false
            appMain.changeAppSection(Constants.timeline)
        }
    }

    StatusIconTabButton {
        id: profileBtn
        visible: enabled
        height: enabled ? implicitHeight: 0
        anchors.horizontalCenter: parent.horizontalCenter
        icon.name: "profile"
        checked: sLayout.currentIndex === Utils.getAppSectionIndex(Constants.profile)
        onClicked: {
            chatsModel.communities.activeCommunity.active = false
            appMain.changeAppSection(Constants.profile)
        }

        Rectangle {
            id: profileBadge
            visible: !profileModel.mnemonic.isBackedUp && sLayout.children[sLayout.currentIndex] !== profileLayoutContainer
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.rightMargin: 4
            anchors.topMargin: 5
            radius: height / 2
            color: Style.current.blue
            border.color: profileBtn.hovered ? Style.current.secondaryBackground : Style.current.mainMenuBackground
            border.width: 2
            width: 14
            height: 14
        }
    }

    StatusIconTabButton {
        id: nodeBtn
        visible: enabled
        height: enabled ? implicitHeight: 0
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: isExperimental === "1" && appSettings.nodeManagementEnabled
        icon.name: "node"
        checked: sLayout.currentIndex === Utils.getAppSectionIndex(Constants.node)
        onClicked: {
            chatsModel.communities.activeCommunity.active = false
            appMain.changeAppSection(Constants.node)
        }
    }

    StatusIconTabButton {
        id: uiComponentBtn
        visible: enabled
        height: enabled ? implicitHeight: 0
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: isExperimental === "1"
        icon.name: "node"
        checked: sLayout.currentIndex === Utils.getAppSectionIndex(Constants.ui)
        onClicked: {
            chatsModel.communities.activeCommunity.active = false
            appMain.changeAppSection(Constants.ui)
        }
    }
}
