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

ColumnLayout {
    id: root

    spacing: 20

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
        biometricsSwitch.checked = Qt.binding(() => { return biometricsSwitch.currentStoredValue })
        profileHeader.icon = Qt.binding(() => { return profileStore.profileLargeImage })
    }

    function save() {
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

        if (biometricsSwitch.checked && !biometricsSwitch.currentStoredValue)
            root.privacyStore.tryStoreToKeyChain()
        else if (!biometricsSwitch.checked)
            root.privacyStore.tryRemoveFromKeyChain()

        reset()
    }

    Connections {
        target: Qt.platform.os === Constants.mac ? root.privacyStore.privacyModule : null

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

    Separator {
        Layout.fillWidth: true
    }

    ProfileSocialLinksPanel {
        Layout.fillWidth: true
        profileStore: root.profileStore
        socialLinksModel: root.profileStore.temporarySocialLinksModel
    }

    Separator {
        Layout.fillWidth: true
    }

    StatusBaseText {
        visible: Qt.platform.os === Constants.mac
        text: qsTr("Security")
        color: Theme.palette.baseColor1
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

    Separator {
        Layout.fillWidth: true
        visible: Qt.platform.os === Constants.mac
    }

    StatusBaseText {
        text: qsTr("Showcase")
        color: Theme.palette.baseColor1
    }

    StatusTabBar {
        id: showcaseTabBar

        StatusTabButton {
            width: implicitWidth
            leftPadding: 0
            text: qsTr("Communities")
        }

        StatusTabButton {
            width: implicitWidth
            text: qsTr("Accounts")
        }

        StatusTabButton {
            width: implicitWidth
            text: qsTr("Collectibles")
        }

        StatusTabButton {
            width: implicitWidth
            text: qsTr("Assets")
        }
    }

    StackLayout {
        id: showcaseStack
        Layout.fillWidth: true
        currentIndex: showcaseTabBar.currentIndex

        ProfileShowcaseCommunitiesPanel {
            Layout.minimumHeight: implicitHeight
            Layout.maximumHeight: implicitHeight
            baseModel: root.communitiesModel
        }

        ProfileShowcaseAccountsPanel {
            Layout.minimumHeight: implicitHeight
            Layout.maximumHeight: implicitHeight
            baseModel: root.walletStore.accounts
            currentWallet: root.walletStore.overview.mixedcaseAddress
        }

        ProfileShowcaseCollectiblesPanel {
            Layout.minimumHeight: implicitHeight
            Layout.maximumHeight: implicitHeight
            baseModel: root.walletStore.collectibles
        }

        ProfileShowcaseAssetsPanel {
            Layout.minimumHeight: implicitHeight
            Layout.maximumHeight: implicitHeight
            baseModel: root.walletStore.assets
        }
    }
}
