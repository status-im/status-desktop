import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Storybook 1.0

import mainui 1.0
import utils 1.0
import AppLayouts.Profile.views 1.0
import shared.stores 1.0

SplitView {
    id: root
    orientation: Qt.Vertical

    Logs { id: logs }

    Popups {
        popupParent: root
        rootStore: QtObject {}
        communityTokensStore: CommunityTokensStore {}
    }

    SyncingView {
        id: syncView
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        contentWidth: 664

        isProduction: ctrlIsProduction.checked

        advancedStore: QtObject {
            readonly property bool isDebugEnabled: ctrlDebugEnabled.checked
        }

        devicesStore: QtObject {
            function generateConnectionStringAndRunSetupSyncingPopup() {
                logs.logEvent("devicesStore::generateConnectionStringAndRunSetupSyncingPopup()")
            }

            function setInstallationName(installationId, name) {
                logs.logEvent("devicesStore::setInstallationName", ["installationId", "name"], arguments)
            }

            readonly property bool isDeviceSetup: ctrlDevicesLoaded.checked
            readonly property var devicesModule: QtObject {
                readonly property bool devicesLoading: ctrlDevicesLoading.checked
                readonly property bool devicesLoadingError: ctrlDevicesLoadingError.checked
            }
            readonly property var devicesModel: ListModel {
                ListElement {
                    name: "Device 1"
                    deviceType: "osx"
                    timestamp: 123456789123
                    isCurrentDevice: true
                    enabled: true
                    installationId: "a"
                }
                ListElement {
                    name: "Device 2"
                    deviceType: "windows"
                    timestamp: 123456789123
                    isCurrentDevice: false
                    enabled: false
                    installationId: "b"
                }
                ListElement {
                    name: "Device 3"
                    deviceType: "android"
                    timestamp: 3456541235346346322
                    isCurrentDevice: false
                    enabled: true
                    installationId: "c"
                }
                ListElement {
                    name: "Device 4"
                    deviceType: "ios"
                    timestamp: 385657923539634639
                    isCurrentDevice: false
                    enabled: true
                    installationId: "d"
                }
                ListElement {
                    name: "Device 5"
                    deviceType: "desktop"
                    timestamp: 0
                    isCurrentDevice: false
                    enabled: true
                    installationId: "e"
                }
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 270

        logsView.logText: logs.logText

        ColumnLayout {
            RadioButton {
                id: ctrlDevicesLoaded
                text: "Devices loaded"
                checked: true
            }
            RadioButton {
                id: ctrlDevicesLoading
                text: "Devices loading"
            }
            RadioButton {
                id: ctrlDevicesLoadingError
                text: "Devices loading error"
            }

            Switch {
                id: ctrlDebugEnabled
                text: "Debug enabled"
            }

            Switch {
                id: ctrlIsProduction
                text: "Is production"
                checked: true
            }
        }
    }
}

// category: Views

// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?type=design&node-id=1592-128606&mode=design&t=1xZLPCet6yRCZCuz-0
