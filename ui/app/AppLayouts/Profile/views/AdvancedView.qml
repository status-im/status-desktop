import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.controls 1.0

import StatusQ.Core 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import "../stores"
import "../controls"
import "../popups"
import "../panels"

SettingsContentBase {
    id: root

    property MessagingStore messagingStore
    property AdvancedStore advancedStore
    property WalletStore walletStore

    property bool isFleetSelectionEnabled

    Item {
        id: advancedContainer
        width: root.contentWidth
        height: generalColumn.height

        QtObject {
            id: d
            readonly property string experimentalFeatureMessage: qsTr("This feature is experimental and is meant for testing purposes by core contributors and the community. It's not meant for real use and makes no claims of security or integrity of funds or data. Use at your own risk.")
        }

        Column {
            id: generalColumn
            anchors.top: parent.top
            anchors.left: parent.left
            width: root.contentWidth

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Fleet")
                currentValue: root.advancedStore.fleet
                onClicked: fleetModal.open()
                visible: root.isFleetSelectionEnabled
            }

            StatusSettingsLineButton {
                id: labelScrolling
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Chat scrolling")
                currentValue: root.advancedStore.isCustomScrollingEnabled ? qsTr("Custom") : qsTr("System")
                onClicked: scrollingModal.open()
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Minimize on close")
                isSwitch: true
                switchChecked: !localAccountSensitiveSettings.quitOnClose
                onClicked: function (checked) {
                    localAccountSensitiveSettings.quitOnClose = !checked
                }
            }

            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Mainnet data verified by Nimbus")
                isSwitch: true
                switchChecked: root.advancedStore.isNimbusProxyEnabled
                onClicked: {
                    Global.openPopup(enableNimbusProxyComponent)
                }
            }

            StatusBaseText {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.padding
                anchors.rightMargin: Theme.padding
                text: qsTr("Application Logs")
                font.underline: mouseArea.containsMouse
                color: Theme.palette.primaryColor1
                topPadding: 23

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        Qt.openUrlExternally(root.advancedStore.logDir())
                    }
                }
            }

            Item {
                id: spacer1
                height: Theme.bigPadding
                width: parent.width
            }

            Separator {
                width: parent.width
            }

            StatusSectionHeadline {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.padding
                anchors.rightMargin: Theme.padding
                text: qsTr("Experimental features")
                topPadding: Theme.bigPadding
                bottomPadding: Theme.padding
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Node Management")
                isSwitch: true
                switchChecked: localAccountSensitiveSettings.nodeManagementEnabled
                onClicked: {
                    if (!localAccountSensitiveSettings.nodeManagementEnabled) {
                        confirmationPopup.experimentalFeature = root.advancedStore.experimentalFeatures.nodeManagement
                        confirmationPopup.open()
                    } else {
                        root.advancedStore.toggleExperimentalFeature(root.advancedStore.experimentalFeatures.nodeManagement)
                    }
                }
            }

            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                objectName: "enableCreateCommunityButton"
                text: qsTr("Enable Community Creation")
                isSwitch: true
                switchChecked: root.advancedStore.createCommunityEnabled
                onClicked: {
                    root.advancedStore.toggleCreateCommunityEnabled()
                }
            }

            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Archive Protocol Enabled")
                isSwitch: true
                switchChecked: root.advancedStore.archiveProtocolEnabled
                onClicked: {
                    root.advancedStore.toggleArchiveProtocolEnabled()
                }
            }

            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("ENS Community Permissions Enabled")
                isSwitch: true
                switchChecked: root.advancedStore.ensCommunityPermissionsEnabled
                onClicked: {
                    root.advancedStore.toggleEnsCommunityPermissionsEnabled()
                }
            }

            Separator {
                width: parent.width
            }

            StatusSectionHeadline {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.padding
                anchors.rightMargin: Theme.padding
                text: qsTr("WakuV2 options")
                topPadding: Theme.bigPadding
                bottomPadding: Theme.padding
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Enable creation of sharded communities")
                isSwitch: true
                switchChecked: root.advancedStore.isWakuV2ShardedCommunitiesEnabled
                onClicked: root.advancedStore.toggleWakuV2ShardedCommunities()
            }

             StatusListItem {
                 anchors.left: parent.left
                 anchors.right: parent.right
                 title: qsTr("Waku Nodes")
                 components: [
                     StatusIcon {
                         icon: "next"
                         color: Theme.palette.baseColor1
                     }
                 ]
                 onClicked: Global.openPopup(wakuNodesModalComponent)
             }

            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.padding
                anchors.rightMargin: Theme.padding
                spacing: 11

                Component {
                    id: wakuV2ModeConfirmationDialogComponent

                    ConfirmationDialog {
                        id: confirmDialog

                        property bool lightMode: false

                        confirmationText: (!lightMode ? "" : (d.experimentalFeatureMessage + "\n\n"))
                                          + qsTr("The account will be logged out. When you login again, the selected mode will be enabled")
                        confirmButtonLabel: lightMode ? qsTr("I understand") : qsTr("Confirm")
                        showCancelButton: lightMode
                        onConfirmButtonClicked: {
                            root.advancedStore.setWakuV2LightClientEnabled(lightMode)
                        }
                        onCancelButtonClicked: {
                            close()
                        }
                        onClosed: {
                            if (root.advancedStore.wakuV2LightClientEnabled){
                                btnWakuV2Light.toggle()
                            } else {
                                btnWakuV2Full.toggle()
                            }
                            destroy()
                        }
                    }
                }

                ButtonGroup {
                    id: wakuV2Group
                }

                BloomSelectorButton {
                    id: btnWakuV2Light
                    objectName: "lightWakuModeButton"
                    buttonGroup: wakuV2Group
                    checkedByDefault: root.advancedStore.wakuV2LightClientEnabled
                    btnText: qsTr("Light mode")
                    onToggled: {
                        Global.openPopup(wakuV2ModeConfirmationDialogComponent, { lightMode: true })
                    }
                }

                BloomSelectorButton {
                    id: btnWakuV2Full
                    objectName: "relayWakuModeButton"
                    buttonGroup: wakuV2Group
                    checkedByDefault: !root.advancedStore.wakuV2LightClientEnabled
                    btnText: qsTr("Relay mode")
                    onToggled: {
                        Global.openPopup(wakuV2ModeConfirmationDialogComponent, { lightMode: false })
                    }
                }
            }

            // SYNC WAKU SECTION

            StatusListItem {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.padding
                anchors.rightMargin: Theme.padding
                title: qsTr("History nodes")
                label: root.messagingStore.activeMailserverId || "---"
                components: [
                    StatusIcon {
                        icon: "next"
                        color: Theme.palette.baseColor1
                    }
                ]
                onClicked: Global.openPopup(wakuStoreModalComponent)
            }

            Component {
                id: wakuStoreModalComponent
                WakuStoreModal {
                    messagingStore: root.messagingStore
                    advancedStore: root.advancedStore
                }
            }

            StatusSectionHeadline {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.padding
                anchors.rightMargin: Theme.padding
                text: qsTr("Developer features")
                topPadding: Theme.bigPadding
                bottomPadding: Theme.padding
            }

            Separator {
                width: parent.width
            }

            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Full developer mode")
                isEnabled: {
                    return !localAccountSensitiveSettings.downloadChannelMessagesEnabled ||
                        !root.advancedStore.isTelemetryEnabled ||
                        !root.advancedStore.isDebugEnabled ||
                        !root.advancedStore.isAutoMessageEnabled
                }
                onClicked: {
                    Global.openPopup(enableDeveloperFeaturesConfirmationDialogComponent)
                }
            }

            Separator {
                width: parent.width
            }

            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Enable translations")
                isSwitch: true
                switchChecked: localAppSettings.translationsEnabled
                onClicked: {
                    localAppSettings.translationsEnabled = !localAppSettings.translationsEnabled
                    if (!checked)
                        Global.openPopup(disableLanguagesPopupComponent)
                }
            }

            Component {
                id: disableLanguagesPopupComponent
                ConfirmationDialog {
                    destroyOnClose: true
                    headerSettings.title: qsTr("Language reset")
                    confirmationText: qsTr("Display language will be switched back to English. You must restart the application for changes to take effect.")
                    confirmButtonLabel: qsTr("Restart")
                    onConfirmButtonClicked: SystemUtils.restartApplication()
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Download messages")
                isSwitch: true
                switchChecked: localAccountSensitiveSettings.downloadChannelMessagesEnabled
                onClicked: {
                    localAccountSensitiveSettings.downloadChannelMessagesEnabled = !localAccountSensitiveSettings.downloadChannelMessagesEnabled
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Telemetry")
                isSwitch: true
                switchChecked: root.advancedStore.isTelemetryEnabled
                onClicked: {
                    Global.openPopup(enableTelemetryConfirmationDialogComponent)
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Debug")
                isSwitch: true
                isEnabled: !root.advancedStore.isRuntimeLogLevelSet
                switchChecked: root.advancedStore.isDebugEnabled

                onClicked: {
                    Global.openPopup(enableDebugComponent)
                }

                MouseArea {
                    id: overlayMouseArea
                    anchors.fill: parent
                    enabled: true
                    hoverEnabled: true
                    propagateComposedEvents: true
                }

                StatusToolTip {
                    text: qsTr("The value is overridden with runtime options")
                    visible: overlayMouseArea.containsMouse && root.advancedStore.isRuntimeLogLevelSet
                    delay: 1000
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Auto message")
                isSwitch: true
                switchChecked: root.advancedStore.isAutoMessageEnabled
                onClicked: {
                    Global.openPopup(enableAutoMessageConfirmationDialogComponent)
                }
            }

            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Fake loading screen")
                isSwitch: true
                switchChecked: root.advancedStore.isFakeLoadingScreenEnabled
                onClicked: {
                    root.advancedStore.toggleFakeLoadingScreen()
                }
            }

            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                objectName: "manageCommunitiesOnTestnetButton"
                text: qsTr("Manage communities on testnet")
                isSwitch: true
                switchChecked: root.advancedStore.isManageCommunityOnTestModeEnabled
                onClicked: {
                    root.advancedStore.toggleManageCommunityOnTestnet()
                }
            }

            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Enable community tokens refreshing")
                isSwitch: true
                switchChecked: root.advancedStore.refreshTokenEnabled
                onClicked: {
                    root.advancedStore.toggleRefreshTokenEnabled()
                }
            }

            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("How many log files to keep archived")
                currentValue: root.advancedStore.logMaxBackups
                onClicked: {
                    Global.openPopup(changeNumberOfLogsArchived)
                }
            }

            StatusSettingsLineButton {
                id: rpcStatsButton
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("RPC statistics")
                onClicked: rpcStatsModal.open()
            }

            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Enable RLN Rate Limit")
                isSwitch: true
                switchChecked: root.advancedStore.isRateLimitEnabled
                onClicked: {
                    root.advancedStore.toggleRateLimit()
                }
            }
        }

        FleetsModal {
            id: fleetModal
            advancedStore: root.advancedStore
        }

        Component {
            id: wakuNodesModalComponent
            WakuNodesModal {
                messagingStore: root.messagingStore
                advancedStore: root.advancedStore
            }
        }

        Component {
            id: enableDeveloperFeaturesConfirmationDialogComponent
            ConfirmationDialog {
                property bool mode: false

                id: confirmDialog
                destroyOnClose: true
                showCancelButton: true
                confirmationText: qsTr("Are you sure you want to enable all the developer features? The app will be restarted.")
                onConfirmButtonClicked: {
                    localAccountSensitiveSettings.downloadChannelMessagesEnabled = true
                    Qt.callLater(root.advancedStore.enableDeveloperFeatures)
                    close()
                }
                onCancelButtonClicked: {
                    close()
                }
            }
        }

        Component {
            id: enableTelemetryConfirmationDialogComponent
            ConfirmationDialog {
                property bool mode: false

                id: confirmDialog
                destroyOnClose: true
                showCancelButton: true
                confirmationText: qsTr("Are you sure you want to enable telemetry? This will reduce your privacy level while using Status. You need to restart the app for this change to take effect.")
                onConfirmButtonClicked: {
                    root.advancedStore.toggleTelemetry()
                    close()
                }
                onCancelButtonClicked: {
                    close()
                }
            }
        }

        Component {
            id: enableAutoMessageConfirmationDialogComponent
            ConfirmationDialog {
                property bool mode: false

                id: confirmDialog
                destroyOnClose: true
                showCancelButton: true
                confirmationText: qsTr("Are you sure you want to enable auto message? You need to restart the app for this change to take effect.")
                onConfirmButtonClicked: {
                    root.advancedStore.toggleAutoMessage()
                    close()
                }
                onCancelButtonClicked: {
                    close()
                }
            }
        }

        Component {
            id: enableDebugComponent
            ConfirmationDialog {
                property bool mode: false

                id: confirmDialog
                destroyOnClose: true
                showCancelButton: true
                confirmationText: qsTr("Are you sure you want to %1 debug mode? You need to restart the app for this change to take effect.").arg(root.advancedStore.isDebugEnabled ?
                    qsTr("disable") :
                    qsTr("enable"))
                onConfirmButtonClicked: {
                    root.advancedStore.toggleDebug()
                    close()
                }
                onCancelButtonClicked: {
                    close()
                }
            }
        }

        Component {
            id: enableNimbusProxyComponent
            ConfirmationDialog {
                property bool mode: false

                id: confirmDialog
                destroyOnClose: true
                showCancelButton: true
                confirmationText: qsTr("Are you sure you want to %1 Nimbus proxy? You need to restart the app for this change to take effect.").arg(root.advancedStore.isNimbusProxyEnabled ?
                    qsTr("disable") :
                    qsTr("enable"))
                onConfirmButtonClicked: {
                    root.advancedStore.toggleNimbusProxy()
                    close()
                }
                onCancelButtonClicked: {
                    close()
                }
            }
        }

        Component {
            id: changeNumberOfLogsArchived

            StatusModal {
                id: logChangerModal

                onClosed: destroy()
                anchors.centerIn: parent
                width: 400
                headerSettings.title: qsTr("How many log files do you want to keep archived?")

                contentItem: Column {
                    width: parent.width
                    StatusBaseText {
                        width: parent.width
                        padding: 15
                        wrapMode: Text.WordWrap
                        text: qsTr("Choose a number between 1 and 100")
                    }

                    StatusAmountInput {
                        id: numberInput
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Theme.padding
                        anchors.rightMargin: Theme.padding
                        label: qsTr("Number of archives files")
                        input.text: root.advancedStore.logMaxBackups
                        placeholderText: qsTr("Number between 1 and 100")
                        validators: [
                            StatusIntValidator {
                                bottom: 1
                                top: 100
                                errorMessage: qsTr("Number needs to be between 1 and 100")
                                locale: LocaleUtils.userInputLocale
                            }
                        ]
                    }

                    StatusBaseText {
                        width: parent.width
                        padding: 15
                        wrapMode: Text.WordWrap
                        text: qsTr("This change will only come into action after a restart")
                    }
                }

                rightButtons: [
                    StatusButton {
                        text: qsTr("Cancel")
                        onClicked: logChangerModal.close()
                        normalColor: "transparent"
                        hoverColor: "transparent"
                    },
                    StatusButton {
                        id: banButton
                        text: qsTr("Change")
                        type: StatusBaseButton.Type.Normal
                        onClicked: {
                            root.advancedStore.setMaxLogBackups(numberInput.input.text)
                            logChangerModal.close()
                        }
                    }
                ]
            }
        }

        ConfirmationDialog {
            id: confirmationPopup
            property string experimentalFeature: ""
            showCancelButton: true
            confirmationText: d.experimentalFeatureMessage
            confirmButtonLabel: qsTr("I understand")
            confirmButtonObjectName: "leaveGroupConfirmationDialogLeaveButton"
            onConfirmButtonClicked: {
                root.advancedStore.toggleExperimentalFeature(experimentalFeature)
                experimentalFeature = ""
                close()
            }
            onCancelButtonClicked: {
                close()
            }
        }

        ScrollingModal {
            id: scrollingModal

            title: labelScrolling.text
            initialVelocity: root.advancedStore.scrollVelocity
            initialDeceleration: root.advancedStore.scrollDeceleration
            isCustomScrollingEnabled: root.advancedStore.isCustomScrollingEnabled
            onVelocityChanged: root.advancedStore.setScrollVelocity(value)
            onDecelerationChanged: root.advancedStore.setScrollDeceleration(value)
            onCustomScrollingChanged: root.advancedStore.setCustomScrollingEnabled(enabled)
        }

        RPCStatsModal {
            id: rpcStatsModal

            walletStore: root.walletStore
            title: rpcStatsButton.text
        }
    }
}
