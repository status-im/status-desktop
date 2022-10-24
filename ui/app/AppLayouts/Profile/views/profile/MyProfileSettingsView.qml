import QtQuick 2.13
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.13

import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.controls.chat 1.0

import "../../popups"
import "../../stores"
import "../../controls"
import "../../panels"
import "../../../Onboarding/shared" as OnboardingComponents

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import SortFilterProxyModel 0.2

ColumnLayout {
    id: root

    property PrivacyStore privacyStore
    property ProfileStore profileStore
    property var accountSettings
    property var accountSensitiveSettings
    property var communitiesModel
    property var accountsModel

    readonly property bool dirty: descriptionPanel.displayName.text !== profileStore.displayName ||
                                  descriptionPanel.bio.text !== profileStore.bio ||
                                  profileStore.socialLinksDirty ||
                                  biometricsSwitch.checked != biometricsSwitch.currentStoredValue

    readonly property bool valid: !!descriptionPanel.displayName.text && descriptionPanel.displayName.valid

    function reset() {
        descriptionPanel.displayName.text = Qt.binding(() => { return profileStore.displayName })
        descriptionPanel.bio.text = Qt.binding(() => { return profileStore.bio })
        profileStore.resetSocialLinks()
        descriptionPanel.reevaluateSocialLinkInputs()
        biometricsSwitch.checked = Qt.binding(() => { return biometricsSwitch.currentStoredValue })
    }

    function save() {
        profileStore.setDisplayName(descriptionPanel.displayName.text)
        profileStore.setBio(descriptionPanel.bio.text)
        profileStore.saveSocialLinks()

        if (biometricsSwitch.checked)
            Global.openPopup(storePasswordModal)
        else
            accountSettings.storeToKeychainValue = Constants.keychain.storedValue.never;
    }

    function offerToStorePassword(password, runStoreToKeyChainPopup)
    {
        if (Qt.platform.os !== "osx")
            return;

        accountSettings.storeToKeychainValue = Constants.keychain.storedValue.store;
        root.privacyStore.storeToKeyChain(password);
    }

    ProfileHeader {
        Layout.fillWidth: true
        Layout.leftMargin: Style.current.padding
        Layout.rightMargin: Style.current.padding

        store: root.profileStore

        displayName: profileStore.name
        pubkey: profileStore.pubkey
        icon: profileStore.profileLargeImage
        imageSize: ProfileHeader.ImageSize.Big

        displayNameVisible: false
        pubkeyVisible: false
        emojiHashVisible: false
        editImageButtonVisible: true
    }

    SortFilterProxyModel {
        id: staticSocialLinksSubsetModel

        function filterPredicate(linkType) {
            return linkType === Constants.socialLinkType.twitter ||
                   linkType === Constants.socialLinkType.personalSite
        }

        sourceModel: profileStore.temporarySocialLinksModel
        filters: ExpressionFilter {
            expression: staticSocialLinksSubsetModel.filterPredicate(model.linkType)
        }
        sorters: RoleSorter {
            roleName: "linkType"
        }
    }

    ProfileDescriptionPanel {
        id: descriptionPanel

        Layout.fillWidth: true

        function reevaluateSocialLinkInputs()  {
            socialLinksModel = null
            socialLinksModel = staticSocialLinksSubsetModel
        }

        displayName.text: profileStore.displayName
        displayName.validationMode: StatusInput.ValidationMode.Always
        bio.text: profileStore.bio
        socialLinksModel: staticSocialLinksSubsetModel

        onSocialLinkChanged: profileStore.updateLink(uuid, text, url)
        onAddSocialLinksClicked: socialLinksModal.open()
    }

    SocialLinksModal {
        id: socialLinksModal
        profileStore: root.profileStore

        onClosed: descriptionPanel.reevaluateSocialLinkInputs()
    }

    StatusListItem {
        Layout.fillWidth: true
        visible: Qt.platform.os == "osx"
        title: qsTr("Biometric login and transaction authentication")
        asset.name: "touch-id"
        components: [ StatusSwitch {
            id: biometricsSwitch
            horizontalPadding: 0
            readonly property bool currentStoredValue: accountSettings.storeToKeychainValue === Constants.keychain.storedValue.store
            checked: currentStoredValue
        } ]
        onClicked: biometricsSwitch.toggle()
    }

    StatusTabBar {
        id: showcaseTabBar
        Layout.fillWidth: true

        function validateCurrentIndex() {

            let processedButtons = 0;

            while (!itemAt(currentIndex).enabled) {
                if (++processedButtons == count) {
                    currentIndex = -1;
                    break;
                }
                currentIndex = (currentIndex + 1) % count;
            }
        }

        StatusTabButton {
            enabled: accountSensitiveSettings.communitiesEnabled
            width: enabled ? implicitWidth : 0
            text: qsTr("Communities")
            onEnabledChanged: showcaseTabBar.validateCurrentIndex()
        }

        StatusTabButton {
            enabled: accountSensitiveSettings.isWalletEnabled
            width: enabled ? implicitWidth : 0
            text: qsTr("Accounts")
            onEnabledChanged: showcaseTabBar.validateCurrentIndex()
        }
    }

    StackLayout {
        Layout.fillWidth: true
        currentIndex: showcaseTabBar.currentIndex

        Column {
            Layout.fillWidth: true

            StatusBaseText {
                visible: communitiesRepeater.count == 0
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                color: Theme.palette.directColor1
                text: qsTr("You haven't joined any communities yet")
            }

            Repeater {
                id: communitiesRepeater
                model: communitiesModel

                CommunityDelegate {
                    width: parent.width
                    visible: joined
                    community: model
                    enabled: false
                }
            }
        }

        Column {
            StatusBaseText {
                visible: accountsRepeater.count == 0
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                color: Theme.palette.directColor1
                text: qsTr("You don't have any wallet accounts yet")
            }

            Repeater {
                id: accountsRepeater
                model: accountsModel

                WalletAccountDelegate {
                    width: parent.width
                    account: model
                    showShevronIcon: false
                    enabled: false
                }
            }
        }
    }

    Component {
        id: storePasswordModal

        OnboardingComponents.CreatePasswordModal {
            privacyStore: root.privacyStore
            onOfferToStorePassword: {
                root.offerToStorePassword(password, runStoreToKeychainPopup)
            }
        }
    }
}
