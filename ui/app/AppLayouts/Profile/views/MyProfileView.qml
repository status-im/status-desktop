import QtQuick 2.13
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.13

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
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

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
    }

    titleRowComponentLoader.sourceComponent: StatusButton {
        text: qsTr("Preview")
        onClicked: Global.openPopup(profilePreview)
        visible: !root.sideBySidePreview
    }

    dirty: (!descriptionPanel.isEnsName &&
            descriptionPanel.displayName.text !== profileStore.displayName) ||
            descriptionPanel.bio.text !== profileStore.bio ||
            profileStore.socialLinksDirty ||
            profileHeader.icon !== profileStore.profileLargeImage ||
            priv.hasAnyProfileShowcaseChanges
    saveChangesButtonEnabled: !!descriptionPanel.displayName.text && descriptionPanel.displayName.valid

    toast.saveChangesTooltipVisible: root.dirty
    toast.saveChangesTooltipText: qsTr("Invalid changes made to Identity")

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

        StatusTabButton {
            objectName: "assetsTabButton"
            width: implicitWidth
            text: qsTr("Assets")
        }

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

        property bool hasAnyProfileShowcaseChanges: false

        function reset() {
            descriptionPanel.displayName.text = Qt.binding(() => { return profileStore.displayName })
            descriptionPanel.bio.text = Qt.binding(() => { return profileStore.bio })
            profileStore.resetSocialLinks()
            profileHeader.icon = Qt.binding(() => { return profileStore.profileLargeImage })

            profileShowcaseCommunitiesPanel.reset()
            profileShowcaseAccountsPanel.reset()
            profileShowcaseCollectiblesPanel.reset()
            profileShowcaseAssetsPanel.reset()
            root.profileStore.requestProfileShowcasePreferences()
            hasAnyProfileShowcaseChanges = false
        }

        function save() {
            if (hasAnyProfileShowcaseChanges)
                profileStore.storeProfileShowcasePreferences()

            if (!descriptionPanel.isEnsName)
                profileStore.setDisplayName(descriptionPanel.displayName.text)
            profileStore.setBio(descriptionPanel.bio.text.trim())
            profileStore.saveSocialLinks()
            if (profileHeader.icon === "") {
                root.profileStore.removeImage()
            } else {
                profileStore.uploadImage(profileHeader.icon,
                                         profileHeader.cropRect.x.toFixed(),
                                         profileHeader.cropRect.y.toFixed(),
                                         (profileHeader.cropRect.x + profileHeader.cropRect.width).toFixed(),
                                         (profileHeader.cropRect.y + profileHeader.cropRect.height).toFixed());
            }

            reset()
        }
    }

    ColumnLayout {
        width: root.contentWidth

        StackLayout {
            id: stackLayout
            currentIndex: profileTabBar.currentIndex

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
                baseModel: root.communitiesModel
                showcaseModel: root.profileStore.profileShowcaseCommunitiesModel
                onShowcaseEntryChanged: priv.hasAnyProfileShowcaseChanges = true
            }

            // accounts
            ProfileShowcaseAccountsPanel {
                id: profileShowcaseAccountsPanel
                baseModel: root.walletStore.accounts
                showcaseModel: root.profileStore.profileShowcaseAccountsModel
                currentWallet: root.walletStore.overview.mixedcaseAddress
                onShowcaseEntryChanged: priv.hasAnyProfileShowcaseChanges = true
            }

            // collectibles
            ProfileShowcaseCollectiblesPanel {
                id: profileShowcaseCollectiblesPanel
                baseModel: root.profileStore.collectiblesModel
                showcaseModel: root.profileStore.profileShowcaseCollectiblesModel
                onShowcaseEntryChanged: priv.hasAnyProfileShowcaseChanges = true
            }

            // assets
            ProfileShowcaseAssetsPanel {
                id: profileShowcaseAssetsPanel

                baseModel: root.walletAssetsStore.groupedAccountAssetsModel // TODO: instantiate an assets model in profile module
                showcaseModel: root.profileStore.profileShowcaseAssetsModel
                addAccountsButtonVisible: root.profileStore.profileShowcaseAccountsModel.hiddenCount > 0
                formatCurrencyAmount: function(amount, symbol) {
                    return root.currencyStore.formatCurrencyAmount(amount, symbol)
                }

                onShowcaseEntryChanged: priv.hasAnyProfileShowcaseChanges = true
                onNavigateToAccountsTab: profileTabBar.currentIndex = 2
            }

            // web
            ProfileSocialLinksPanel {
                profileStore: root.profileStore
                socialLinksModel: root.profileStore.temporarySocialLinksModel
            }

            Component {
                id: profilePreview
                ProfileDialog {
                    publicKey: root.contactsStore.myPublicKey
                    profileStore: root.profileStore
                    contactsStore: root.contactsStore
                    networkConnectionStore: root.networkConnectionStore
                    onClosed: destroy()
                }
            }
        }
    }
}
