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

    implicitHeight: 84 // by design

    Component.onCompleted: d.componentComplete = true

    QtObject {
        id: d
        property bool componentComplete
    }

    contentItem: ListView {
        implicitWidth: contentWidth
        clip: true
        orientation: ListView.Horizontal
        model: ConcatModel {
            sources: [
                SourceModel {
                    model: root.sectionsModel
                    markerRoleValue: false
                },
                SourceModel {
                    model: root.pinnedModel
                    markerRoleValue: true
                }
            ]
            markerRoleName: "pinnable"
        }

        spacing: root.spacing
        interactive: contentWidth > width
        delegate: Loader {
            id: delegateLoader
            required property var model
            required property int index
            sourceComponent: model.pinnable ? pinnedDockButton : regularDockButton

            ListView.onRemove: SequentialAnimation {
                PropertyAction { target: delegateLoader; property: "ListView.delayRemove"; value: true }
                NumberAnimation { target: delegateLoader; property: "scale"; to: 0; duration: Theme.AnimationDuration.Default; easing.type: Easing.InOutQuad }
                PropertyAction { target: delegateLoader; property: "ListView.delayRemove"; value: false }
            }
        }

        Behavior on implicitWidth {
            enabled: d.componentComplete
            PropertyAnimation { duration: Theme.AnimationDuration.Fast }
        }
    }

    Component {
        id: regularDockButton
        ShellDockButton {
            sectionType: model.sectionType
            text: model.name
            hasNotification: model.hasNotification ?? false
            notificationsCount: model.notificationsCount ?? 0
            connectorBadge: model.connectorBadge ?? ""
            icon.color: Theme.palette.white
            icon.name: (root.useNewDockIcons ? "shell/" : "") + model.icon
            enabled: model.enabled
            onClicked: root.itemActivated(sectionType, "") // not interested in item (section) id here
        }
    }

    Component {
        id: pinnedDockButton
        ShellDockButton {
            id: pinnedDelegate
            sectionType: model.sectionType
            text: model.name
            hasNotification: model.hasNotification ?? false
            notificationsCount: model.notificationsCount ?? 0
            connectorBadge: model.connectorBadge ?? ""
            icon.name: model.icon
            icon.color: model.color ?? Theme.palette.white
            icon.width: 24
            icon.height: 24
            tooltipText: "%1 (%2)".arg(text).arg(Utils.translatedSectionName(sectionType))

            chatType: model.chatType ?? Constants.chatType.unknown
            onlineStatus: model.onlineStatus ?? Constants.onlineStatus.unknown

            pinned: true
            onItemPinRequested: function(key, pin) {
                model.pinned = pin
                root.itemPinRequested(key, pin)
            }
            onDappDisconnectRequested: (dappUrl) => root.dappDisconnectRequested(dappUrl)
            onClicked: {
                root.itemActivated(sectionType, model.id)
                model.timestamp = new Date().valueOf()
            }
        }
    }
}
