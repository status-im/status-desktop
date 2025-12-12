import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core

import StatusQ
import StatusQ.Popups
import StatusQ.Popups.Dialog

import AppLayouts.ActivityCenter.controls
import AppLayouts.ActivityCenter.helpers

import utils

Control {
    id: root

    // Properties related to the different notification types / groups:
    required property bool hasAdmin
    required property bool hasMentions
    required property bool hasReplies
    required property bool hasContactRequests
    required property bool hasMembership
    required property int activeGroup

    property bool hideReadNotifications: true

    property var notificationsModel

    // Style:
    property color backgroundColor: Theme.palette.baseColor4

    signal moreOptionsRequested()
    signal closeRequested()
    signal markAllAsReadRequested()
    signal hideShowNotificationsRequested()
    signal setActiveGroupRequested(int group)

    QtObject {
        id: d

        property bool showOptions: false
    }

    contentItem: ColumnLayout {
        spacing: 0

        // Panel Header
        RowLayout {
            id: panelHeader
            Tracer{}

            Layout.fillWidth: true
            Layout.margins: Theme.padding
            Layout.rightMargin: 0

            spacing: 0

            StatusNavigationPanelHeadline {
                Layout.fillWidth: true

                font.pixelSize: Theme.fontSize(19)
                text: qsTr("Notifications")
                elide: Text.ElideRight
            }

            // Filler
            Item {
                Layout.fillWidth: true
            }

            StatusFlatRoundButton {
                objectName: "moreOptionsButton"
                icon.name: "more"
                onClicked: d.showOptions = !d.showOptions
            }

            StatusFlatRoundButton {
                objectName: "closeButton"
                icon.name: "close"
                onClicked: {
                    d.showOptions = false
                    root.closeRequested()
                }
            }
        }

        // Notification's List Header
        ActivityCenterPopupTopBarPanel {
            id: topBarPanel
            Tracer{}
            Layout.fillWidth: true

            hasAdmin: root.hasAdmin
            hasReplies: root.hasReplies
            hasMentions: root.hasMentions
            hasContactRequests: root.hasContactRequests
            hasMembership: root.hasMembership
            activeGroup: root.activeGroup

            gradientColor: root.backgroundColor

            onSetActiveGroupRequested: root.setActiveGroupRequested(group)
        }

        // Notifications
        StatusListView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            implicitHeight: contentHeight
            model: root.notificationsModel
            clip: true
            delegate: NotificationCard {
                Tracer{}
                width: root.width

                // Card states related
                unread: !model.read
                selected: model.selected

                // Avatar related
                avatarSource: model.avatarSource
                badgeIconName: model.badgeIconName
                isCircularAvatar: model.isCricularAvatar

                // Header row related
                title: model.title
                chatKey: model.chatKey
                isContact: model.isContact
                trustIndicator: model.trustIndicator

                // Context row related
                primaryText: model.primartyText
                iconName: contextEditor.iconType
                secondaryText: model.secondaryText
                separatorIconName: contextEditor.separatorType

                // Action text
                actionText: model.actionText

                // Content block related
                preImageSource: contentEditor.preImageVisible ? "https://picsum.photos/320/240?6" : ""
                preImageRadius: contentEditor.preImageWithRadius ? 8 : 0
                content: contentEditor.content
                attachments: contentEditor.oneAttachment ? d.oneAttachment :
                                                           contentEditor.threeAttachments ? d.threeAttachments :
                                                                                            contentEditor.sevenAttachments ? d.sevenAttachments : []

                // Timestamp related
                timestamp: dateText.text

                // Interactions
                onClicked: logs.logEvent("NotificationCard::onClicked --> Card clicked")
            }
        }

        // Filler
        Item {
            Tracer {}
            Layout.fillHeight: true
        }

        /*StatusListView {
            id: listView

            Layout.fillWidth: true
            Layout.fillHeight: count !== 0
            spacing: 1
            model: 5

            Rectangle {
                anchors.fill: parent
                color: "#3300ff00"
            }
            delegate: Item {
                width: listView.width
                height: 40

                StatusBaseText {
                    anchors.fill: parent
                    anchors.margins: 8
                    text: "aslkdfñlkasjdflkaj fklajsdñlkfjañsdlkfj"
                    elide: Text.ElideRight
                }
            }
        }*/

        /*ActivityCenterOptionsPanel {
            visible: d.showOptions
            Layout.fillWidth: true
            anchors.top: panelHeader.bottom
            background: Rectangle {
                color: "red"//root.backgroundColor
                radius: Theme.radius
            }
            z: root.z + 1
        }*/

        /*Rectangle {
            visible: d.showOptions
            anchors.top: panelHeader.bottom
            Layout.fillWidth: true
            Layout.preferredHeight: root
            color: root.backgroundColor
            opacity: 0.8
        }/*/
    }
}
