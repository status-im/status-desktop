import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.panels 1.0

import "../controls"

StatusModal {
    id: root

    property var notificationsStore
    property var item: ({
        name: "",
        image: "",
        color: "",
        customized: false,
        type: Constants.settingsSection.exemptions.community,
        muteAllMessages: false,
        personalMentions: Constants.settingsSection.notifications.sendAlertsValue,
        globalMentions: Constants.settingsSection.notifications.sendAlertsValue,
        otherMessages: Constants.settingsSection.notifications.turnOffValue
    })
    headerSettings.title: qsTr("%1 exemption").arg(root.item.name)
    headerSettings.asset: StatusAssetSettings {
        // Once we introduce StatusSmartIdenticon in popup header, we should use the folowing
//        color: root.item.type === Constants.settingsSection.exemptions.oneToOneChat?
//                   Theme.palette.userCustomizationColors[Utils.colorIdForPubkey(root.item.itemId)] :
//                   root.item.color
        // until then the following is used
        bgColor: d.isOneToOneChat ? Utils.colorForPubkey(root.item.itemId) : root.item.color
        name: root.item.image
        isImage: !!root.item.image
        charactersLen: d.isOneToOneChat ? 2 : 1
        isLetterIdenticon: root.item.image === ""
        height: 40
        width: 40
    }

    QtObject {
        id: d
        readonly property bool isOneToOneChat: root.item.type === Constants.settingsSection.exemptions.oneToOneChat
        readonly property int contentSpacing: 0
        property bool muteAllMessages: root.item.muteAllMessages
        property string personalMentions: root.item.personalMentions
        property string globalMentions: root.item.globalMentions
        property string otherMessages: root.item.otherMessages
        property bool customized: d.muteAllMessages ||
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
                root.notificationsStore.saveExemptions(root.item.itemId,
                                                       d.muteAllMessages,
                                                       d.personalMentions,
                                                       d.globalMentions,
                                                       d.otherMessages)
                root.close()
            }
        }
    ]
}
