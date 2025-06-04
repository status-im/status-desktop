import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1

import utils 1.0

ToolButton {
    id: root
    
    /*required */property int sectionType // cf Constants.appSection.*
    property bool hasNotification
    property int notificationsCount
    property bool pinned
    property color badgeColor: Theme.palette.primaryColor1
    property url connectorBadge
    property int chatType: Constants.chatType.unknown
    property int onlineStatus: Constants.onlineStatus.unknown
    property string tooltipText: Utils.translatedSectionName(sectionType, "")

    signal itemPinRequested(string key, bool pin)
    signal dappDisconnectRequested(string dappUrl)

    implicitWidth: 64
    implicitHeight: 64

    padding: Theme.smallPadding
    opacity: pressed || down ? Theme.pressedOpacity : enabled ? 1 : Theme.disabledOpacity
    Behavior on opacity { NumberAnimation { duration: Theme.AnimationDuration.Fast } }

    icon.width: 36
    icon.height: 36

    background: Rectangle {
        color: Qt.rgba(1, 1, 1, hovered ? 0.1 : 0.05) // FIXME get rid of opacity tricks
        Behavior on color { ColorAnimation { duration: Theme.AnimationDuration.Fast } }
        radius: Theme.smallPadding * 2

        // top right corner
        StatusBadge {
            width: root.notificationsCount ? implicitWidth : 12 + border.width // bigger dot
            height: root.notificationsCount ? implicitHeight : 12 + border.width
            color: hovered ? Qt.lighter(root.badgeColor, 1.25) : root.badgeColor
            Behavior on color { ColorAnimation { duration: Theme.AnimationDuration.Fast } }
            border.width: 2
            border.color: "#161d27"
            anchors.right: parent.right
            anchors.rightMargin: root.notificationsCount ? -2 : 0
            anchors.top: parent.top
            anchors.topMargin: root.notificationsCount ? -2 : 0
            visible: root.hasNotification
            value: root.notificationsCount
        }
    }

    contentItem: StatusSmartIdenticon {
        asset.width: root.icon.width
        asset.height: root.icon.height
        asset.letterSize: Theme.secondaryAdditionalTextSize
        asset.emoji: root.pinned && (root.sectionType === Constants.appSection.wallet || root.chatType === Constants.chatType.communityChat) ? root.icon.name : ""
        asset.color: root.icon.color
        asset.name: asset.emoji ? "" : root.icon.name
        asset.bgRadius: root.pinned && root.sectionType === Constants.appSection.wallet ? Theme.padding : asset.bgWidth/2
        name: root.text

        Binding on asset.bgColor {
            value: Qt.lighter(root.icon.color, 1.8)
            when: root.pinned && (root.sectionType === Constants.appSection.dApp || root.sectionType === Constants.appSection.profile)
        }

        hoverEnabled: false

        // for dApps
        bridgeBadge {
            image.source: root.connectorBadge
            border.width: 0
            implicitHeight: 16
            implicitWidth: 16
            anchors.rightMargin: 1
            anchors.bottomMargin: 1
        }
        bridgeBadge.visible: root.connectorBadge != "" && !bridgeBadge.isError

        // for chat items
        badge {
            visible: root.chatType === Constants.chatType.oneToOne
            color: root.onlineStatus === Constants.onlineStatus.online ? Theme.palette.successColor1
                                                                       : Theme.palette.baseColor1
            border.width: 2
            border.color: hovered ? "#222833" : "#161c27"
            implicitHeight: 10
            implicitWidth: 10
            anchors.rightMargin: 1
            anchors.bottomMargin: 1
        }
    }

    StatusToolTip {
        visible: !!text && root.hovered
        offset: -(x + width/2 - root.width/2)
        color: "#222833"
        text: root.tooltipText
    }

    onPressAndHold: if (root.pinned) contextMenuComponent.createObject(root).popup()

    MouseArea {
        anchors.fill: parent
        hoverEnabled: root.hoverEnabled
        acceptedButtons: Qt.RightButton
        cursorShape: hovered ? Qt.PointingHandCursor : undefined
        onClicked: if (root.pinned) contextMenuComponent.createObject(root).popup()
    }

    Component {
        id: contextMenuComponent
        StatusMenu {
            StatusAction {
                icon.name: "unpin"
                text: qsTr("Unpin")
                onTriggered: root.itemPinRequested(model.key, false)
            }
            StatusAction {
                enabled: root.sectionType === Constants.appSection.dApp
                icon.name: "disconnect"
                text: qsTr("Disconnect")
                onTriggered: root.dappDisconnectRequested(model.id)
            }
            onClosed: destroy()
        }
    }
}
