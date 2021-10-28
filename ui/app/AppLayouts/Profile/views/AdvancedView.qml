import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0

import "../controls"
import "../popups"
import "../panels"

ScrollView {
    id: root
    height: parent.height
    width: parent.width
    contentHeight: advancedContainer.height + 100
    clip: true
    property bool isWakuV2: store.fleet == Constants.waku_prod || store.fleet === Constants.waku_test

    property var store

    Item {
        id: advancedContainer
        width: profileContainer.profileContentWidth
        anchors.horizontalCenter: parent.horizontalCenter
        height: generalColumn.height

        Column {
            id: generalColumn
            anchors.top: parent.top
            anchors.topMargin: 64
            anchors.left: parent.left
            anchors.right: parent.right

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding

                title: qsTr("Network")
                label: root.store.getNetworkName()
                onClicked: networksModal.open()
                components: [
                    StatusIcon {
                        icon: "chevron-down"
                        rotation: 270
                        color: Theme.palette.baseColor1
                    }
                ]
            }

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding

                title: qsTr("Fleet")
                label: root.store.fleet
                onClicked: fleetModal.open()
                components: [
                    StatusIcon {
                        icon: "chevron-down"
                        rotation: 270
                        color: Theme.palette.baseColor1
                    }
                ]
            }

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding

                title: qsTr("Minimize on close")

                onClicked: quitOnCloseSwitch.checked = !quitOnCloseSwitch.checked
                components: [
                    StatusSwitch {
                        id: quitOnCloseSwitch
                        checked: !localAccountSensitiveSettings.quitOnClose
                        onClicked: {
                            localAccountSensitiveSettings.quitOnClose = !checked
                        }
                    }
                ]
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

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding

                title: qsTr("Wallet")

                onClicked: walletEnabledSwitch.clicked()
                components: [
                    StatusSwitch {
                        id: walletEnabledSwitch
                        checked: localAccountSensitiveSettings.isWalletEnabled
                        onClicked: {
                            if (!localAccountSensitiveSettings.isWalletEnabled) {
                                confirmationPopup.settingsProp = "isWalletEnabled"
                                confirmationPopup.open()
                            } else {
                                localAccountSensitiveSettings.isWalletEnabled = false
                            }
                        }
                    }
                ]
            }

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding

                title: qsTr("Wallet v2 - do not use, under active development")

                onClicked: walletV2EnabledSwitch.clicked()
                components: [
                    StatusSwitch {
                        id: walletV2EnabledSwitch
                        checked: localAccountSensitiveSettings.isWalletV2Enabled
                        onClicked: {
                            if (!localAccountSensitiveSettings.isWalletV2Enabled) {
                                confirmationPopup.settingsProp = "isWalletV2Enabled"
                                confirmationPopup.open()
                            } else {
                                localAccountSensitiveSettings.isWalletV2Enabled = false
                            }
                        }
                    }
                ]
            }

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding

                title: qsTrId("DApp Browser")

                onClicked: browserEnabledSwitch.clicked()
                components: [
                    StatusSwitch {
                        id: browserEnabledSwitch
                        checked: localAccountSensitiveSettings.isBrowserEnabled
                        onClicked: {
                            if (!localAccountSensitiveSettings.isBrowserEnabled) {
                                confirmationPopup.settingsProp = "isBrowserEnabled"
                                confirmationPopup.open()
                            } else {
                                localAccountSensitiveSettings.isBrowserEnabled = false
                            }
                        }
                    }
                ]
            }

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding

                title: qsTrId("Communities")

                onClicked: communitiesEnabledSwitch.clicked()
                components: [
                    StatusSwitch {
                        id: communitiesEnabledSwitch
                        checked: localAccountSensitiveSettings.communitiesEnabled
                        onClicked: {
                            if (!localAccountSensitiveSettings.communitiesEnabled) {
                                confirmationPopup.settingsProp = "communitiesEnabled"
                                confirmationPopup.open()
                            } else {
                                localAccountSensitiveSettings.communitiesEnabled = false
                            }
                        }
                    }
                ]
            }

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding

                title: qsTrId("Activity Center")

                onClicked: activityCenterEnabledSwitch.clicked()
                components: [
                    StatusSwitch {
                        id: activityCenterEnabledSwitch
                        checked: localAccountSensitiveSettings.isActivityCenterEnabled
                        onClicked: {
                            if (!localAccountSensitiveSettings.isActivityCenterEnabled) {
                                confirmationPopup.settingsProp = "isActivityCenterEnabled"
                                confirmationPopup.open()
                            } else {
                                localAccountSensitiveSettings.isActivityCenterEnabled = false
                            }
                        }
                    }
                ]
            }

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding

                title: qsTrId("Node Management")

                onClicked: nodeManagementSwitch.clicked()
                components: [
                    StatusSwitch {
                        id: nodeManagementSwitch
                        checked: localAccountSensitiveSettings.nodeManagementEnabled
                        onClicked: {
                            if (!localAccountSensitiveSettings.nodeManagementEnabled) {
                                confirmationPopup.settingsProp = "nodeManagementEnabled"
                                confirmationPopup.open()
                            } else {
                                localAccountSensitiveSettings.nodeManagementEnabled = false
                            }
                        }
                    }
                ]
            }

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding

                title: qsTrId("Online users")

                onClicked: {
                    localAccountSensitiveSettings.showOnlineUsers = !localAccountSensitiveSettings.showOnlineUsers
                }
                components: [
                    StatusSwitch {
                        checked: localAccountSensitiveSettings.showOnlineUsers
                        onCheckedChanged: {
                            localAccountSensitiveSettings.showOnlineUsers = checked
                        }
                    }
                ]
            }

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding

                title: qsTrId("GIF Widget")

                onClicked: {
                    localAccountSensitiveSettings.isGifWidgetEnabled = !localAccountSensitiveSettings.isGifWidgetEnabled
                }
                components: [
                    StatusSwitch {
                        checked: localAccountSensitiveSettings.isGifWidgetEnabled
                        onCheckedChanged: {
                            localAccountSensitiveSettings.isGifWidgetEnabled = checked
                        }
                    }
                ]
            }

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding

                title: qsTrId("Keycard")

                onClicked: {
                    localAccountSettings.isKeycardEnabled = !localAccountSettings.isKeycardEnabled
                }
                components: [
                    StatusSwitch {
                        checked: localAccountSettings.isKeycardEnabled
                        onCheckedChanged: {
                            localAccountSettings.isKeycardEnabled = checked
                        }
                    }
                ]
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
                            switch(root.store.nodeModelInst.bloomLevel){
                                case "light":  btnBloomLight.click(); break;
                                case "normal":  btnBloomNormal.click(); break;
                                case "full":  btnBloomFull.click(); break;
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
                    checkedByDefault: root.store.bloomLevel == "light"
                    //% "Light Node"
                    btnText: qsTrId("light-node")
                    onToggled: {
                        if (root.store.bloomLevel != "light") {
                            openPopup(bloomConfirmationDialogComponent, {mode: "light"})
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
                            openPopup(bloomConfirmationDialogComponent, {mode: "normal"})
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
                            openPopup(bloomConfirmationDialogComponent, {mode: "full"})
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
                            openPopup(wakuV2ModeConfirmationDialogComponent, {light: true})
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
                            openPopup(wakuV2ModeConfirmationDialogComponent, {light: false})
                        } else {
                            btnWakuV2Full.click()
                        }
                    }
                }
            }

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding

                title: qsTrId("Download messages")

                onClicked: {
                    localAccountSensitiveSettings.downloadChannelMessagesEnabled = !localAccountSensitiveSettings.downloadChannelMessagesEnabled
                }
                components: [
                    StatusSwitch {
                        checked: localAccountSensitiveSettings.downloadChannelMessagesEnabled
                        onCheckedChanged: {
                            localAccountSensitiveSettings.downloadChannelMessagesEnabled = checked
                        }
                    }
                ]
            }

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding

                title: qsTrId("Stickers/ENS on ropsten")

                onClicked: {
                    localAccountSensitiveSettings.stickersEnsRopsten = !localAccountSensitiveSettings.stickersEnsRopsten
                }
                components: [
                    StatusSwitch {
                        checked: localAccountSensitiveSettings.stickersEnsRopsten
                        onCheckedChanged: {
                            localAccountSensitiveSettings.stickersEnsRopsten = checked
                        }
                    }
                ]
            }

            StatusListItem {
                height: 52
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: -Style.current.padding
                anchors.rightMargin: -Style.current.padding

                title: qsTrId("Enable Telemetry")

                onClicked: {
                    openPopup(enableTelemetryConfirmationDialogComponent, {light: false})
                }
                components: [
                    StatusSwitch {
                        id: telemetrySwitch
                        checked: root.store.profileModuleInst.isTelemetryEnabled
                    }
                ]
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

/*##^##
Designer {
    D{i:0;height:400;width:700}
}
##^##*/
