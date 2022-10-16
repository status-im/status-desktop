import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Controls.Universal 2.12
import QtQuick.Layouts 1.13

import SortFilterProxyModel 0.2

import utils 1.0
import shared 1.0
import shared.panels 1.0

import "stores"
import "popups"
import "views"

import StatusQ.Layout 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

StatusSectionLayout {
    id: root

    property ProfileSectionStore store
    property var globalStore
    property var systemPalette
    property var emojiPopup

    backButtonName: root.store.backButtonName
    notificationCount: root.store.unreadNotificationsCount

    onNotificationButtonClicked: Global.openActivityCenterPopup()
    onBackButtonClicked: {
        switch (profileContainer.currentIndex) {
        case Constants.settingsSubsection.contacts:
            Global.changeAppSectionBySectionType(Constants.appSection.profile, Constants.settingsSubsection.messaging)
            break;
        case Constants.settingsSubsection.wallet:
            walletView.resetStack();
            break;
        case Constants.settingsSubsection.keycard:
            keycardView.handleBackAction();
            break;
        }
    }

    QtObject {
        id: d

        readonly property int topMargin: 0
        readonly property int bottomMargin: 56
        readonly property int leftMargin: 64
        readonly property int rightMargin: 64

        readonly property int contentWidth: 560
    }

    function getColorForUser(model) {
        return (model.type === Constants.settingsSection.exemptions.oneToOneChat? Utils.colorForPubkey(model.itemId) : model.color)
    }

    function getRingForUser(model) {
        return (model.type === Constants.settingsSection.exemptions.oneToOneChat? Utils.getColorHashAsJson(model.itemId) : undefined)
    }

    // note: this sanitizes the data expected by the Exemption component
    // this will be moved to a layer above later as the qml is refactored
    // it uses helpers defined as local functions due to an issue accessing imports
    SortFilterProxyModel {
        id: exemptionsModel
        sourceModel: root.store.notificationsStore.exemptionsModel
        proxyRoles: [
            ExpressionRole {
                name: "color"
                expression: root.getColorForUser(model)
            },
            ExpressionRole {
                name: "ring"
                expression: root.getRingForUser(model)
            }
        ]
    }
    leftPanel: LeftTabView {
        id: leftTab
        store: root.store
        anchors.fill: parent
        anchors.topMargin: d.topMargin
        onMenuItemClicked: {
            if (profileContainer.currentItem.dirty) {
                event.accepted = true;
                profileContainer.currentItem.notifyDirty();
            }
        }
    }

    centerPanel: Item {
        anchors.fill: parent

        StackLayout {
            id: profileContainer

            readonly property var currentItem: (currentIndex >= 0 && currentIndex < children.length) ? children[currentIndex] : null

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: d.bottomMargin
            anchors.leftMargin: d.leftMargin
            anchors.rightMargin: d.rightMargin

            currentIndex: Global.settingsSubsection

            onCurrentIndexChanged: {
                if(visibleChildren[0] === ensContainer){
                    ensContainer.goToStart();
                }
                if (currentIndex === 1) {
                    root.store.backButtonName = root.store.getNameForSubsection(Constants.settingsSubsection.messaging);
                }
                else if (currentIndex === Constants.settingsSubsection.keycard) {
                    keycardView.handleBackAction();
                }
                else {
                    root.store.backButtonName = "";
                }
            }

            MyProfileView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                walletStore: root.store.walletStore
                profileStore: root.store.profileStore
                privacyStore: root.store.privacyStore
                contactsStore: root.store.contactsStore
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.profile)
                contentWidth: d.contentWidth
            }

            ContactsView {
                implicitWidth: parent.width
                implicitHeight: parent.height
                contactsStore: root.store.contactsStore
                sectionTitle: qsTr("Contacts")
                contentWidth: d.contentWidth
            }

            EnsView {
                // TODO: we need to align structure for the entire this part using `SettingsContentBase` as root component
                // TODO: handle structure for this subsection to match style used in onther sections
                // using `SettingsContentBase` component as base.
                id: ensContainer
                implicitWidth: parent.width
                implicitHeight: parent.height

                ensUsernamesStore: root.store.ensUsernamesStore
                contactsStore: root.store.contactsStore
                stickersStore: root.store.stickersStore

                profileContentWidth: d.contentWidth
            }

            MessagingView {
                implicitWidth: parent.width
                implicitHeight: parent.height
                advancedStore: root.store.advancedStore
                messagingStore: root.store.messagingStore
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.messaging)
                contactsStore: root.store.contactsStore
                contentWidth: d.contentWidth
            }

            WalletView {
                id: walletView
                implicitWidth: parent.width
                implicitHeight: parent.height
                rootStore: root.store
                walletStore: root.store.walletStore
                emojiPopup: root.emojiPopup
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.wallet)
                contentWidth: d.contentWidth
            }

            AppearanceView {
                id: appearanceView
                implicitWidth: parent.width
                implicitHeight: parent.height
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.appearance)
                contentWidth: d.contentWidth

                currentFontSize: localAccountSensitiveSettings.fontSize
                currentTheme: localAppSettings.theme

                readonly property int initialZoomValue: {
                    let scaleFactorStr = root.store.appearanceStore.readTextFile(uiScaleFilePath)
                    if (scaleFactorStr === "") {
                        return 100
                    }
                    let scaleFactor = parseFloat(scaleFactorStr)
                    if (isNaN(scaleFactor)) {
                        return 100
                    }
                    return scaleFactor * 100
                }

                currentZoom: initialZoomValue

                onFontSizeChanged: (value) => {
                    Style.changeFontSize(value)
                    Theme.updateFontSize(value)
                }

                onZoomChanged: (value) => {
                    if (value !== initialZoomValue) {
                        root.store.appearanceStore.writeTextFile(uiScaleFilePath, value / 100.0)
                        confirmAppRestartModal.open()
                    }
                }

                onThemeChanged: (value) => {
                    let current = Universal.System
                    if (value == 0) {
                        current = Universal.Light;
                    } else if (value == 1) {
                        current = Universal.Dark;
                    }
                    localAppSettings.theme = current
                    Style.changeTheme(current, root.systemPalette.isCurrentSystemThemeDark())
                }
            }

            LanguageView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                languageStore: root.store.languageStore
                currencyStore: root.store.walletStore.currencyStore
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.language)
                contentWidth: d.contentWidth
            }

            NotificationsView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                notificationsStore: root.store.notificationsStore
                devicesStore: root.store.devicesStore
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.notifications)
                contentWidth: d.contentWidth

                hasMultipleDevices: root.store.devicesStore.devicesModel.count > 0
                exemptionsModel: exemptionsModel
            }

            DevicesView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                devicesStore: root.store.devicesStore
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.devicesSettings)
                contentWidth: d.contentWidth
            }

            BrowserView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                store: root.store
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.browserSettings)
                contentWidth: d.contentWidth
            }

            AdvancedView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                advancedStore: root.store.advancedStore
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.advanced)
                contentWidth: d.contentWidth
            }

            AboutView {
                implicitWidth: parent.width
                implicitHeight: parent.height
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.about)
                contentWidth: d.contentWidth

                store: QtObject {
                    function checkForUpdates() {
                        return root.store.checkForUpdates()
                    }

                    function getCurrentVersion() {
                        return root.store.getCurrentVersion()
                    }

                    function getReleaseNotes() {
                        openLink("https://github.com/status-im/status-desktop/releases/%1".arg(getCurrentVersion()))
                    }

                    function openLink(url) {
                        Global.openLink(url)
                 }
                }
            }

            CommunitiesView {
                implicitWidth: parent.width
                implicitHeight: parent.height

                profileSectionStore: root.store
                rootStore: root.globalStore
                contactStore: root.store.contactsStore
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.communitiesSettings)
                contentWidth: d.contentWidth
            }

            KeycardView {
                id: keycardView
                implicitWidth: parent.width
                implicitHeight: parent.height

                profileSectionStore: root.store
                keycardStore: root.store.keycardStore
                sectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.keycard)
                mainSectionTitle: root.store.getNameForSubsection(Constants.settingsSubsection.keycard)
                contentWidth: d.contentWidth
            }
        }
    } // Item

    ConfirmAppRestartModal {
        id: confirmAppRestartModal
        onClosed: {
            root.store.appearanceStore.writeTextFile(uiScaleFilePath, appearanceView.currentZoom / 100.0)
            appearanceView.setZoom(appearanceView.currentZoom)
        }
    }


} // StatusAppTwoPanelLayout
