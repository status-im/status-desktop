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

    Item {
        id: advancedContainer
        width: root.contentWidth
        height: generalColumn.height

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

            Separator {
                width: parent.width
            }

            StatusSectionHeadline {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
                visible: root.advancedStore.isWakuV2 && root.advancedStore.fleet != Constants.status_prod
                text: qsTr("WakuV2 options")
                topPadding: Style.current.bigPadding
                bottomPadding: Style.current.padding
            }

            // TODO: replace with StatusQ component
            StatusSettingsLineButton {
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                text: qsTr("WakuV2 Store")
                isSwitch: true
                visible: root.advancedStore.isWakuV2
                switchChecked: root.advancedStore.isWakuV2StoreEnabled
                onClicked: {
                    Global.openPopup(enableWakuV2StoreComponent)
                }
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
                    checkedByDefault: root.advancedStore.bloomLevel == "light"
                    btnText: qsTr("Light Node")
                    onToggled: {
                        if (root.advancedStore.bloomLevel != "light") {
                            Global.openPopup(bloomConfirmationDialogComponent, {mode: "light"})
                        } else {
                            btnBloomLight.click()
                        }
                    }
                }

                BloomSelectorButton {
                    id: btnBloomNormal
                    buttonGroup: bloomGroup
                    checkedByDefault: root.advancedStore.bloomLevel == "normal"
                    btnText: qsTr("Normal")
                    onToggled: {
                        if (root.advancedStore.bloomLevel != "normal") {
                            Global.openPopup(bloomConfirmationDialogComponent, {mode: "normal"})
                        } else {
                            btnBloomNormal.click()
                        }
                    }
                }

                BloomSelectorButton {
                    id: btnBloomFull
                    buttonGroup: bloomGroup
                    checkedByDefault: root.advancedStore.bloomLevel == "full"
                    btnText: qsTr("Full Node")
                    onToggled: {
                        if (root.advancedStore.bloomLevel != "full") {
                            Global.openPopup(bloomConfirmationDialogComponent, {mode: "full"})
                        } else {
                            btnBloomFull.click()
                        }
                    }
                }
            }

            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding
                spacing: 11
                visible: root.advancedStore.isWakuV2 && root.advancedStore.fleet != Constants.status_prod
                Component {
                    id: wakuV2ModeConfirmationDialogComponent
                    ConfirmationDialog {
                        property bool mode: false

                        id: confirmDialog
                        confirmationText: qsTr("The account will be logged out. When you login again, the selected mode will be enabled")
                        onConfirmButtonClicked: {
                            root.advancedStore.setWakuV2LightClientEnabled(mode)
                        }
                        onClosed: {
                            if(root.advancedStore.wakuV2LightClientEnabled){
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
                    checkedByDefault: root.advancedStore.wakuV2LightClientEnabled
                    btnText: qsTr("Light Node")
                    onToggled: {
                        if (!root.advancedStore.wakuV2LightClientEnabled) {
                            Global.openPopup(wakuV2ModeConfirmationDialogComponent, {mode: true})
                        } else {
                            btnWakuV2Light.click()
                        }
                    }
                }

                BloomSelectorButton {
                    id: btnWakuV2Full
                    buttonGroup: wakuV2Group
                    checkedByDefault: !root.advancedStore.wakuV2LightClientEnabled
                    btnText: qsTr("Full Node")
                    onToggled: {
                        if (root.advancedStore.wakuV2LightClientEnabled) {
                            Global.openPopup(wakuV2ModeConfirmationDialogComponent, {mode: false})
                        } else {
                            btnWakuV2Full.click()
                        }
                    }
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
                showCancelButton: true
                confirmationText: qsTr("Are you sure you want to enable all the develoer features? The app will be restarted.")
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
            id: enableWakuV2StoreComponent
            ConfirmationDialog {
                property bool mode: false

                id: confirmDialog
                showCancelButton: true
                confirmationText: qsTr("Are you sure you want to %1 WakuV2 Store? You need to restart the app for this change to take effect.")
                    .arg(root.advancedStore.isWakuV2StoreEnabled ?
                        qsTr("disable") :
                        qsTr("enable"))
                onConfirmButtonClicked: {
                    root.advancedStore.toggleExperimentalFeature(root.advancedStore.experimentalFeatures.wakuV2StoreEnabled)
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
                        font.pixelSize: 15
                        color: Theme.palette.directColor1
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
                        font.pixelSize: 15
                        color: Theme.palette.directColor1
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
            confirmationText: qsTr("This feature is experimental and is meant for testing purposes by core contributors and the community. It's not meant for real use and makes no claims of security or integrity of funds or data. Use at your own risk.")
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
    }
}
