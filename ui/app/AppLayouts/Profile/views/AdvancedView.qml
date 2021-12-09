import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0

import "../controls"
import "../popups"
import "../panels"

ScrollView {
    id: root

    property bool isWakuV2: store.fleet == Constants.waku_prod || store.fleet === Constants.waku_test
    property var store
    property int profileContentWidth

    height: parent.height
    width: parent.width
    contentHeight: advancedContainer.height + 100
    clip: true

    Item {
        id: advancedContainer
        width: profileContentWidth
        anchors.horizontalCenter: parent.horizontalCenter
        height: generalColumn.height

        Column {
            id: generalColumn
            anchors.top: parent.top
            anchors.topMargin: 64
            anchors.left: parent.left
            anchors.right: parent.right

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                //% "Network"
                text: qsTrId("network")
                currentValue: root.store.getNetworkName()
                onClicked: networksModal.open()
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                //% "Fleet"
                text: qsTrId("fleet")
                currentValue: root.store.fleet
                onClicked: fleetModal.open()
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                //% "Minimize on close"
                text: qsTrId("minimize-on-close")
                isSwitch: true
                switchChecked: !localAccountSensitiveSettings.quitOnClose
                onClicked: function (checked) {
                    localAccountSensitiveSettings.quitOnClose = !checked
                }
            }

            // TODO: replace with StatusQ component
            StyledText {
                //% "Application Logs"
                text: qsTr("Application Logs")
                font.pixelSize: 15
                font.underline: mouseArea.containsMouse
                color: Style.current.blue
                topPadding: 23

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        Qt.openUrlExternally(root.store.logDir())
                    }
                }
            }

            Item {
                id: spacer1
                height: Style.current.bigPadding
                width: parent.width
            }

            Separator {
                anchors.topMargin: Style.current.bigPadding
                anchors.left: parent.left
                anchors.leftMargin: -Style.current.padding
                anchors.right: parent.right
                anchors.rightMargin: -Style.current.padding
            }

            StatusSectionHeadline {
                //% "Experimental features"
                text: qsTrId("experimental-features")
                topPadding: Style.current.bigPadding
                bottomPadding: Style.current.padding
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                //% "Wallet"
                text: qsTrId("wallet")
                isSwitch: true
                switchChecked: localAccountSensitiveSettings.isWalletEnabled
                onClicked: {
                    if (!localAccountSensitiveSettings.isWalletEnabled) {
                        confirmationPopup.settingsProp = "isWalletEnabled"
                        confirmationPopup.open()
                    } else {
                        localAccountSensitiveSettings.isWalletEnabled = false
                    }
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                text: qsTr("Wallet v2 - do not use, under active development")
                isSwitch: true
                switchChecked: localAccountSensitiveSettings.isWalletV2Enabled
                onClicked: {
                    if (!localAccountSensitiveSettings.isWalletV2Enabled) {
                        confirmationPopup.settingsProp = "isWalletV2Enabled"
                        confirmationPopup.open()
                    } else {
                        localAccountSensitiveSettings.isWalletV2Enabled = false
                    }
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                //% "Dapp Browser"
                text: qsTrId("dapp-browser")
                isSwitch: true
                switchChecked: localAccountSensitiveSettings.isBrowserEnabled
                onClicked: {
                    if (!localAccountSensitiveSettings.isBrowserEnabled) {
                        confirmationPopup.settingsProp = "isBrowserEnabled"
                        confirmationPopup.open()
                    } else {
                        localAccountSensitiveSettings.isBrowserEnabled = false
                    }
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                //% "Communities"
                text: qsTrId("communities")
                isSwitch: true
                switchChecked: localAccountSensitiveSettings.communitiesEnabled
                onClicked: {
                    if (!localAccountSensitiveSettings.communitiesEnabled) {
                        confirmationPopup.settingsProp = "communitiesEnabled"
                        confirmationPopup.open()
                    } else {
                        localAccountSensitiveSettings.communitiesEnabled = false
                    }
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                //% "Activity Center"
                text: qsTrId("activity-center")
                isSwitch: true
                switchChecked: localAccountSensitiveSettings.isActivityCenterEnabled
                onClicked: {
                    if (!localAccountSensitiveSettings.isActivityCenterEnabled) {
                        confirmationPopup.settingsProp = "isActivityCenterEnabled"
                        confirmationPopup.open()
                    } else {
                        localAccountSensitiveSettings.isActivityCenterEnabled = false
                    }
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                //% "Node Management"
                text: qsTrId("node-management")
                isSwitch: true
                switchChecked: localAccountSensitiveSettings.nodeManagementEnabled
                onClicked: {
                    if (!localAccountSensitiveSettings.nodeManagementEnabled) {
                        confirmationPopup.settingsProp = "nodeManagementEnabled"
                        confirmationPopup.open()
                    } else {
                        localAccountSensitiveSettings.nodeManagementEnabled = false
                    }
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                id: onlineUsers
                //% "Online users"
                text: qsTrId("online-users")
                isSwitch: true
                switchChecked: localAccountSensitiveSettings.showOnlineUsers
                onClicked: {
                    localAccountSensitiveSettings.showOnlineUsers = !localAccountSensitiveSettings.showOnlineUsers
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                //% "GIF Widget"
                text: qsTrId("gif-widget")
                isSwitch: true
                switchChecked: localAccountSensitiveSettings.isGifWidgetEnabled
                onClicked: {
                    localAccountSensitiveSettings.isGifWidgetEnabled = !localAccountSensitiveSettings.isGifWidgetEnabled
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                //% "Keycard"
                text: qsTr("Keycard")
                isSwitch: true
                switchChecked: localAccountSettings.isKeycardEnabled
                onClicked: {
                    localAccountSettings.isKeycardEnabled = !localAccountSettings.isKeycardEnabled
                }
            }

            StatusSectionHeadline {
                visible: !isWakuV2
                //% "Bloom filter level"
                text: qsTrId("bloom-filter-level")
                topPadding: Style.current.bigPadding
                bottomPadding: Style.current.padding
            }

            Row {
                visible: !isWakuV2
                spacing: 11

                Component {
                    id: bloomConfirmationDialogComponent
                    ConfirmationDialog {
                        property string mode: "normal"

                        id: confirmDialog
                        //% "Warning!"
                        header.title: qsTrId("close-app-title")
                        //% "The account will be logged out. When you login again, the selected mode will be enabled"
                        confirmationText: qsTrId("the-account-will-be-logged-out--when-you-login-again--the-selected-mode-will-be-enabled")
                        onConfirmButtonClicked: {
                            root.store.setBloomLevel(mode)
                        }
                        onClosed: {
                            // Not Refactored Yet
//                            switch(root.store.nodeModelInst.bloomLevel){
//                                case "light":  btnBloomLight.click(); break;
//                                case "normal":  btnBloomNormal.click(); break;
//                                case "full":  btnBloomFull.click(); break;
//                            }
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
                    checkedByDefault: root.store.bloomLevel == "light"
                    //% "Light Node"
                    btnText: qsTrId("light-node")
                    onToggled: {
                        if (root.store.bloomLevel != "light") {
                            Global.openPopup(bloomConfirmationDialogComponent, {mode: "light"})
                        } else {
                            btnBloomLight.click()
                        }
                    }
                }

                BloomSelectorButton {
                    id: btnBloomNormal
                    buttonGroup: bloomGroup
                    checkedByDefault: root.store.bloomLevel == "normal"
                    //% "Normal"
                    btnText: qsTrId("normal")
                    onToggled: {
                        if (root.store.bloomLevel != "normal") {
                            Global.openPopup(bloomConfirmationDialogComponent, {mode: "normal"})
                        } else {
                            btnBloomNormal.click()
                        }
                    }
                }

                BloomSelectorButton {
                    id: btnBloomFull
                    buttonGroup: bloomGroup
                    checkedByDefault: root.store.bloomLevel == "full"
                    //% "Full Node"
                    btnText: qsTrId("full-node")
                    onToggled: {
                        if (root.store.bloomLevel != "full") {
                            Global.openPopup(bloomConfirmationDialogComponent, {mode: "full"})
                        } else {
                            btnBloomFull.click()
                        }
                    }
                }
            }

            StatusSectionHeadline {
                visible: isWakuV2
                text: qsTr("WakuV2 mode")
                topPadding: Style.current.bigPadding
                bottomPadding: Style.current.padding
            }

            Row {
                spacing: 11
                visible: isWakuV2
                Component {
                    id: wakuV2ModeConfirmationDialogComponent
                    ConfirmationDialog {
                        property bool mode: false

                        id: confirmDialog
                        //% "The account will be logged out. When you login again, the selected mode will be enabled"
                        confirmationText: qsTrId("the-account-will-be-logged-out--when-you-login-again--the-selected-mode-will-be-enabled")
                        onConfirmButtonClicked: {
                            root.store.setWakuV2LightClient(mode)
                        }
                        onClosed: {
                            if(root.store.isWakuV2LightClient){
                                btnWakuV2Light.click()
                            } else {
                                btnWakuV2Full.click();
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
                    checkedByDefault: root.store.isWakuV2LightClient
                    //% "Light Node"
                    btnText: qsTrId("light-node")
                    onToggled: {
                        if (!root.store.isWakuV2LightClient) {
                            Global.openPopup(wakuV2ModeConfirmationDialogComponent, {mode: true})
                        } else {
                            btnWakuV2Light.click()
                        }
                    }
                }

                BloomSelectorButton {
                    id: btnWakuV2Full
                    buttonGroup: wakuV2Group
                    checkedByDefault: !root.store.isWakuV2LightClient
                    //% "Full Node"
                    btnText: qsTrId("full-node")
                    onToggled: {
                        if (root.store.isWakuV2LightClient) {
                            Global.openPopup(wakuV2ModeConfirmationDialogComponent, {mode: false})
                        } else {
                            btnWakuV2Full.click()
                        }
                    }
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                text: qsTr("Download messages")
                isSwitch: true
                switchChecked: localAccountSensitiveSettings.downloadChannelMessagesEnabled
                onClicked: {
                    localAccountSensitiveSettings.downloadChannelMessagesEnabled = !localAccountSensitiveSettings.downloadChannelMessagesEnabled
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                text: qsTr("Stickers/ENS on ropsten")
                visible: root.store.currentNetwork === Constants.networkRopsten
                isSwitch: true
                switchChecked: localAccountSensitiveSettings.stickersEnsRopsten
                onClicked: {
                    localAccountSensitiveSettings.stickersEnsRopsten = !localAccountSensitiveSettings.stickersEnsRopsten
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                text: qsTr("Enable Telemetry")
                isSwitch: true
                switchChecked: root.store.profileModuleInst.isTelemetryEnabled
                onClicked: {
                    Global.openPopup(enableTelemetryConfirmationDialogComponent, {light: false})
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                text: qsTr("Debug")
                isSwitch: true
                switchChecked: root.store.profileModuleInst.isDebugEnabled
                onClicked: {
                    Global.openPopup(enableDebugComponent)
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                text: qsTr("Enable Auto message")
                isSwitch: true
                switchChecked: root.store.profileModuleInst.isAutoMessageEnabled
                onClicked: {
                    Global.openPopup(enableAutoMessageConfirmationDialogComponent, {light: false})
                }
            }
        }

        NetworksModal {
            id: networksModal
        }

        FleetsModal {
            id: fleetModal
        }

        Component {
            id: enableTelemetryConfirmationDialogComponent
            ConfirmationDialog {
                property bool mode: false

                id: confirmDialog
                showCancelButton: true
                confirmationText: qsTr("Are you sure you want to enable telemetry? This will reduce your privacy level while using Status. You need to restart the app for this change to take effect.")
                onConfirmButtonClicked: {
                    root.store.profileModuleInst.toggleTelemetry()
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
                showCancelButton: true
                confirmationText: qsTr("Are you sure you want to enable auto message? You need to restart the app for this change to take effect.")
                onConfirmButtonClicked: {
                    root.store.profileModuleInst.toggleAutoMessage()
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
                showCancelButton: true
                confirmationText: qsTr("Are you sure you want to %1 debug mode? The app will be restarted for this change to take effect.").arg(root.store.profileModuleInst.isDebugEnabled ? 
                    qsTr("disable") : 
                    qsTr("enable"))
                onConfirmButtonClicked: {
                    root.store.profileModuleInst.toggleDebug()
                    close()
                }
                onCancelButtonClicked: {
                    close()
                }
            }
        }

        ConfirmationDialog {
            id: confirmationPopup
            property string settingsProp: ""
            showCancelButton: true
            //% "This feature is experimental and is meant for testing purposes by core contributors and the community. It's not meant for real use and makes no claims of security or integrity of funds or data. Use at your own risk."
            confirmationText: (settingsProp === "isWalletV2Enabled" ? qsTr("<b>--DO NOT USE - UNDER ACTIVE DEVELOPMENT--</b>\n") : "") +
                qsTrId("this-feature-is-experimental-and-is-meant-for-testing-purposes-by-core-contributors-and-the-community--it-s-not-meant-for-real-use-and-makes-no-claims-of-security-or-integrity-of-funds-or-data--use-at-your-own-risk-")
            //% "I understand"
            confirmButtonLabel: qsTrId("i-understand")
            onConfirmButtonClicked: {
                localAccountSensitiveSettings[settingsProp] = true
                settingsProp = ""
                close()
            }

            onCancelButtonClicked: {
                close()
            }
        }
    }
}
