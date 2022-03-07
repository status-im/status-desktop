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

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import "../stores"
import "../controls"
import "../popups"
import "../panels"

ScrollView {
    id: root

    property int profileContentWidth

    height: parent.height
    width: parent.width
    contentHeight: advancedContainer.height + 100
    clip: true

    property MessagingStore messagingStore

    Item {
        id: advancedContainer
        width: profileContentWidth
        anchors.horizontalCenter: parent.horizontalCenter
        height: generalColumn.height

        ButtonGroup {
            id: showProfilePictureToGroup
        }

        ButtonGroup {
            id: seeProfilePicturesFromGroup
        }

        ButtonGroup {
            id: browserGroup
        }

        Column {
            id: generalColumn
            spacing: 18
            anchors.top: parent.top
            anchors.topMargin: 24
            anchors.left: parent.left
            anchors.right: parent.right

            StatusBaseText {
                id: titleText
                text: qsTr("Messaging")
                font.weight: Font.Bold
                font.pixelSize: 28
                color: Theme.palette.directColor1
            }

            StatusListItem {
                anchors.left: parent.left
                anchors.leftMargin: -Style.current.padding
                anchors.right: parent.right
                anchors.rightMargin: -Style.current.padding
                //% "Allow new contact requests"
                title: qsTrId("allow-new-contact-requests")
                implicitHeight: 64
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
                sensor.onClicked: {
                    switch3.checked = !switch3.checked
                }
            }

            // SHOW PROFILE PICTURE TO
            StatusBaseText {
                text: qsTr("Show My Profile Picture To")
                font.pixelSize: 15
                color: Theme.palette.directColor1
            }

            SettingsRadioButton {
                label: qsTr("Everyone")
                group: showProfilePictureToGroup
                checked: root.messagingStore.profilePicturesShowTo ===
                    Constants.profilePicturesShowTo.everyone
                onClicked: root.messagingStore.setProfilePicturesShowTo(
                        Constants.profilePicturesShowTo.everyone
                    )
            }

            SettingsRadioButton {
                label: qsTr("Contacts")
                group: showProfilePictureToGroup
                checked: root.messagingStore.profilePicturesShowTo ===
                    Constants.profilePicturesShowTo.contactsOnly
                onClicked: root.messagingStore.setProfilePicturesShowTo(
                        Constants.profilePicturesShowTo.contactsOnly
                    )
            }

            SettingsRadioButton {
                label: qsTr("No One")
                group: showProfilePictureToGroup
                checked: root.messagingStore.profilePicturesShowTo ===
                    Constants.profilePicturesShowTo.noOne
                onClicked: root.messagingStore.setProfilePicturesShowTo(
                        Constants.profilePicturesShowTo.noOne
                    )
            }

            Item {
                id: spacer1
                width: parent.width
                height: 6
            }

            // SEE PROFILTE PICTURES FROM
            StatusBaseText {
                text: qsTr("See Profile Pictures From")
                font.pixelSize: 15
                color: Theme.palette.directColor1
            }

            SettingsRadioButton {
                label: qsTr("Everyone")
                group: seeProfilePicturesFromGroup
                checked: root.messagingStore.profilePicturesVisibility ===
                    Constants.profilePicturesVisibility.everyone
                onClicked: root.messagingStore.setProfilePicturesVisibility(
                        Constants.profilePicturesVisibility.everyone
                    )
            }

            SettingsRadioButton {
                label: qsTr("Contacts")
                group: seeProfilePicturesFromGroup
                checked: root.messagingStore.profilePicturesVisibility ===
                    Constants.profilePicturesVisibility.contactsOnly
                onClicked: root.messagingStore.setProfilePicturesVisibility(
                        Constants.profilePicturesVisibility.contactsOnly
                    )
            }

            SettingsRadioButton {
                label: qsTr("No One")
                group: seeProfilePicturesFromGroup
                checked: root.messagingStore.profilePicturesVisibility ===
                    Constants.profilePicturesVisibility.noOne
                onClicked: root.messagingStore.setProfilePicturesVisibility(
                        Constants.profilePicturesVisibility.noOne
                    )
            }

            Item {
                id: spacer2
                width: parent.width
                height: 6
            }

            // Open Message Links With
            StatusBaseText {
                text: qsTr("Open Message Links With")
                font.pixelSize: 15
                color: Theme.palette.directColor1
            }

            SettingsRadioButton {
                label: qsTr("Status Browser")
                group: browserGroup
                checked: localAccountSensitiveSettings.openLinksInStatus
                onClicked: {
                     localAccountSensitiveSettings.openLinksInStatus = true
                }
            }

            SettingsRadioButton {
                label: qsTr("System Default Browser")
                group: browserGroup
                checked: !localAccountSensitiveSettings.openLinksInStatus
                onClicked: {
                     localAccountSensitiveSettings.openLinksInStatus = false
                }
            }

            Separator {
                id: separator1
            }

            // CONTACTS SECTION
            StatusContactRequestsIndicatorListItem {
                title: qsTr("Contacts, Requests, and Blocked Users")
                requestsCount: root.messagingStore.contactRequestsModel.count
                anchors.left: parent.left
                anchors.leftMargin: -Style.current.padding
                anchors.right: parent.right
                anchors.rightMargin: -Style.current.padding
                sensor.onClicked: Global.changeAppSectionBySectionType(Constants.appSection.profile,
                        Constants.settingsSubsection.contacts)
            }

            Separator {
                id: separator2
            }

            // MESSAGE LINK PREVIEWS
            StatusListItem {
                anchors.left: parent.left
                anchors.leftMargin: -Style.current.padding
                anchors.right: parent.right
                anchors.rightMargin: -Style.current.padding
                title: qsTr("Display Message Link Previews")
                implicitHeight: 64
                components: [
                    StatusSwitch {
                        id: showMessageLinksSwitch
                        checked: false
                        onCheckedChanged: {
                            if (checked === false) {
                                // Switch all the whitelists to false
                                imageSwitch.checked = false
                                for (let i = 0; i < sitesListView.count; i++) {
                                    let item = sitesListView.itemAt(i)
                                    item.whitelistSwitch.checked = false
                                }
                            }
                        }
                    }
                ]
                sensor.onClicked: {
                    showMessageLinksSwitch.checked = !showMessageLinksSwitch.checked
                }
            }

            function populatePreviewableSites() {
                let whitelistAsString = root.messagingStore.getLinkPreviewWhitelist()
                if(whitelistAsString == "")
                    return
                let whitelist = JSON.parse(whitelistAsString)
                if (!localAccountSensitiveSettings.whitelistedUnfurlingSites) {
                    localAccountSensitiveSettings.whitelistedUnfurlingSites = {}
                }
                previewableSites.clear()
                var oneEntryIsActive = false
                whitelist.forEach(entry => {
                    entry.isWhitelisted = localAccountSensitiveSettings.whitelistedUnfurlingSites[entry.address] || false
                    if (entry.isWhitelisted) {
                        oneEntryIsActive = true
                    }
                    previewableSites.append(entry)
                })
                if (oneEntryIsActive) {
                    showMessageLinksSwitch.checked = true
                }
            }

            Component.onCompleted: {
                populatePreviewableSites()
            }

            Column {
                id: siteColumn
                visible: showMessageLinksSwitch.checked
                width: parent.width

                StatusSectionHeadline {
                    id: labelWebsites
                    text: qsTr("Fine tune which sites to allow link previews")
                    width: parent.width
                }

                ListModel {
                    id: previewableSites
                }

                Connections {
                    target: Global
                    onSettingsLoaded: {
                        generalColumn.populatePreviewableSites()
                    }
                }

                // Manually add switch for the image unfurling
                StatusListItem {
                    anchors.left: parent.left
                    anchors.leftMargin: -Style.current.padding
                    anchors.right: parent.right
                    anchors.rightMargin: -Style.current.padding
                    implicitHeight: 64
                    title: qsTr("Image unfurling")
                    subTitle: qsTr("All images (links that contain an image extension) will be downloaded and displayed")
                    // TODO find a better icon for this
                    image.source: Style.svg('globe')
                    Component.onCompleted: {
                        if (localAccountSensitiveSettings.displayChatImages) {
                            showMessageLinksSwitch.checked = true
                        }
                    }
                    components: [
                        StatusSwitch {
                            id: imageSwitch
                            checked: localAccountSensitiveSettings.displayChatImages
                            onCheckedChanged: {
                                if (localAccountSensitiveSettings.displayChatImages !== checked) {
                                    localAccountSensitiveSettings.displayChatImages = checked
                                }
                            }
                        }
                    ]
                    sensor.onClicked: {
                        imageSwitch.checked = !imageSwitch.checked
                    }
                }

                Repeater {
                    id: sitesListView
                    model: previewableSites

                    delegate: Component {
                        StatusListItem {
                            property alias whitelistSwitch: siteSwitch
                            anchors.left: parent.left
                            anchors.leftMargin: -Style.current.padding
                            anchors.right: parent.right
                            anchors.rightMargin: -Style.current.padding
                            implicitHeight: 64
                            title: model.title
                            subTitle: model.address
                            image.source:  {
                                let filename;
                                switch (model.title.toLowerCase()) {
                                    case "youtube":
                                    case "youtube shortener":
                                        filename = "youtube"; break;
                                    case "github":
                                        filename = "github"; break;
                                    case "medium":
                                        filename = "medium"; break;
                                    case "tenor gifs":
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
                            components: [
                                StatusSwitch {
                                    id: siteSwitch
                                    checked: !!model.isWhitelisted
                                    onCheckedChanged: {
                                        let settings = localAccountSensitiveSettings.whitelistedUnfurlingSites

                                        if (!settings) {
                                            settings = {}
                                        }

                                        if (settings[address] === this.checked) {
                                            return
                                        }

                                        settings[address] = this.checked
                                        localAccountSensitiveSettings.whitelistedUnfurlingSites = settings
                                    }
                                }
                            ]
                            sensor.onClicked: {
                                siteSwitch.checked = !siteSwitch.checked
                            }
                        }
                    }
                }
            } // Site Column

            Separator {
                id: separator3
                visible: siteColumn.visible 
            }

            // SYNC WAKU SECTION
            StatusSectionHeadline {
                text: qsTr("Message syncing")
                width: parent.width
            }

            StatusListItem {
                anchors.left: parent.left
                anchors.leftMargin: -Style.current.padding
                anchors.right: parent.right
                anchors.rightMargin: -Style.current.padding
                title: qsTr("Waku nodes")
                label: root.messagingStore.getMailserverNameForNodeAddress(root.messagingStore.activeMailserver)
                components: [
                    StatusIcon {
                        icon: "chevron-down"
                        rotation: 270
                        color: Theme.palette.baseColor1
                    }
                ]
                sensor.onClicked: Global.openPopup(wakuNodeModalComponent)
            }

            Component {
                id: wakuNodeModalComponent
                WakuNodesModal {
                    messagingStore: root.messagingStore
                }
            }

            StatusSectionHeadline {
                text: qsTr("For security reasons, private chat history won't be synced.")
                width: parent.width
            }
            
        } // Column
    } // Item
} // ScrollView
