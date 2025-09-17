import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import AppLayouts.ActivityCenter.controls
import Models
import Storybook

import StatusQ.Core.Theme
import StatusQ.Components

import utils

SplitView {
    id: root

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillHeight: true
            SplitView.fillWidth: true

            NotificationCard {
                Tracer {
                    visible: baseEditor.showTracer
                }
                anchors.centerIn: parent
                width: baseEditor.cardWidth

                // Card states related
                unread: undreadCheck.checked
                selected: selectedCheck.checked
                unreadDotColor: changeUnreadDotColor.checked ? "pink" : Theme.palette.primaryColor1

                // Avatar related
                avatarSource: avatarEditor.changeAvatarImage ? "https://i.pravatar.cc/128?img=5" : Theme.png("status-logo-icon")
                badgeIconName: avatarEditor.changeBadgeIcon ? "action-mention" : "action-reply"
                //density: avatarEditor.density
                isCircularAvatar: avatarEditor.isRoundedAvatar

                // Header row related
                title: headerEditor.titleField
                chatKey: headerEditor.chatkeyTextField
                isContact: headerEditor.isContactCheck
                trustedIndicator: contextEditor.isTruestedCheck ? StatusContactVerificationIcons.TrustedType.Verified :
                                                           StatusContactVerificationIcons.TrustedType.Untrustworthy
                // Context row related
                primaryText: contextEditor.primartyText
                iconName: contextEditor.iconType
                secondaryText: contextEditor.secondaryText
                separatorIconName: contextEditor.separatorType

                // Action text
                actionText: "New contact request"

                // Content block related
                content: 'hey, <a href="status:robertf.ox.eth">@robertf.ox.eth</a>, Do we still plan to ship this with v2.1 or postpone to the next release cycle?'
                preImageSource: "https://picsum.photos/seed/colors/600/600"
                attachments: [
                    "https://picsum.photos/320/240?3",
                    "https://picsum.photos/320/240?4",
                    "https://picsum.photos/320/240?5",
                    "https://picsum.photos/320/240?6",
                    "https://picsum.photos/320/240?7"
                ]

                // Timestamp related
                timestampText: "Just now"

                // Interactions
                onClicked: logs.logEvent("NotificationCard::onClicked --> Card clicked")
            }
        }

        LogsAndControlsPanel {
            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 160
            logsView.logText: logs.logText
        }
    }

    ScrollView {
        id: scroll
        SplitView.minimumWidth: 350
        SplitView.preferredWidth: 350
        clip: true

        Pane {
            ColumnLayout {
                width: scroll.width

                Label {
                    Layout.topMargin: Theme.padding
                    Layout.bottomMargin: Theme.padding
                    text: "GENERAL CARD STATES"
                    font.weight: Font.Bold
                }

                CheckBox {
                    id: undreadCheck
                    text: "Unread?"
                    checked: true
                }

                Switch {
                    id: changeUnreadDotColor
                    text: "Change Unread Dot Color"
                }

                CheckBox {
                    id: selectedCheck
                    text: "Seleted?"
                    checked: true
                }

                NotificationCardBaseEditor {
                    id: baseEditor
                    Layout.rightMargin: 8
                    Layout.fillWidth: true

                    minCardWidth: 296
                }

                NotificationAvatarEditor {
                    id: avatarEditor
                    Layout.rightMargin: 8
                    Layout.fillWidth: true
                }

                NotificationHeaderRowEditor {
                    id: headerEditor
                    Layout.rightMargin: 8
                    Layout.fillWidth: true
                }

                NotificationContextRowEditor {
                    id: contextEditor
                    Layout.rightMargin: 8
                    Layout.fillWidth: true
                }

                // TODO: Add NotificaitonContentBlockEditor
            }
        }
    }
}
// category: Activity Center
// status: good
// https://www.figma.com/design/SGyfSjxs5EbzimHDXTlj8B/Qt-Responsive---v?node-id=1135-37804&m=dev
