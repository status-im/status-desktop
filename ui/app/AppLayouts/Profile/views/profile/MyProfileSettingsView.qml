import QtQuick 2.13
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.13

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.controls.chat 1.0

import "../../popups"
import "../../stores"
import "../../controls"
import "../../panels"

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import SortFilterProxyModel 0.2

ColumnLayout {
    id: root

    property PrivacyStore privacyStore
    property ProfileStore profileStore
    property WalletStore walletStore
    property var communitiesModel

    property QtObject dirtyValues: QtObject {
        property string displayName: descriptionPanel.displayName.text
        property string bio: descriptionPanel.bio.text
        property bool biomentricValue: biometricsSwitch.checked
        property url profileLargeImage: profileHeader.previewIcon
    }

    readonly property bool dirty: (!descriptionPanel.isEnsName &&
                                   descriptionPanel.displayName.text !== profileStore.displayName) ||
                                  descriptionPanel.bio.text !== profileStore.bio ||
                                  profileStore.socialLinksDirty ||
                                  biometricsSwitch.checked !== biometricsSwitch.currentStoredValue ||
                                  profileHeader.icon !== profileStore.profileLargeImage

    readonly property bool valid: !!descriptionPanel.displayName.text && descriptionPanel.displayName.valid

    function reset() {
        descriptionPanel.displayName.text = Qt.binding(() => { return profileStore.displayName })
        descriptionPanel.bio.text = Qt.binding(() => { return profileStore.bio })
        profileStore.resetSocialLinks()
        descriptionPanel.reevaluateSocialLinkInputs()
        biometricsSwitch.checked = Qt.binding(() => { return biometricsSwitch.currentStoredValue })
        profileHeader.icon = Qt.binding(() => { return profileStore.profileLargeImage })
    }

    function save() {
        if (!descriptionPanel.isEnsName)
            profileStore.setDisplayName(descriptionPanel.displayName.text)
        profileStore.setBio(descriptionPanel.bio.text)
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

        if (biometricsSwitch.checked && !biometricsSwitch.currentStoredValue)
            root.privacyStore.tryStoreToKeyChain()
        else if (!biometricsSwitch.checked)
            root.privacyStore.tryRemoveFromKeyChain()

        reset()
    }

    Connections {
        target: Qt.platform.os === Constants.mac? root.privacyStore.privacyModule : null

        function onStoreToKeychainError(errorDescription: string) {
            root.reset()
        }

        function onStoreToKeychainSuccess() {
            root.reset()
        }
    }

    ProfileHeader {
        id: profileHeader
        Layout.fillWidth: true
        Layout.leftMargin: Style.current.padding
        Layout.rightMargin: Style.current.padding
        Layout.topMargin: 20
        Layout.bottomMargin: 20

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

        readonly property bool isEnsName: profileStore.preferredName

        function reevaluateSocialLinkInputs()  {
            socialLinksModel = null
            socialLinksModel = staticSocialLinksSubsetModel
        }

        Layout.fillWidth: true

        displayName.focus: !isEnsName
        displayName.input.edit.readOnly: isEnsName
        displayName.text: profileStore.name
        displayName.validationMode: StatusInput.ValidationMode.Always
        displayName.validators: isEnsName ? [] : Constants.validators.displayName
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
        visible: Qt.platform.os === Constants.mac
        title: qsTr("Biometric login and transaction authentication")
        asset.name: "touch-id"
        components: [ StatusSwitch {
            id: biometricsSwitch
            horizontalPadding: 0
            readonly property bool currentStoredValue: localAccountSettings.storeToKeychainValue === Constants.keychain.storedValue.store
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
                if (++processedButtons === count) {
                    currentIndex = -1;
                    break;
                }
                currentIndex = (currentIndex + 1) % count;
            }
        }

        StatusTabButton {
            width: enabled ? implicitWidth : 0
            text: qsTr("Communities")
            onEnabledChanged: showcaseTabBar.validateCurrentIndex()
        }

        StatusTabButton {
            enabled: localAccountSensitiveSettings.isWalletEnabled
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
                model: root.communitiesModel

                CommunityDelegate {
                    width: parent.width
                    visible: joined
                    community: model
                    sensor.enabled: false
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
                model: root.walletStore.accounts

                WalletAccountDelegate {
                    width: parent.width
                    account: model
                    showShevronIcon: false
                    sensor.enabled: false
                }
            }
        }
    }
}
