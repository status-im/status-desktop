import QtQuick 2.13
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.13
import QtQml 2.15

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.stores 1.0
import shared.controls.chat 1.0

import "../popups"
import "../stores"
import "../controls"
import "./profile"

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import AppLayouts.Profile.helpers 1.0
import AppLayouts.Profile.panels 1.0
import AppLayouts.Wallet.stores 1.0

SettingsContentBase {
    id: root

    property WalletStore walletStore
    property ProfileStore profileStore
    property PrivacyStore privacyStore
    property ContactsStore contactsStore
    property NetworkConnectionStore networkConnectionStore
    required property WalletAssetsStore walletAssetsStore
    required property CurrenciesStore currencyStore

    property var communitiesModel

    property bool sideBySidePreview

    property QtObject dirtyValues: QtObject {
        property string displayName: descriptionPanel.displayName.text
        property string bio: descriptionPanel.bio.text
        property url profileLargeImage: profileHeader.previewIcon
        property var socialLinks: priv.showcaseModels.socialLinksVisibleModel
        property var communitiesModel: priv.showcaseModels.communitiesVisibleModel
        property var accountsModel: priv.showcaseModels.accountsVisibleModel
        property var collectiblesModel: priv.showcaseModels.collectiblesVisibleModel
    }

    enum TabIndex {
        Identity = 0,
        Communities = 1,
        Accounts = 2,
        Collectibles = 3,
        //Assets = 4,
        Web = 4
    }

    titleRowComponentLoader.sourceComponent: StatusButton {
        text: qsTr("Preview")
        onClicked: Global.openPopup(profilePreview)
        visible: !root.sideBySidePreview
    }

    dirty: priv.isIdentityTabDirty ||
           priv.hasAnyProfileShowcaseChanges
    saveChangesButtonEnabled: !!descriptionPanel.displayName.text && descriptionPanel.displayName.valid

    toast.saveChangesTooltipText: saveChangesButtonEnabled ? "" : qsTr("Invalid changes made to Identity")
    autoscrollWhenDirty: profileTabBar.currentIndex === MyProfileView.Identity

    onResetChangesClicked: priv.reset()

    onSaveChangesClicked: priv.save()

    bottomHeaderComponents: StatusTabBar {
        id: profileTabBar

        StatusTabButton {
            objectName: "identityTabButton"
            width: implicitWidth
            leftPadding: 0
            text: qsTr("Identity")
        }

        StatusTabButton {
            objectName: "communitiesTabButton"
            width: implicitWidth
            text: qsTr("Communities")
        }

        StatusTabButton {
            objectName: "accountsTabButton"
            width: implicitWidth
            text: qsTr("Accounts")
        }

        StatusTabButton {
            objectName: "collectiblesTabButton"
            width: implicitWidth
            text: qsTr("Collectibles")
        }

        // TODO: Uncomment when assets tab is implemented
        // StatusTabButton {
        //     objectName: "assetsTabButton"
        //     width: implicitWidth
        //     text: qsTr("Assets")
        // }

        StatusTabButton {
            objectName: "webTabButton"
            width: implicitWidth
            text: qsTr("Web")
        }
    }

    onVisibleChanged: if (visible) profileStore.requestProfileShowcasePreferences()
    Component.onCompleted: profileStore.requestProfileShowcasePreferences()

    readonly property var priv: QtObject {
        id: priv

        property bool hasAnyProfileShowcaseChanges: showcaseModels.dirty
        property bool isIdentityTabDirty: (!descriptionPanel.isEnsName &&
                                            descriptionPanel.displayName.text !== profileStore.displayName) ||
                                            descriptionPanel.bio.text !== profileStore.bio ||
                                            profileStore.socialLinksDirty ||
                                            profileHeader.icon !== profileStore.profileLargeImage

        property ProfileShowcaseModels showcaseModels: ProfileShowcaseModels {
            communitiesSourceModel: root.communitiesModel
            communitiesShowcaseModel: root.profileStore.showcasePreferencesCommunitiesModel
            communitiesSearcherText: profileShowcaseCommunitiesPanel.searcherText
            
            accountsSourceModel: root.walletStore.ownAccounts
            accountsShowcaseModel: root.profileStore.showcasePreferencesAccountsModel
            accountsSearcherText: profileShowcaseAccountsPanel.searcherText

            collectiblesSourceModel: root.profileStore.collectiblesModel
            collectiblesShowcaseModel: root.profileStore.showcasePreferencesCollectiblesModel
            collectiblesSearcherText: profileShowcaseCollectiblesPanel.searcherText

            socialLinksSourceModel: root.profileStore.showcasePreferencesSocialLinksModel
        }

        function reset() {
            descriptionPanel.displayName.text = Qt.binding(() => { return profileStore.displayName })
            descriptionPanel.bio.text = Qt.binding(() => { return profileStore.bio })
            profileStore.resetSocialLinks()
            profileHeader.icon = Qt.binding(() => { return profileStore.profileLargeImage })

            priv.showcaseModels.revert()
            root.profileStore.requestProfileShowcasePreferences()
        }

        function save() {
            // Accounts, Communities, Assets, Collectibles and social links info
            if (hasAnyProfileShowcaseChanges) {
                root.profileStore.saveProfileShowcasePreferences(showcaseModels.buildJSONModelsCurrentState())
            }

            // Identity info
            if (isIdentityTabDirty) {
                root.profileStore.saveProfileIdentity(descriptionPanel.displayName.text,
                                                    descriptionPanel.bio.text.trim(),
                                                    profileHeader.icon,
                                                    profileHeader.cropRect.x,
                                                    profileHeader.cropRect.y,
                                                    (profileHeader.cropRect.x + profileHeader.cropRect.width),
                                                    (profileHeader.cropRect.y + profileHeader.cropRect.height))
                profileHeader.icon = Qt.binding(() => { return profileStore.profileLargeImage })
            }
        }
    }

    StackLayout {
        id: stackLayout

        width: root.contentWidth
        height: profileTabBar.currentIndex === MyProfileView.Web ? implicitHeight : root.contentHeight
        currentIndex: profileTabBar.currentIndex

        onCurrentIndexChanged: {
            if(root.profileStore.isFirstShowcaseInteraction && currentIndex !== MyProfileView.TabIndex.Identity) {
                root.profileStore.setIsFirstShowcaseInteraction()
                Global.openPopup(profileShowcaseInfoPopup)
            }
        }

        // identity
        ColumnLayout {
            objectName: "myProfileSettingsView"
            ProfileHeader {
                id: profileHeader
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

            ProfileDescriptionPanel {
                id: descriptionPanel

                readonly property bool isEnsName: profileStore.preferredName

                Layout.fillWidth: true

                displayName.focus: !isEnsName
                displayName.input.edit.readOnly: isEnsName
                displayName.text: profileStore.name
                displayName.validationMode: StatusInput.ValidationMode.Always
                displayName.validators: isEnsName ? [] : Constants.validators.displayName
                bio.text: profileStore.bio
            }
        }

        // communities
        ProfileShowcaseCommunitiesPanel {
            id: profileShowcaseCommunitiesPanel
            inShowcaseModel: priv.showcaseModels.communitiesVisibleModel
            hiddenModel: priv.showcaseModels.communitiesHiddenModel
            showcaseLimit: root.profileStore.getProfileShowcaseEntriesLimit()

            onChangePositionRequested: function (from, to) {
                priv.showcaseModels.changeCommunityPosition(from, to)
            }
            onSetVisibilityRequested: function (key, toVisibility) {
                priv.showcaseModels.setCommunityVisibility(key, toVisibility)
            }
        }

        // accounts
        ProfileShowcaseAccountsPanel {
            id: profileShowcaseAccountsPanel
            inShowcaseModel: priv.showcaseModels.accountsVisibleModel
            hiddenModel: priv.showcaseModels.accountsHiddenModel
            showcaseLimit: root.profileStore.getProfileShowcaseEntriesLimit()
            currentWallet: root.walletStore.overview.mixedcaseAddress

            onChangePositionRequested: function (from, to) {
                priv.showcaseModels.changeAccountPosition(from, to)
            
            }
            onSetVisibilityRequested: function (key, toVisibility) {
                priv.showcaseModels.setAccountVisibility(key, toVisibility)
            }
        }

        // collectibles
        ProfileShowcaseCollectiblesPanel {
            id: profileShowcaseCollectiblesPanel
            inShowcaseModel: priv.showcaseModels.collectiblesVisibleModel
            hiddenModel: priv.showcaseModels.collectiblesHiddenModel
            showcaseLimit: root.profileStore.getProfileShowcaseEntriesLimit()
            addAccountsButtonVisible: priv.showcaseModels.accountsHiddenModel.count > 0
            
            onNavigateToAccountsTab: profileTabBar.currentIndex = MyProfileView.TabIndex.Accounts
            
            onChangePositionRequested: function (from, to) {
                priv.showcaseModels.changeCollectiblePosition(from, to)
            }

            onSetVisibilityRequested: function (key, toVisibility) {
                priv.showcaseModels.setCollectibleVisibility(key, toVisibility)
            }
        }

        // assets
        // TODO: Integrate the assets tab with the new backend
        // ProfileShowcaseAssetsPanel {
        //     id: profileShowcaseAssetsPanel

        //     baseModel: root.walletAssetsStore.groupedAccountAssetsModel // TODO: instantiate an assets model in profile module
        //     showcaseModel: root.profileStore.profileShowcaseAssetsModel
        //     addAccountsButtonVisible: root.profileStore.profileShowcaseAccountsModel.hiddenCount > 0
        //     formatCurrencyAmount: function(amount, symbol) {
        //         return root.currencyStore.formatCurrencyAmount(amount, symbol)
        //     }

        //     onShowcaseEntryChanged: priv.hasAnyProfileShowcaseChanges = true
        //     onNavigateToAccountsTab: profileTabBar.currentIndex = MyProfileView.TabIndex.Accounts
        // }

        // web
        ProfileSocialLinksPanel {
            showcaseLimit: root.profileStore.getProfileShowcaseSocialLinksLimit()
            socialLinksModel: priv.showcaseModels.socialLinksVisibleModel

            onAddSocialLink: function(url, text) {
                priv.showcaseModels.appendSocialLink({ showcaseKey: "", text: text, url: url })
            }

            onUpdateSocialLink: function(index, url, text) {
                priv.showcaseModels.updateSocialLink(index, { text: text, url: url })
            }

            onRemoveSocialLink: function(index) {
                priv.showcaseModels.removeSocialLink(index)
            }

            onChangePosition: function(from, to) {
                priv.showcaseModels.changeSocialLinkPosition(from, to)
            }
        }

        Component {
            id: profilePreview
            ProfileDialog {
                publicKey: root.contactsStore.myPublicKey
                profileStore: root.profileStore
                contactsStore: root.contactsStore
                networkConnectionStore: root.networkConnectionStore
                onClosed: destroy()
                dirtyValues: root.dirtyValues
                dirty: root.dirty
            }
        }

        Component {
            id: profileShowcaseInfoPopup

            ProfileShowcaseInfoPopup {
                destroyOnClose: true
            }
        }
    }
}
