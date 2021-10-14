import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import "../../../../shared"
import "../../../../shared/popups"
import "../../../../shared/status"

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
                switchChecked: !appSettings.quitOnClose
                onClicked: function (checked) {
                    appSettings.quitOnClose = !checked
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
                switchChecked: appSettings.isWalletEnabled
                onClicked: {
                    if (!appSettings.isWalletEnabled) {
                        confirmationPopup.settingsProp = "isWalletEnabled"
                        confirmationPopup.open()
                    } else {
                        appSettings.isWalletEnabled = false
                    }
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                text: qsTr("Wallet v2 - do not use, under active development")
                isSwitch: true
                switchChecked: appSettings.isWalletV2Enabled
                onClicked: {
                    if (!appSettings.isWalletV2Enabled) {
                        confirmationPopup.settingsProp = "isWalletV2Enabled"
                        confirmationPopup.open()
                    } else {
                        appSettings.isWalletV2Enabled = false
                    }
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                //% "Dapp Browser"
                text: qsTrId("dapp-browser")
                isSwitch: true
                switchChecked: appSettings.isBrowserEnabled
                onClicked: {
                    if (!appSettings.isBrowserEnabled) {
                        confirmationPopup.settingsProp = "isBrowserEnabled"
                        confirmationPopup.open()
                    } else {
                        appSettings.isBrowserEnabled = false
                    }
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                //% "Communities"
                text: qsTrId("communities")
                isSwitch: true
                switchChecked: appSettings.communitiesEnabled
                onClicked: {
                    if (!appSettings.communitiesEnabled) {
                        confirmationPopup.settingsProp = "communitiesEnabled"
                        confirmationPopup.open()
                    } else {
                        appSettings.communitiesEnabled = false
                    }
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                //% "Activity Center"
                text: qsTrId("activity-center")
                isSwitch: true
                switchChecked: appSettings.isActivityCenterEnabled
                onClicked: {
                    if (!appSettings.isActivityCenterEnabled) {
                        confirmationPopup.settingsProp = "isActivityCenterEnabled"
                        confirmationPopup.open()
                    } else {
                        appSettings.isActivityCenterEnabled = false
                    }
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                //% "Node Management"
                text: qsTrId("node-management")
                isSwitch: true
                switchChecked: appSettings.nodeManagementEnabled
                onClicked: {
                    if (!appSettings.nodeManagementEnabled) {
                        confirmationPopup.settingsProp = "nodeManagementEnabled"
                        confirmationPopup.open()
                    } else {
                        appSettings.nodeManagementEnabled = false
                    }
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                id: onlineUsers
                //% "Online users"
                text: qsTrId("online-users")
                isSwitch: true
                switchChecked: appSettings.showOnlineUsers
                onClicked: {
                    appSettings.showOnlineUsers = !appSettings.showOnlineUsers
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                //% "GIF Widget"
                text: qsTrId("gif-widget")
                isSwitch: true
                switchChecked: appSettings.isGifWidgetEnabled
                onClicked: {
                    appSettings.isGifWidgetEnabled = !appSettings.isGifWidgetEnabled
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                //% "Keycard"
                text: qsTr("Keycard")
                isSwitch: true
                switchChecked: appSettings.isKeycardEnabled
                onClicked: {
                    appSettings.isKeycardEnabled = !appSettings.isKeycardEnabled
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

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                text: qsTr("Download messages")
                isSwitch: true
                switchChecked: appSettings.downloadChannelMessagesEnabled
                onClicked: {
                    appSettings.downloadChannelMessagesEnabled = !appSettings.downloadChannelMessagesEnabled
                }
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                text: qsTr("Stickers/ENS on ropsten")
                visible: root.store.currentNetwork === Constants.networkRopsten
                isSwitch: true
                switchChecked: appSettings.stickersEnsRopsten
                onClicked: {
                    appSettings.stickersEnsRopsten = !appSettings.stickersEnsRopsten
                }
            }
        }

        NetworksModal {
            id: networksModal
        }

        FleetsModal {
            id: fleetModal
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
                appSettings[settingsProp] = true
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
