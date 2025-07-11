import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Popups

import utils
import shared.panels

import "../controls"
import "../stores"

StatusModal {
    id: root

    property NotificationsStore notificationsStore

    property string name
    property int type: Constants.settingsSection.exemptions.community
    property string itemId
    property color color
    property string image
    property bool muteAllMessages
    property string personalMentions: Constants.settingsSection.notifications.sendAlertsValue
    property string globalMentions: Constants.settingsSection.notifications.sendAlertsValue
    property string otherMessages: Constants.settingsSection.notifications.turnOffValue

    headerSettings.title: qsTr("%1 exemption").arg(root.name)
    headerSettings.asset: StatusAssetSettings {
        // Once we introduce StatusSmartIdenticon in popup header, we should use the folowing
//        color: root.type === Constants.settingsSection.exemptions.oneToOneChat?
//                   Theme.palette.userCustomizationColors[Utils.colorIdForPubkey(root.itemId)] :
//                   root.color
        // until then the following is used
        bgColor: d.isOneToOneChat ? Utils.colorForPubkey(root.itemId) : root.color
        name: root.image
        isImage: !!root.image
        charactersLen: d.isOneToOneChat ? 2 : 1
        isLetterIdenticon: root.image === ""
        height: 40
        width: 40
    }

    QtObject {
        id: d
        readonly property bool isOneToOneChat: root.type === Constants.settingsSection.exemptions.oneToOneChat
        readonly property int contentSpacing: 0
        property bool muteAllMessages: root.muteAllMessages
        property string personalMentions: root.personalMentions
        property string globalMentions: root.globalMentions
        property string otherMessages: root.otherMessages
        readonly property bool customized: d.muteAllMessages ||
                                           d.personalMentions !== Constants.settingsSection.notifications.sendAlertsValue ||
                                           d.globalMentions !== Constants.settingsSection.notifications.sendAlertsValue ||
                                           d.otherMessages !== Constants.settingsSection.notifications.turnOffValue
    }

    contentItem: Column {
        width: root.width
        spacing: d.contentSpacing

        StatusListItem {
            width: parent.width
            title: qsTr("Mute all messages")
            components: [
                StatusSwitch {
                    id: muteAllMessagesSwitch
                    checked: d.muteAllMessages
                    onClicked: {
                        d.muteAllMessages = !d.muteAllMessages
                    }
                }
            ]
            onClicked: {
                muteAllMessagesSwitch.clicked()
            }
        }

        Separator {
            visible: !d.isOneToOneChat
        }

        StatusListItem {
            width: parent.width
            title: qsTr("Personal @ Mentions")
            visible: !d.isOneToOneChat
            components: [
                NotificationSelect {
                    selected: d.personalMentions
                    onSendAlertsClicked: d.personalMentions = Constants.settingsSection.notifications.sendAlertsValue
                    onDeliverQuietlyClicked: d.personalMentions = Constants.settingsSection.notifications.deliverQuietlyValue
                    onTurnOffClicked: d.personalMentions = Constants.settingsSection.notifications.turnOffValue
                }
            ]
        }

        StatusListItem {
            width: parent.width
            title: qsTr("Global @ Mentions")
            visible: !d.isOneToOneChat
            components: [
                NotificationSelect {
                    selected: d.globalMentions
                    onSendAlertsClicked: d.globalMentions = Constants.settingsSection.notifications.sendAlertsValue
                    onDeliverQuietlyClicked: d.globalMentions = Constants.settingsSection.notifications.deliverQuietlyValue
                    onTurnOffClicked: d.globalMentions = Constants.settingsSection.notifications.turnOffValue
                }
            ]
        }

        StatusListItem {
            width: parent.width
            title: qsTr("Other Messages")
            visible: !d.isOneToOneChat
            components: [
                NotificationSelect {
                    selected: d.otherMessages
                    onSendAlertsClicked: d.otherMessages = Constants.settingsSection.notifications.sendAlertsValue
                    onDeliverQuietlyClicked: d.otherMessages = Constants.settingsSection.notifications.deliverQuietlyValue
                    onTurnOffClicked: d.otherMessages = Constants.settingsSection.notifications.turnOffValue
                }
            ]
        }
    }

    rightButtons: [
        StatusFlatButton {
            text: qsTr("Clear Exemptions")
            enabled: d.customized
            onClicked: {
                d.muteAllMessages = false
                d.personalMentions = Constants.settingsSection.notifications.sendAlertsValue
                d.globalMentions = Constants.settingsSection.notifications.sendAlertsValue
                d.otherMessages = Constants.settingsSection.notifications.turnOffValue
            }
        },
        StatusButton {
            id: btnCreateEdit
            text: qsTr("Done")
            onClicked: {
                root.notificationsStore.saveExemptions(root.itemId,
                                                       d.muteAllMessages,
                                                       d.personalMentions,
                                                       d.globalMentions,
                                                       d.otherMessages)
                root.close()
            }
        }
    ]
}
