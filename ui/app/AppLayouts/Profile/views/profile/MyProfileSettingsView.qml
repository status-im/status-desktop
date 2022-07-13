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
import "../../../Onboarding/shared" as OnboardingComponents

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

ColumnLayout {
    id: root

    property PrivacyStore privacyStore
    property ProfileStore profileStore
    property WalletStore walletStore

    readonly property bool dirty: displayNameInput.text != profileStore.displayName
                               || biometricsSwitch.checked != biometricsSwitch.currentStoredValue

    readonly property bool valid: !!displayNameInput.text && displayNameInput.valid

    function reset() {
        displayNameInput.text = Qt.binding(() => { return profileStore.displayName })
        biometricsSwitch.checked = Qt.binding(() => { return biometricsSwitch.currentStoredValue })
    }

    function save() {
        profileStore.setDisplayName(displayNameInput.text)

        if (biometricsSwitch.checked)
            Global.openPopup(storePasswordModal)
        else
            localAccountSettings.storeToKeychainValue = Constants.storeToKeychainValueNever;
    }

    function offerToStorePassword(password, runStoreToKeyChainPopup)
    {
        if (Qt.platform.os !== "osx")
            return;

        localAccountSettings.storeToKeychainValue = Constants.storeToKeychainValueStore;
        root.privacyStore.storeToKeyChain(password);
    }

    ProfileHeader {
        Layout.fillWidth: true
        Layout.leftMargin: Style.current.padding
        Layout.rightMargin: Style.current.padding

        displayName: profileStore.name
        pubkey: profileStore.pubkey
        icon: profileStore.profileLargeImage
        imageSize: ProfileHeader.ImageSize.Big
        
        displayNameVisible: false
        pubkeyVisible: false
        emojiHashVisible: false
        editImageButtonVisible: true
    }

    StatusInput {
        id: displayNameInput
        Layout.fillWidth: true
        label: qsTr("Display name")
        input.placeholderText: qsTr("Display Name")
        charLimit: 24
        input.text: root.profileStore.displayName
        validators: Constants.validators.displayName
    }

    StatusListItem {
        Layout.fillWidth: true
        visible: Qt.platform.os == "osx"
        leftPadding: 0
        rightPadding: 0
        title: qsTr("Biometric login and transaction authentication")
        icon.name: "touch-id"
        components: [ StatusSwitch {
            id: biometricsSwitch
            horizontalPadding: 0
            readonly property bool currentStoredValue: localAccountSettings.storeToKeychainValue === Constants.storeToKeychainValueStore
            checked: currentStoredValue
        } ]
        sensor.onClicked: biometricsSwitch.toggle()
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
            enabled: localAccountSensitiveSettings.communitiesEnabled
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
                font.pixelSize: 15
                color: Theme.palette.directColor1
                text: qsTr("You haven't joined any communities yet")
            }

            Repeater {
                id: communitiesRepeater
                model: communitiesModule.model

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
                font.pixelSize: 15
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
                    enabled: false
                }
            }
        }
    }

    Component {
        id: storePasswordModal

        OnboardingComponents.CreatePasswordModal {
            privacyStore: root.privacyStore
            storingPasswordModal: true
            onOfferToStorePassword: {
                root.offerToStorePassword(password, runStoreToKeychainPopup)
            }
        }
    }

}
