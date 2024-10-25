import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Onboarding.views 1.0
import AppLayouts.Onboarding.stores 1.0

import SortFilterProxyModel 0.2

import Storybook 1.0

import utils 1.0

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        LoginView {
            id: loginView
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            startupStore: StartupStore {
                readonly property QtObject startupModuleInst: QtObject {
                    readonly property int remainingAttempts: 5

                    signal accountLoginError(string errorMessage)
                    signal obtainingPasswordSuccess
                    signal obtainingPasswordError

                    readonly property ListModel loginAccountsModel: ListModel {
                        ListElement {
                            keycardCreatedAccount: false
                            colorId: 1
                            colorHash: "0xAB34"
                            username: "Bob"
                            thumbnailImage: ""
                            icon: ""
                            keyUid: "uid_1"
                        }
                        ListElement {
                            keycardCreatedAccount: false
                            colorId: 2
                            colorHash: "0xAB35"
                            username: "John"
                            thumbnailImage: ""
                            icon: ""
                            keyUid: "uid_2"
                        }
                        ListElement {
                            keycardCreatedAccount: false
                            colorId: 3
                            colorHash: "0xAB38"
                            username: "8️⃣6️⃣.eth"
                            thumbnailImage: ""
                            icon: ""
                            keyUid: "uid_4"
                        }
                        ListElement {
                            keycardCreatedAccount: true
                            colorId: 4
                            colorHash: "0xAB37"
                            username: "Very long username that should eventually elide on the right side"
                            thumbnailImage: ""
                            icon: ""
                            keyUid: "uid_3"
                        }
                    }
                }

                readonly property QtObject selectedLoginAccount: QtObject {
                    readonly property bool keycardCreatedAccount: false
                    readonly property int colorId: 3
                    readonly property string username: "8️⃣6️⃣.eth"
                    readonly property string thumbnailImage: ""
                    readonly property string keyUid: "uid_4"
                    readonly property string icon: ""
                }

                readonly property QtObject currentStartupState: QtObject {
                    readonly property string stateType: Constants.startupState.loginKeycardEnterPassword
                }

                function setPassword(password) {
                    logs.logEvent("StartupStore::setPassword", ["password"], arguments)
                }

                function doPrimaryAction() {
                    logs.logEvent("StartupStore::doPrimaryAction")
                }

                function doSecondaryAction() {
                    logs.logEvent("StartupStore::doSecondaryAction")
                }

                function doTertiaryAction() {
                    logs.logEvent("StartupStore::doTertiaryAction")
                }

                function doQuaternaryAction() {
                    logs.logEvent("StartupStore::doQuaternaryAction")
                }

                function doQuinaryAction() {
                    logs.logEvent("StartupStore::doQuinaryAction")
                }

                function setSelectedLoginAccountByIndex(index) {
                    logs.logEvent("StartupStore::setSelectedLoginAccountByIndex", ["index"], arguments)
                }
            }

            QtObject {
                id: localAccountSettings
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText

            TextField {
                id: error
                placeholderText: "Error"
                onAccepted: loginView.startupStore.startupModuleInst.accountLoginError(text)
            }
        }
    }
}

// category: Views

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=1080%3A313192
