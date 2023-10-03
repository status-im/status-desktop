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
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            startupStore: StartupStore {
                readonly property QtObject startupModuleInst: QtObject {
                    signal accountLoginError
                    signal obtainingPasswordSuccess
                    signal obtainingPasswordError

                    readonly property ListModel loginAccountsModel: ListModel {
                        ListElement {
                            keycardCreatedAccount: false
                            colorId: 1
                            colorHash: "0xAB34"
                            username: "Bob"
                            thumbnailImage: ""
                            keyUid: "uid_1"
                        }
                        ListElement {
                            keycardCreatedAccount: false
                            colorId: 2
                            colorHash: "0xAB34"
                            username: "John"
                            thumbnailImage: ""
                            keyUid: "uid_2"
                        }
                    }
                }

                readonly property QtObject selectedLoginAccount: QtObject {
                    readonly property bool keycardCreatedAccount: false
                    readonly property int colorId: 0
                    readonly property string username: "Alice"
                    readonly property string thumbnailImage: ""
                    readonly property string keyUid: "uid_3"
                }

                readonly property QtObject currentStartupState: QtObject {
                    readonly property string stateType: Constants.startupState.welcome
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
        }
    }

    Control {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        // model editor will go here
    }
}

// category: Views

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=1080%3A313192
