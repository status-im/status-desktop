import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Extras 1.4

import shared.views 1.0
import AppLayouts.Profile.stores 1.0
import AppLayouts.Profile.views 1.0

import utils 1.0

import Storybook 1.0

SplitView {
    orientation: Qt.Vertical

    Logs { id: logs }

    StackLayout {
        id: wrapper
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        ChangePasswordView {
            id: passwordView

            implicitWidth: parent.width
            implicitHeight: parent.height

            contentWidth: 560
            sectionTitle: "Password"

            passwordStrengthScoreFunction: (newPass) => Math.min(newPass.length-1, 4)

            privacyStore: PrivacyStore {
                 property QtObject privacyModule: QtObject {
                    signal passwordChanged(success: bool, errorMsg: string)
                    signal storeToKeychainError(errorDescription: string)
                    signal storeToKeychainSuccess()
                 }

                 function tryStoreToKeyChain(errorDescription) {
                    if (generateMacKeyChainStoreError.checked) {
                        privacyModule.storeToKeychainError(errorDescription)
                    } else {
                        passwordView.localAccountSettings.storeToKeychainValue = Constants.keychain.storedValue.store
                        privacyModule.storeToKeychainSuccess()
                        privacyModule.passwordChanged(true, "")
                    }
                 }

                 function tryRemoveFromKeyChain() {
                    if (generateMacKeyChainStoreError.checked) {
                        privacyModule.storeToKeychainError("Error removing from keychain")
                    } else {
                        passwordView.localAccountSettings.storeToKeychainValue = Constants.keychain.storedValue.notNow
                        privacyModule.storeToKeychainSuccess()
                    }
                 }

                 function changePassword(from, to) {
                     privacyModule.passwordChanged(ctrlChangePassSuccess.checked, ctrlChangePassSuccess.checked ? "" : "Err changing password")
                 }
            }

            property QtObject localAccountSettings: QtObject {
                property string storeToKeychainValue: Constants.keychain.storedValue.notNow
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 150

        logsView.logText: logs.logText

        RowLayout {
            Switch {
                id: generateMacKeyChainStoreError
                text: "Generate key chain error"
                checked: false
            }
            Switch {
                id: ctrlChangePassSuccess
                text: "Password change will succeed"
                checked: true
            }
        }
    }
}

// category: Views
// status: good
// https://www.figma.com/file/d0G7m8X6ELjQlFOEKQpn1g/Profile-WIP?type=design&node-id=11-115317&mode=design&t=mBpxe2bJKzpseHGN-0
