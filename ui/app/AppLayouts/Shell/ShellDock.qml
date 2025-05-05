import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Control {
    id: root

    required property var sectionsModel
    required property var pinnedModel

    property bool useNewDockIcons: true

    signal itemActivated(int sectionType, string itemId)
    signal itemPinRequested(string key, bool pin)
    signal dappDisconnectRequested(string dappUrl)

    padding: Theme.smallPadding
    spacing: Theme.smallPadding

    background: Rectangle {
        color: "#161d27"
        radius: Theme.smallPadding * 2
    }

    clip: true

    contentItem: RowLayout {
        spacing: root.spacing

        // regular (section items)
        ListView {
            Layout.preferredHeight: 64
            implicitWidth: contentWidth
            orientation: ListView.Horizontal
            spacing: root.spacing
            interactive: false
            model: root.sectionsModel
            delegate: DockButton {
                icon.color: Theme.palette.white
                icon.name: (root.useNewDockIcons ? "shell/" : "") + model.icon
                enabled: model.enabled
                onClicked: root.itemActivated(sectionType, "") // not interested in item (section) id here
            }
        }

        // (optional) divider
        ToolSeparator {
            visible: !root.pinnedModel.ModelCount.empty
            Layout.preferredWidth: 2
            Layout.fillHeight: true
            background: Rectangle {
                color: "#222833"
            }
        }

        // pinned items
        ListView {
            Layout.preferredHeight: 64
            Layout.fillWidth: true
            implicitWidth: contentWidth
            clip: true
            opacity: count ? 1 : 0
            visible: opacity > 0
            orientation: ListView.Horizontal
            model: root.pinnedModel
            spacing: root.spacing
            interactive: contentWidth > width
            delegate: DockButton {
                id: pinnedDelegate
                icon.name: model.icon
                icon.color: model.color ?? Theme.palette.white
                badgeColor: model.color ?? Theme.palette.primaryColor1
                tooltipText: "%1 (%2)".arg(text).arg(Utils.translatedSectionName(sectionType))

                chatType: model.chatType ?? Constants.chatType.unknown
                onlineStatus: model.onlineStatus ?? Constants.onlineStatus.unknown

                pinned: true
                onItemPinRequested: function(key, pin) {
                    model.pinned = pin
                    root.itemPinRequested(key, pin)
                }
                onDappDisconnectRequested: (dappUrl) => root.dappDisconnectRequested(dappUrl)

                ListView.onRemove: SequentialAnimation {
                    PropertyAction { target: pinnedDelegate; property: "ListView.delayRemove"; value: true }
                    NumberAnimation { target: pinnedDelegate; property: "scale"; to: 0; duration: Theme.AnimationDuration.Default; easing.type: Easing.InOutQuad }
                    PropertyAction { target: pinnedDelegate; property: "ListView.delayRemove"; value: false }
                }
                onClicked: root.itemActivated(sectionType, model.id)
            }
            Behavior on opacity {
                PropertyAnimation { duration: Theme.AnimationDuration.Fast }
            }
            Behavior on implicitWidth {
                PropertyAnimation { duration: Theme.AnimationDuration.Fast }
            }
        }
    }

    component DockButton: ShellDockButton {
        sectionType: model.sectionType
        text: model.name
        hasNotification: model.hasNotification ?? false
        notificationsCount: model.notificationsCount ?? 0
        connectorBadge: model.connectorBadge ?? ""
    }
}
