import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Extras 1.4

import shared.views 1.0
import AppLayouts.Profile.stores 1.0
import AppLayouts.Profile.views 1.0

import utils 1.0

import StatusQ 0.1
import Storybook 1.0

SplitView {
    id: root

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
                    signal saveBiometricsRequested(string keyUid, string credential)
                }

                readonly property string keyUid: keyUidInput.text

                function tryStoreToKeyChain(errorDescription) {
                    privacyModule.saveBiometricsRequested(keyUid, passwordInput.text)
                }

                function changePassword(from, to) {
                    privacyModule.passwordChanged(ctrlChangePassSuccess.checked, ctrlChangePassSuccess.checked ? "" : "Err changing password")
                }
            }

            keychain: loader.item
        }
    }

    Loader {
        id: loader

        sourceComponent: useMockedKeychainCheckBox.checked ? mockedKeychainComponent
                                                           : nativeKeychainComponent
    }

    Component {
        id: nativeKeychainComponent

        Keychain {
            service: "StatusStorybook"
        }
    }

    Component {
        id: mockedKeychainComponent

        KeychainMock {
            parent: root
            available: keychainAvailableCheckBox.checked
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 150

        logsView.logText: logs.logText

        ColumnLayout {
            RowLayout {
                Switch {
                    id: ctrlChangePassSuccess
                    text: "Password change will succeed"
                    checked: true
                }
            }

            RowLayout {
                Switch {
                    id: useMockedKeychainCheckBox
                    text: "Use Keychain mock"
                    checked: Qt.platform.os !== "osx"
                }
                Switch {
                    id: keychainAvailableCheckBox
                    text: "Keychain available (mocked only)"
                    enabled: useMockedKeychainCheckBox.checked
                }
            }

            RowLayout {
                Text {
                    text: "KeyUID: "
                }
                TextField {
                    id: keyUidInput
                    text: "0x42"
                }
                Text {
                    text: "Password: "
                }
                TextField {
                    id: passwordInput
                    text: "123456"
                }
            }
        }
    }
}

// category: Views
// status: good
// https://www.figma.com/file/d0G7m8X6ELjQlFOEKQpn1g/Profile-WIP?type=design&node-id=11-115317&mode=design&t=mBpxe2bJKzpseHGN-0
