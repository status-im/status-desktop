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

    property ProfileStore profileStore
    property ContactsStore contactsStore

    property bool sendToAccountEnabled: false

    property alias communitiesShowcaseModel: showcaseModels.communitiesSourceModel
    property alias accountsShowcaseModel: showcaseModels.accountsSourceModel
    property alias collectiblesShowcaseModel: showcaseModels.collectiblesSourceModel
    property alias socialLinksShowcaseModel: showcaseModels.socialLinksSourceModel

    property bool sideBySidePreview
    property bool toastClashesWithDirtyBubble
    readonly property alias sideBySidePreviewComponent: myProfilePreviewComponent

    readonly property QtObject liveValues: QtObject {
        readonly property string displayName: descriptionPanel.displayName.text
        readonly property string bio: descriptionPanel.bio.text
        readonly property url profileLargeImage: profileHeader.previewIcon
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
    toast.loading: priv.expectedBackendResponses > 0
    toast.additionalComponent.visible: false // TODO:Issue #13997 // !toast.loading && root.toastClashesWithDirtyBubble && priv.saveRequestFailed
    toast.additionalComponent.text: qsTr("Changes could not be saved. Try again")
    toast.additionalComponent.color: Theme.palette.dangerColor1

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

    property QObject priv: QObject {
        id: priv

        readonly property bool hasAnyProfileShowcaseChanges: showcaseModels.dirty
        readonly property bool isIdentityTabDirty: (!descriptionPanel.isEnsName &&
                                                    descriptionPanel.displayName.text !== profileStore.displayName) ||
                                                   descriptionPanel.bio.text !== profileStore.bio ||
                                                   profileStore.socialLinksDirty ||
                                                   profileHeader.icon !== profileStore.profileLargeImage

        property ProfileShowcaseModels showcaseModels: ProfileShowcaseModels {
            id: showcaseModels

            communitiesSearcherText: profileShowcaseCommunitiesPanel.searcherText
            accountsSearcherText: profileShowcaseAccountsPanel.searcherText
            collectiblesSearcherText: profileShowcaseCollectiblesPanel.searcherText
        }

        // Used to track which are the expected backend responses (they can be 0, 1 or 2) depending on the dirty changes
        property int expectedBackendResponses: 0
        property bool saveRequestFailed: false

        // Maximum save action waiting time controller.
        // Backend response must be received before, otherwise it will be considered
        // a failure and UI will be released.
        property Timer saveLoadingTimeout : Timer {
            interval: 5000
            repeat: false
            running: toast.active && toast.loading

            onTriggered: {
                // Forcing a failure
                if(priv.expectedBackendResponses > 0) {
                    root.profileStore.profileSettingsSaveFailed()
                    priv.expectedBackendResponses = 0
                }
            }
        }

        // Save backend response received:
        property Connections profileStoreConnection: Connections {
            target: root.profileStore

            function onProfileIdentitySaveSucceeded() {
                priv.checkSaveResult(false)
            }

            function onProfileIdentitySaveFailed() {
                priv.checkSaveResult(true)
            }

            function onProfileShowcasePreferencesSaveSucceeded() {
                priv.checkSaveResult(false)
            }

            function onProfileShowcasePreferencesSaveFailed() {
                priv.checkSaveResult(true)
            }
        }

        function checkSaveResult(isFailure) {
            priv.expectedBackendResponses--
            if(isFailure)
                priv.saveRequestFailed = isFailure

            if(priv.expectedBackendResponses == 0) {
                if(priv.saveRequestFailed || isFailure) {
                    root.profileStore.profileSettingsSaveFailed()
                } else {
                    root.profileStore.profileSettingsSaveSucceeded()
                }
            }
        }

        function reset() {
            descriptionPanel.displayName.text = Qt.binding(() => { return profileStore.displayName })
            descriptionPanel.bio.text = Qt.binding(() => { return profileStore.bio })
            profileStore.resetSocialLinks()
            profileHeader.icon = Qt.binding(() => { return profileStore.profileLargeImage })

            priv.showcaseModels.revert()
            priv.saveRequestFailed = false
            priv.expectedBackendResponses = 0
            root.profileStore.requestProfileShowcasePreferences()
        }

        function save() {
            // IMPORTANT: Save implies 2 calls in backend but 1 result in UI so the order in current save method is relevant
            // First save stage: Review which are the expected responses before calling backend
            priv.expectedBackendResponses = 0
            priv.saveRequestFailed = false
            if(hasAnyProfileShowcaseChanges) {
                priv.expectedBackendResponses++
            }
            if (isIdentityTabDirty ) {
                priv.expectedBackendResponses++
            }

            // Second save stage: Ready to call backend
            if(priv.expectedBackendResponses > 0) {
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
        //     showcaseModel: root.contactsStore.showcaseContactAssetsModel
        //     addAccountsButtonVisible: root.contactsStore.showcaseContactAccountsModel.hiddenCount > 0
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
                sendToAccountEnabled: root.sendToAccountEnabled
                onClosed: destroy()
                dirtyValues: root.liveValues
                dirty: root.dirty

                showcaseCommunitiesModel: priv.showcaseModels.communitiesVisibleModel
                showcaseAccountsModel: priv.showcaseModels.accountsVisibleModel
                showcaseCollectiblesModel: priv.showcaseModels.collectiblesVisibleModel
                showcaseSocialLinksModel: priv.showcaseModels.socialLinksVisibleModel
                //showcaseAssetsModel: priv.showcaseModels.assetsVisibleModel
            }
        }

        Component {
            id: myProfilePreviewComponent
            MyProfilePreview {
                profileStore: root.profileStore
                contactsStore: root.contactsStore
                sendToAccountEnabled: root.sendToAccountEnabled
                dirtyValues: root.liveValues
                dirty: root.dirty

                showcaseCommunitiesModel: priv.showcaseModels.communitiesVisibleModel
                showcaseAccountsModel: priv.showcaseModels.accountsVisibleModel
                showcaseCollectiblesModel: priv.showcaseModels.collectiblesVisibleModel
                showcaseSocialLinksModel: priv.showcaseModels.socialLinksVisibleModel
                //showcaseAssetsModel: priv.showcaseModels.assetsVisibleModel
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
