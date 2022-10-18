import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Profile.views 1.0
import AppLayouts.Profile.stores 1.0

import Storybook 1.0

import utils 1.0

SplitView {
    Logs { id: logs }

    property var mockData: QtObject {
        property bool isCommunityHistoryArchiveSupportEnabled: true
        property string currentChainId: ""
        property string fleet: "eth.prod"
        property string bloomLevel: "full" // light //normal
        property bool wakuV2LightClientEnabled: false
        property bool isTelemetryEnabled: false
        property bool isAutoMessageEnabled: false
        property bool isDebugEnabled: false

        property var accountSettings: QtObject {
            property bool quitOnClose: true
            property bool isWalletEnabled: true
            property bool isBrowserEnabled: true
            property bool nodeManagementEnabled: true
            property bool isCommunityPermissionsEnabled: true
            property bool isDiscordImportToolEnabled: true
            property bool downloadChannelMessagesEnabled: true
        }
    }
    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        AdvancedView {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            contentWidth: parent.width

            accountSettings: mockData.accountSettings

            advancedStore: AdvancedStore {
                currentChainId: mockData.currentChainId
                fleet: mockData.fleet
                bloomLevel: mockData.bloomLevel
                wakuV2LightClientEnabled: mockData.wakuV2LightClientEnabled
                isTelemetryEnabled: mockData.isTelemetryEnabled
                isAutoMessageEnabled: mockData.isAutoMessageEnabled
                isDebugEnabled: mockData.isDebugEnabled
                isCommunityHistoryArchiveSupportEnabled: mockData.isCommunityHistoryArchiveSupportEnabled

                // customNetworksModel: advancedModule? advancedModule.customNetworksModel : []
                customNetworksModel: []

                isWakuV2: true

                function toggleExperimentalFeature(feature) {
                    logs.logEvent("advancedStore::toggleExperimentalFeature", ["feature"], arguments)
                    if (feature === "wallet") {
                        mockData.accountSettings.isWalletEnabled = !mockData.accountSettings.isWalletEnabled
                    }
                    if (feature === "browser") {
                        mockData.accountSettings.isBrowserEnabled = !mockData.accountSettings.isBrowserEnabled
                    }
                    if (feature === "communityHistoryArchiveSupport") {
                        mockData.isCommunityHistoryArchiveSupportEnabled = !mockData.isCommunityHistoryArchiveSupportEnabled
                    }
                    if (feature === "nodeManagement") {
                        mockData.accountSettings.nodeManagementEnabled = !mockData.accountSettings.nodeManagementEnabled
                    }
                    if (feature === "communityPermissions") {
                        mockData.accountSettings.isCommunityPermissionsEnabled = !mockData.accountSettings.isCommunityPermissionsEnabled
                    }
                    if (feature === "discordImportTool") {
                        mockData.accountSettings.isDiscordImportToolEnabled = !mockData.accountSettings.isDiscordImportToolEnabled
                    }
                }

                function setWakuV2LightClientEnabled(mode) {
                    logs.logEvent("advancedStore::setWakuV2LightClientEnabled", ["mode"], arguments)
                    mockData.wakuV2LightClientEnabled = mode
                }
                function setBloomLevel(mode) {
                    logs.logEvent("advancedStore::setBloomLevel", ["mode"], arguments)
                    mockData.bloomLevel = mode
                }
                function toggleDebug() {
                    logs.logEvent("advancedStore::toggleDebug")
                    mockData.isDebugEnabled = !mockData.isDebugEnabled
                }
                function toggleAutoMessage() {
                    logs.logEvent("advancedStore::toggleAutoMessage")
                    mockData.isAutoMessageEnabled = !mockData.isAutoMessageEnabled
                }
                function toggleTelemetry() {
                    logs.logEvent("advancedStore::toggleTelemetry")
                    mockData.isTelemetryEnabled = !mockData.isTelemetryEnabled
                }
            }

            onOpenApplicationLogs: {
                logs.logEvent("signals::openApplicationsLogs")
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

        font.pixelSize: 13

        ColumnLayout {
            Row {
                Label {
                    text: "Fleet"
                }
            }

            Row {
                TextField {
                    Layout.fillWidth: true
                    text: mockData.fleet
                    onTextChanged: mockData.fleet = text
                }
            }

            Row {
                spacing: 4
                CheckBox {
                    text: "Minimize on close"
                    checked: !mockData.accountSettings.quitOnClose
                    onToggled: mockData.accountSettings.quitOnClose = !mockData.accountSettings.quitOnClose
                }
            }

            Row {
                CheckBox {
                    text: "Wallet"
                    checked: mockData.accountSettings.isWalletEnabled
                    onToggled: mockData.accountSettings.isWalletEnabled = !mockData.accountSettings.isWalletEnabled
                }
            }

            Row {
                CheckBox {
                    text: "Browser"
                    checked: mockData.accountSettings.isBrowserEnabled
                    onToggled: mockData.accountSettings.isBrowserEnabled = !mockData.accountSettings.isBrowserEnabled
                }
            }
            Row {
                CheckBox {
                    text: "Community History Archive Protocol"
                    checked: mockData.isCommunityHistoryArchiveSupportEnabled
                    onToggled: mockData.isCommunityHistoryArchiveSupportEnabled = !mockData.isCommunityHistoryArchiveSupportEnabled
                }
            }
            Row {
                CheckBox {
                    text: "Node Management"
                    checked: mockData.accountSettings.nodeManagementEnabled
                    onToggled: mockData.accountSettings.nodeManagementEnabled = !mockData.accountSettings.nodeManagementEnabled
                }
            }

            Row {

                CheckBox {
                    text: "Community Permissions"
                    checked: mockData.accountSettings.isCommunityPermissionsEnabled
                    onToggled: mockData.accountSettings.isCommunityPermissionsEnabled = !mockData.accountSettings.isCommunityPermissionsEnabled
                }
            }

            Row {

                CheckBox {
                    text: "Discord Import"
                    checked: mockData.accountSettings.isDiscordImportToolEnabled
                    onToggled: mockData.accountSettings.isDiscordImportToolEnabled = !mockData.accountSettings.isDiscordImportToolEnabled
                }
            }

            Row {
                Label {
                    text: "Waku Mode"
                }

                Flow {
                    Layout.fillWidth: true

                    CheckBox {
                        text: "Light"
                        checked: mockData.bloomLevel == "light"
                        onToggled: mockData.bloomLevel = "light"
                    }

                    CheckBox {
                        text: "normal"
                        checked: mockData.bloomLevel == "normal"
                        onToggled: mockData.bloomLevel = "normal"
                    }

                    CheckBox {
                        text: "full"
                        checked: mockData.bloomLevel == "full"
                        onToggled: mockData.bloomLevel = "full"
                    }

                }
            }

            Row {
                CheckBox {
                    text: "Download Messages"
                    checked: mockData.accountSettings.downloadChannelMessagesEnabled
                    onToggled: mockData.accountSettings.downloadChannelMessagesEnabled = !mockData.accountSettings.downloadChannelMessagesEnabled
                }
            }

            Row {
                CheckBox {
                    text: "Telemetry"
                    checked: mockData.isTelemetryEnabled
                    onToggled: mockData.isTelemetryEnabled = !mockData.isTelemetryEnabled
                }
            }

            Row {
                CheckBox {
                    text: "Debug"
                    checked: mockData.isDebugEnabled
                    onToggled: mockData.isDebugEnabled = !mockData.isDebugEnabled
                }
            }

            Row {
                CheckBox {
                    text: "Auto Message"
                    checked: mockData.isAutoMessageEnabled
                    onToggled: mockData.isAutoMessageEnabled = !mockData.isAutoMessageEnabled
                }
            }





        }
    }
}


