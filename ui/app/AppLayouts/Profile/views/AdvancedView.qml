import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQml.Models 2.14
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

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

// TODO: remove DEV import
import AppLayouts.Wallet.stores 1.0 as WalletStores
import AppLayouts.Wallet.views.walletconnect 1.0
// TODO end

SettingsContentBase {
    id: root

    property MessagingStore messagingStore
    property AdvancedStore advancedStore

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

            StatusBaseText {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
                text: qsTr("Application Logs")
                font.underline: mouseArea.containsMouse
                color: Style.current.blue
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
                height: Style.current.bigPadding
                width: parent.width
            }

            Separator {
                width: parent.width
            }

            StatusSectionHeadline {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
                text: qsTr("Experimental features")
                topPadding: Style.current.bigPadding
                bottomPadding: Style.current.padding
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Dapp Browser")
                isSwitch: true
                switchChecked: localAccountSensitiveSettings.isBrowserEnabled
                onClicked: {
                    if (!localAccountSensitiveSettings.isBrowserEnabled) {
                        confirmationPopup.experimentalFeature = root.advancedStore.experimentalFeatures.browser
                        confirmationPopup.open()
                    } else {
                        root.advancedStore.toggleExperimentalFeature(root.advancedStore.experimentalFeatures.browser)
                    }
                }
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
                text: qsTr("Debug Wallet Connect")
                visible: root.advancedStore.isDebugEnabled

                onClicked: {
                    Global.popupWalletConnect()
                }
            }

            Separator {
                width: parent.width
            }

            StatusSectionHeadline {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
                visible: root.advancedStore.isWakuV2
                text: qsTr("WakuV2 options")
                topPadding: Style.current.bigPadding
                bottomPadding: Style.current.padding
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("Enable creation of sharded communities")
                isSwitch: true
                visible: root.advancedStore.isWakuV2
                switchChecked: root.advancedStore.isWakuV2ShardedCommunitiesEnabled
                onClicked: root.advancedStore.toggleWakuV2ShardedCommunities()
            }

             StatusListItem {
                 anchors.left: parent.left
                 anchors.right: parent.right
                 title: qsTr("Waku Nodes")
                 visible: root.advancedStore.isWakuV2
                 components: [
                     StatusIcon {
                         icon: "next"
                         color: Theme.palette.baseColor1
                     }
                 ]
                 onClicked: Global.openPopup(wakuNodesModalComponent)
             }

            StatusSectionHeadline {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
                visible: !root.advancedStore.isWakuV2
                text: qsTr("Bloom filter level")
                topPadding: Style.current.bigPadding
                bottomPadding: Style.current.padding
            }

            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
                visible: !root.advancedStore.isWakuV2
                spacing: 11

                Component {
                    id: bloomConfirmationDialogComponent
                    ConfirmationDialog {
                        property string mode: "normal"

                        id: confirmDialog
                        headerSettings.title: qsTr("Warning!")
                        confirmationText: qsTr("The account will be logged out. When you login again, the selected mode will be enabled")
                        onConfirmButtonClicked: {
                            root.advancedStore.setBloomLevel(mode)
                        }
                        onClosed: {
                            switch(root.advancedStore.bloomLevel){
                                case "light":  btnBloomLight.toggle(); break;
                                case "normal":  btnBloomNormal.toggle(); break;
                                case "full":  btnBloomFull.toggle(); break;
                            }
                            destroy()
                        }
                    }
                }

                ButtonGroup {
                    id: bloomGroup
                }

                BloomSelectorButton {
                    id: btnBloomLight
                    buttonGroup: bloomGroup
                    checkedByDefault: root.advancedStore.bloomLevel == "light"
                    btnText: qsTr("Light Node")
                    onToggled: {
                        Global.openPopup(bloomConfirmationDialogComponent, {mode: "light"})
                    }
                }

                BloomSelectorButton {
                    id: btnBloomNormal
                    buttonGroup: bloomGroup
                    checkedByDefault: root.advancedStore.bloomLevel == "normal"
                    btnText: qsTr("Normal")
                    onToggled: {
                        Global.openPopup(bloomConfirmationDialogComponent, {mode: "normal"})
                    }
                }

                BloomSelectorButton {
                    id: btnBloomFull
                    buttonGroup: bloomGroup
                    checkedByDefault: root.advancedStore.bloomLevel == "full"
                    btnText: qsTr("Full Node")
                    onToggled: {
                        Global.openPopup(bloomConfirmationDialogComponent, {mode: "full"})
                    }
                }
            }

            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
                spacing: 11
                visible: root.advancedStore.isWakuV2

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
                    buttonGroup: wakuV2Group
                    checkedByDefault: root.advancedStore.wakuV2LightClientEnabled
                    btnText: qsTr("Light mode")
                    onToggled: {
                        Global.openPopup(wakuV2ModeConfirmationDialogComponent, { lightMode: true })
                    }
                }

                BloomSelectorButton {
                    id: btnWakuV2Full
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
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
                title: qsTr("History nodes")
                label: root.messagingStore.getMailserverNameForNodeAddress(root.messagingStore.activeMailserver)
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
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
                text: qsTr("Developer features")
                topPadding: Style.current.bigPadding
                bottomPadding: Style.current.padding
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
                switchChecked: root.advancedStore.isDebugEnabled
                onClicked: {
                    Global.openPopup(enableDebugComponent)
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
                text: qsTr("Enable Sepolia as Test Network")
                isSwitch: true
                switchChecked: root.advancedStore.isSepoliaEnabled
                onClicked: {
                    root.advancedStore.toggleIsSepoliaEnabled()
                }
            }

            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
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
                text: qsTr("How many log files to keep archived")
                currentValue: root.advancedStore.logMaxBackups
                onClicked: {
                    Global.openPopup(changeNumberOfLogsArchived)
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

                    StatusInput {
                        id: numberInput
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Style.current.padding
                        anchors.rightMargin: Style.current.padding
                        label: qsTr("Number of archives files")
                        input.text: root.advancedStore.logMaxBackups
                        placeholderText: qsTr("Number between 1 and 100")
                        validators: [
                            StatusFloatValidator {
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
    }
}
