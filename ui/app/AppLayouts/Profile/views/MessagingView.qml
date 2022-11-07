import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

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

import "../stores"
import "../controls"
import "../popups"
import "../panels"

SettingsContentBase {
    id: root

    property MessagingStore messagingStore
    property AdvancedStore advancedStore
    property ContactsStore contactsStore

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
                    checked: !root.messagingStore.privacyModule.messagesFromContactsOnly
                    onCheckedChanged: {
                        // messagesFromContactsOnly needs to be accessed from the module (view),
                        // because otherwise doing `messagesFromContactsOnly = value` only changes the bool property on QML
                        if (root.messagingStore.privacyModule.messagesFromContactsOnly === checked) {
                            root.messagingStore.privacyModule.messagesFromContactsOnly = !checked
                        }
                    }
                }
            ]
            onClicked: {
                switch3.checked = !switch3.checked
            }
        }

        // Open Message Links With
        StatusBaseText {
            Layout.topMargin: Constants.settingsSection.itemSpacing
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            text: qsTr("Open Message Links With")
            font.pixelSize: 15
            color: Theme.palette.directColor1
        }

        SettingsRadioButton {
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            label: qsTr("Status Browser")
            group: browserGroup
            checked: localAccountSensitiveSettings.openLinksInStatus
            onClicked: {
                localAccountSensitiveSettings.openLinksInStatus = true
            }
        }

        SettingsRadioButton {
            Layout.topMargin: Constants.settingsSection.itemSpacing / 2
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            label: qsTr("System Default Browser")
            group: browserGroup
            checked: !localAccountSensitiveSettings.openLinksInStatus
            onClicked: {
                localAccountSensitiveSettings.openLinksInStatus = false
            }
        }

        Separator {
            id: separator1
            Layout.topMargin: Constants.settingsSection.itemSpacing
            Layout.fillWidth: true
        }

        // CONTACTS SECTION
        StatusContactRequestsIndicatorListItem {
            Layout.fillWidth: true
            title: qsTr("Contacts, Requests, and Blocked Users")
            requestsCount: root.contactsStore.receivedContactRequestsModel.count
            onClicked: Global.changeAppSectionBySectionType(Constants.appSection.profile,
                                                                   Constants.settingsSubsection.contacts)
        }

        Separator {
            id: separator2
            Layout.fillWidth: true
        }

        // MESSAGE LINK PREVIEWS
        StatusListItem {
            Layout.fillWidth: true
            objectName: "displayMessageLinkPreviewsItem"
            title: qsTr("Display Message Link Previews")
            implicitHeight: 64
            components: [
                StatusSwitch {
                    id: showMessageLinksSwitch
                    function switchOffPreviewableSites() {
                        //update all models
                        localAccountSensitiveSettings.displayChatImages = false
                        for (let i = 0; i < previewableSites.count; i++) {
                            let item = previewableSites.get(i)
                            RootStore.updateWhitelistedUnfurlingSites(item.address, false)
                        }
                    }
                    checked: previewableSites.anyWhitelisted || localAccountSensitiveSettings.displayChatImages
                    onToggled: {
                        if (checked === false) {
                            switchOffPreviewableSites()
                        }
                    }
                }
            ]
            onClicked: {
                showMessageLinksSwitch.toggle()
                if (showMessageLinksSwitch.checked === false) {
                    showMessageLinksSwitch.switchOffPreviewableSites()
                }
            }
        }

        function buildPreviewablesSitesJSON() {
            let whitelistAsString = root.messagingStore.getLinkPreviewWhitelist()
            if(whitelistAsString == "")
                return

            if (!localAccountSensitiveSettings.whitelistedUnfurlingSites) {
                localAccountSensitiveSettings.whitelistedUnfurlingSites = {}
            }

            let anyWhitelisted = false
            let whitelist = JSON.parse(whitelistAsString)
            whitelist.forEach(entry => {
                                  entry.isWhitelisted = !!localAccountSensitiveSettings.whitelistedUnfurlingSites[entry.address]
                                  if(entry.isWhitelisted) anyWhitelisted = true
                })
            return [anyWhitelisted, whitelist]
        }

        function populatePreviewableSites() {
            const [anyWhitelisted, whitelist] = buildPreviewablesSitesJSON()
            previewableSites.populateModel(whitelist)
            previewableSites.anyWhitelisted = anyWhitelisted
        }

        Component.onCompleted: {
            populatePreviewableSites()
        }

        StatusSectionHeadline {
            id: labelWebsites
            visible: showMessageLinksSwitch.checked
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            text: qsTr("Fine tune which sites to allow link previews")
        }

        Column {
            id: siteColumn
            visible: showMessageLinksSwitch.checked
            Layout.fillWidth: true

            ListModel {
                id: previewableSites
                function populateModel(jsonModel) {
                    // add/update rows
                    Object.entries(jsonModel)
                        .forEach(([index, newRow]) => {
                            var existingRow = previewableSites.get(index)
                            let isRowIdentical = existingRow != undefined && Object.entries(newRow)
                                        .every(([key, value]) => value == existingRow[key])
                            if(!isRowIdentical) {
                                previewableSites.set(index, newRow)
                            }
                    })

                    // remove rows that are not in the new model
                    if(previewableSites.count > jsonModel.length) {
                        let rowsToDelete = previewableSites.count - jsonModel.length
                        previewableSites.remove(jsonModel.length - 1, rowsToDelete)
                    }
                }
                
                property bool anyWhitelisted: false
            }

            Connections {
                target: Global
                function onSettingsLoaded() {
                    generalColumn.populatePreviewableSites()
                }
            }

            Connections {
                target: localAccountSensitiveSettings
                onWhitelistedUnfurlingSitesChanged: generalColumn.populatePreviewableSites()
            }

            // Manually add switch for the image unfurling
            StatusListItem {
                objectName: "imageUnfurlingItem"
                width: parent.width
                implicitHeight: 64
                title: qsTr("Image unfurling")
                subTitle: qsTr("All images (links that contain an image extension) will be downloaded and displayed")
                // TODO find a better icon for this
                asset.name: Style.svg('globe')
                asset.isImage: true
                components: [
                    StatusSwitch {
                        id: imageSwitch
                        checked: localAccountSensitiveSettings.displayChatImages
                        onToggled: {
                                localAccountSensitiveSettings.displayChatImages = !localAccountSensitiveSettings.displayChatImages
                        }
                    }
                ]
                onClicked: {
                    localAccountSensitiveSettings.displayChatImages = !localAccountSensitiveSettings.displayChatImages
                }
            }

            Repeater {
                id: sitesListView
                model: previewableSites

                delegate: Component {
                    StatusListItem {
                        objectName: "MessagingView_sitesListView_StatusListItem_" + model.title.replace(/ /g, "_").toLowerCase()
                        width: parent.width
                        implicitHeight: 64
                        title: model.title
                        subTitle: model.address
                        asset.name:  {
                            let filename;
                            switch (model.title.toLowerCase()) {
                            case "youtube":
                            case "youtube shortener":
                                filename = "youtube"; break;
                            case "github":
                                filename = "github"; break;
                            case "medium":
                                filename = "medium"; break;
                            case "tenor gifs subdomain":
                                filename = "tenor"; break;
                            case "giphy gifs":
                            case "giphy gifs shortener":
                            case "giphy gifs subdomain":
                                filename = "giphy"; break;
                            case "github":
                                filename = "github"; break;
                            case "status":
                                filename = "status"; break;
                                // TODO get a good default icon
                            default: filename = "../globe"
                            }
                            return Style.svg(`linkPreviewThumbnails/${filename}`)
                        }
                        asset.isImage: true
                        components: [
                            StatusSwitch {
                                id: siteSwitch
                                checked: !!model.isWhitelisted
                                onToggled: {
                                    RootStore.updateWhitelistedUnfurlingSites(model.address, checked)
                                }
                            }
                        ]
                        onClicked: {
                            RootStore.updateWhitelistedUnfurlingSites(model.address, !model.isWhitelisted)
                        }
                    }
                }
            }
        } // Site Column

        Separator {
            id: separator3
            visible: siteColumn.visible
            Layout.fillWidth: true
        }

        // SYNC WAKU SECTION
        StatusSectionHeadline {
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            text: qsTr("Message syncing")
        }

        StatusListItem {
            Layout.fillWidth: true
            title: qsTr("Waku nodes")
            label: root.messagingStore.getMailserverNameForNodeAddress(root.messagingStore.activeMailserver)
            components: [
                StatusIcon {
                    icon: "chevron-down"
                    rotation: 270
                    color: Theme.palette.baseColor1
                }
            ]
            onClicked: Global.openPopup(wakuNodeModalComponent)
        }

        Component {
            id: wakuNodeModalComponent
            WakuNodesModal {
                messagingStore: root.messagingStore
                advancedStore: root.advancedStore
            }
        }

        StatusSectionHeadline {
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            text: qsTr("For security reasons, private chat history won't be synced.")
        }
    }
}
