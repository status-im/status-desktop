import QtQuick

import StatusQ

import AppLayouts.Profile.stores as ProfileStores

import shared.popups
import utils

QtObject {
    id: root

    required property var popupParent
    required property ProfileStores.PrivacyStore privacyStore
    required property Keychain keychain

    function openPopup() {
        let enableBiometricsPopupInst = enableBiometricsPopup.createObject(popupParent)
        enableBiometricsPopupInst.open()
    }

    function showSuccessToast() {
        Global.displayToastMessage(
        qsTr("Biometric login and transaction authentication enabled for this device"),
        "", "checkmark-circle", false, Constants.ephemeralNotificationType.success, "")
    }

    readonly property Component enableBiometricsPopup: Component {
        EnableBiometricsPopup {
            id: popup

            onClosed: destroy()

            onEnableBiometricsRequested: () => {
                // Enable Biometrics flow
                popup.loading = true
                root.privacyStore.tryStoreToKeyChain()
            }

            Connections {
                target: root.privacyStore.privacyModule

                function onSaveBiometricsRequested(keyUid, credential) {
                    // If Password not retrieved
                    if (keyUid === "" || credential === "") {
                        popup.loading = false
                        popup.errorText = qsTr("Biometric setup failed. Try again.")
                        return
                    }

                    const status = keychain.saveCredential(keyUid, credential)

                    if (status !== Keychain.StatusSuccess) {
                        popup.loading = false
                        popup.errorText = qsTr("Biometric setup failed. Try again.")
                    }
                }
            }
            Connections {
                target: keychain

                function onCredentialSaved(account: string) {
                    popup.loading = false
                    popup.close()
                    root.showSuccessToast()
                }

                function onGetCredentialRequestCompleted(status, secret) {
                    if (status !== Keychain.StatusSuccess) {
                        popup.loading = false
                        popup.errorText = qsTr("Biometric setup failed. Try again.")
                    }
                }
            }
        }
    }
}
