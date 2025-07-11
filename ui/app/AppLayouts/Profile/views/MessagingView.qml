import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.controls 1.0
import shared.stores 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import AppLayouts.stores.Messaging 1.0

import "../controls"
import "../popups"
import "../panels"

SettingsContentBase {
    id: root

    property MessagingSettingsStore messagingSettingsStore

    property alias requestsCount: contactRequestsIndicator.requestsCount

    ColumnLayout {
        id: generalColumn
        spacing: 2 * Constants.settingsSection.itemSpacing
        width: root.contentWidth

        ButtonGroup {
            id: showProfilePictureToGroup
        }

        ButtonGroup {
            id: seeProfilePicturesFromGroup
        }

        ButtonGroup {
            id: browserGroup
        }

        StatusListItem {
            id: allowNewContactRequest

            Layout.fillWidth: true
            implicitHeight: 64

            title: qsTr("Allow new contact requests")

            components: [
                StatusSwitch {
                    id: switch3
                    checked: !root.messagingSettingsStore.messagesFromContactsOnly
                    onCheckedChanged: {
                        // messagesFromContactsOnly needs to be accessed from the module (view),
                        // because otherwise doing `messagesFromContactsOnly = value` only changes the bool property on QML
                        if (root.messagingSettingsStore.messagesFromContactsOnly === checked) {
                            root.messagingSettingsStore.setMessagesFromContactsOnly(!checked)
                        }
                    }
                }
            ]
            onClicked: {
                switch3.checked = !switch3.checked
            }
        }

        Separator {
            Layout.fillWidth: true
        }

        // CONTACTS SECTION
        StatusContactRequestsIndicatorListItem {
            id: contactRequestsIndicator

            objectName: "MessagingView_ContactsListItem_btn"
            Layout.fillWidth: true
            title: qsTr("Contacts, Requests, and Blocked Users")

            onClicked: Global.changeAppSectionBySectionType(Constants.appSection.profile,
                                                            Constants.settingsSubsection.contacts)
        }

        Separator {
            id: separator2
            Layout.fillWidth: true
        }

        // GIF LINK PREVIEWS
        StatusSectionHeadline {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding
            Layout.rightMargin: Theme.padding
            text: qsTr("GIF link previews")
        }

        StatusListItem {
            Layout.fillWidth: true
            title: qsTr("Allow show GIF previews")
            objectName: "MessagingView_AllowShowGifs_StatusListItem"
            components: [
                StatusSwitch {
                    id: showGifPreviewsSwitch
                    checked: localAccountSensitiveSettings.gifUnfurlingEnabled
                    onClicked: {
                        localAccountSensitiveSettings.gifUnfurlingEnabled = !localAccountSensitiveSettings.gifUnfurlingEnabled
                    }
                }
            ]
            onClicked: {
                showGifPreviewsSwitch.clicked()
            }
        }

        Separator {
            Layout.fillWidth: true
        }

        // URL UNFRULING
        StatusSectionHeadline {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding
            Layout.rightMargin: Theme.padding
            text: qsTr("Website link previews")
        }

        ButtonGroup {
            id: urlUnfurlingGroup
        }

        SettingsRadioButton {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding
            Layout.rightMargin: Theme.padding
            label: qsTr("Always ask")
            objectName: "MessagingView_AlwaysAsk_RadioButton"
            group: urlUnfurlingGroup
            checked: root.messagingSettingsStore.urlUnfurlingMode === Constants.UrlUnfurlingModeAlwaysAsk
            onClicked: {
                root.messagingSettingsStore.setUrlUnfurlingMode(Constants.UrlUnfurlingModeAlwaysAsk)
            }
        }

        SettingsRadioButton {
            Layout.topMargin: Constants.settingsSection.itemSpacing / 2
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding
            Layout.rightMargin: Theme.padding
            label: qsTr("Always show previews")
            objectName: "MessagingView_AlwaysShow_RadioButton"
            group: urlUnfurlingGroup
            checked: root.messagingSettingsStore.urlUnfurlingMode === Constants.UrlUnfurlingModeEnableAll
            onClicked: {
                root.messagingSettingsStore.setUrlUnfurlingMode(Constants.UrlUnfurlingModeEnableAll)
            }
        }

        SettingsRadioButton {
            Layout.topMargin: Constants.settingsSection.itemSpacing / 2
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding
            Layout.rightMargin: Theme.padding
            label: qsTr("Never show previews")
            objectName: "MessagingView_NeverShow_RadioButton"
            group: urlUnfurlingGroup
            checked: root.messagingSettingsStore.urlUnfurlingMode === Constants.UrlUnfurlingModeDisableAll
            onClicked: {
                root.messagingSettingsStore.setUrlUnfurlingMode(Constants.UrlUnfurlingModeDisableAll)
            }
        }
    }
}
