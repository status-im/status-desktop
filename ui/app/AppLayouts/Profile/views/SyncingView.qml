import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Popups
import StatusQ.Popups.Dialog
import StatusQ.Core.Utils as StatusQUtils
import StatusQ.Core.Backpressure

import utils

import shared.panels
import shared.popups
import shared.controls
import shared.controls.chat
import shared.status

import SortFilterProxyModel

import AppLayouts.Profile.stores as ProfileStores
import "../popups"
import "../controls"
import "../../stores"

SettingsContentBase {
    id: root

    property ProfileStores.DevicesStore devicesStore
    property ProfileStores.ProfileStore profileStore
    property ProfileStores.PrivacyStore privacyStore
    property ProfileStores.AdvancedStore advancedStore

    required property bool isProduction
    required property bool localBackupEnabled
    required property bool messagesBackupEnabled
    required property url backupPath

    signal backupPathSet(url path)
    signal backupMessagesEnabledToggled(bool enabled)

    ColumnLayout {
        id: layout
        width: root.contentWidth
        spacing: Theme.padding

        QtObject {
            id: d

            readonly property var instructionsModel: [
                qsTr("Verify your login with password or Keycard"),
                qsTr("Reveal a temporary QR and Sync Code") + "*",
                qsTr("Share that information with your new device"),
            ]

            property bool messageSyncingEnabled: false

            function personalizeDevice(model) {
                Global.openPopup(personalizeDevicePopup, {
                                     "deviceModel": model
                                 })
            }

            function setupPair(installationId) {
                Global.openPopup(pairDeviceDialogComponent, {
                                     "installationId": installationId
                                 })
            }

            function setupUnpair(installationId) {
                Global.openPopup(unpairDeviceDialogComponent, {
                                     "installationId": installationId
                                 })
            }

            function setupSyncing() {
                root.devicesStore.generateConnectionStringAndRunSetupSyncingPopup(messageSyncingEnabled)
            }
        }


        Connections {
            target: devicesStore.devicesModule

            function onOpenPopupWithConnectionStringSignal(rawConnectionString) {
                Global.openPopup(setupSyncingPopup, {
                                     rawConnectionString: rawConnectionString,
                                 })
            }
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.leftMargin: Theme.padding
            Layout.rightMargin: Theme.padding
            text: qsTr("Devices")
            font.pixelSize: Constants.settingsSection.subHeaderFontSize
            color: Theme.palette.baseColor1
        }

        StatusBaseText {
            Layout.fillWidth: true
            visible: root.devicesStore.devicesModule.devicesLoading
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Loading devices...")
        }

        StatusBaseText {
            Layout.fillWidth: true
            visible: root.devicesStore.devicesModule.devicesLoadingError
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Error loading devices. Please try again later.")
            color: Theme.palette.dangerColor1
        }

        StatusListView {
            Layout.fillWidth: true
            implicitHeight: contentHeight

            interactive: false
            spacing: 0
            visible: !root.devicesStore.devicesModule.devicesLoading &&
                     !root.devicesStore.devicesModule.devicesLoadingError &&
                     root.devicesStore.isDeviceSetup

            model: SortFilterProxyModel {
                sourceModel: root.devicesStore.devicesModel
                sorters: [
                    RoleSorter {
                        roleName: "isCurrentDevice"
                        sortOrder: Qt.DescendingOrder
                        priority: 2
                    },
                    RoleSorter {
                        roleName: "enabled"
                        sortOrder: Qt.DescendingOrder
                        priority: 1 // Higher number === higher priority
                    }
                ]
            }

            delegate: StatusSyncDeviceDelegate {
                width: ListView.view.width
                deviceName: model.name
                deviceType: model.deviceType
                deviceEnabled: model.enabled
                timestamp: model.timestamp
                isCurrentDevice: model.isCurrentDevice
                onPairRequested: {
                    d.setupPair(model.installationId)
                }
                onUnpairRequested: {
                    d.setupUnpair(model.installationId)
                }
                onClicked: {
                    if (deviceEnabled) {
                        d.personalizeDevice(model)
                    }
                }
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Theme.padding

            implicitWidth: instructionsLayout.implicitWidth
                           + instructionsLayout.anchors.leftMargin
                           + instructionsLayout.anchors.rightMargin

            implicitHeight: instructionsLayout.implicitHeight
                            + instructionsLayout.anchors.topMargin
                            + instructionsLayout.anchors.bottomMargin

            color: Theme.palette.primaryColor3
            radius: Theme.radius

            ColumnLayout {
                id: instructionsLayout

                anchors {
                    fill: parent
                    topMargin: Theme.bigPadding
                    bottomMargin: Theme.bigPadding
                    leftMargin: Theme.padding
                    rightMargin: Theme.padding
                }

                spacing: Theme.padding

                Item {
                    Layout.alignment: Qt.AlignHCenter
                    height: syncNewDeviceText.height
                    width: syncNewDeviceText.width

                    StatusBaseText {
                        id: syncNewDeviceText
                        objectName: "syncNewDeviceTextLabel"

                        color: Theme.palette.primaryColor1
                        font.pixelSize: Theme.secondaryAdditionalTextSize
                        font.weight: Font.Bold
                        text: qsTr("Sync a New Device")

                        StatusBetaTag {
                            anchors.left: parent.right
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            tooltipText: qsTr("Connection problems can happen.<br>If they do, please use the Enter a Recovery Phrase feature instead.")
                        }
                    }
                }

                StatusBaseText {
                    objectName: "syncNewDeviceSubTitleTextLabel"

                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.palette.baseColor1
                    font.weight: Font.Medium
                    text: qsTr("You own your data. Sync it among your devices.")
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 6
                    Repeater {
                        model: d.instructionsModel
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            StatusBaseText {
                                color: Theme.palette.baseColor1
                                font.pixelSize: Theme.additionalTextSize
                                font.weight: Font.Medium
                                text: index + 1
                            }
                            StatusBaseText {
                                text: modelData
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Theme.halfPadding

                        StatusCheckBox {
                            objectName: "enableMessageSyncingCheckBox"

                            text: qsTr("Enable message syncing")
                            leftSide: true
                            checked: false
                            onToggled: d.messageSyncingEnabled = checked
                        }

                        StatusFlatRoundButton {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: width
                            radius: width/2
                            icon.name: "help"
                            tooltip.text: qsTr("Sends your 1-on-1, group, and community messages to your paired device via encrypted local pairing.")
                        }
                    }
                }

                StatusButton {
                    objectName: "setupSyncingStatusButton"

                    Layout.alignment: Qt.AlignHCenter
                    type: StatusBaseButton.Type.Primary
                    text: qsTr("Setup Syncing")
                    onClicked: {
                        d.setupSyncing()
                    }
                }

                StatusBaseText {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    color: Theme.palette.baseColor1
                    font.pixelSize: Theme.additionalTextSize
                    text: "* " + qsTr("This is best done in private. The code will grant access to your profile.")
                }
            }
        }

        StatusFlatButton {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("How to get a sync code")
            icon.name: "info"
            onClicked: Global.openPopup(getSyncCodeInstructionsPopup)
        }

        StatusSettingsLineButton {
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            visible: root.localBackupEnabled
            text: qsTr("Directory of the local backup files")
            currentValue: root.backupPath
            onClicked: backupPathDialog.open()
        }

        StatusSettingsLineButton {
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            visible: root.localBackupEnabled
            text: qsTr("Backup messages locally")
            isSwitch: true
            switchChecked: root.messagesBackupEnabled
            onClicked: {
                if (root.messagesBackupEnabled) {
                    root.backupMessagesEnabledToggled(false)
                    return
                }
                Global.openPopup(enableMessagesBackupDialog)
            }
        }

        StatusButton {
            objectName: "setupSyncLocalBackupDataButton"

            visible: root.localBackupEnabled
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Backup Data Locally")
            asset.emoji: {
                if (root.devicesStore.backupDataState !== Constants.BackupImportState.Completed) {
                    return ""
                }
                if (root.devicesStore.backupDataError) {
                    return "❌"
                }
                return "✅"
            }
            loading: root.devicesStore.backupDataState === Constants.BackupImportState.InProgress
            onClicked : {
                root.devicesStore.performLocalBackup()
                Backpressure.debounce(this, 5000, () => {
                    root.devicesStore.resetBackupDataState()
                })()
            }
        }

        StatusButton {
            objectName: "importLocalBackupFileButton"

            id: importBackupBtn
            visible: root.localBackupEnabled
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Import Local Backup File")
            loading: root.devicesStore.backupImportState === Constants.BackupImportState.InProgress
            onClicked : importBackupFileDialog.open()
        }

        StatusBaseText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            color: Theme.palette.successColor1
            visible: root.devicesStore.backupImportState === Constants.BackupImportState.Completed && !root.devicesStore.backupImportError
            text: qsTr("Success importing local data")
        }

        StatusBaseText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            color: Theme.palette.dangerColor1
            visible: !!root.devicesStore.backupImportError
            wrapMode: Text.WordWrap
            text: qsTr("Error importing backup file: %1").arg(root.devicesStore.backupImportError)
        }

        Component {
            id: personalizeDevicePopup

            SyncDeviceCustomizationPopup {
                destroyOnClose: true
                devicesStore: root.devicesStore
                advancedStore: root.advancedStore
            }
        }

        Component {
            id: setupSyncingPopup

            SetupSyncingPopup {
                destroyOnClose: true
                devicesStore: root.devicesStore
                profileStore: root.profileStore
            }
        }

        Component {
            id: pairDeviceDialogComponent
            ConfirmationDialog {
                property string installationId

                id: pairDeviceDialog
                destroyOnClose: true
                headerSettings.title: qsTr("Pair Device")
                confirmationText: qsTr("Are you sure you want to pair this device?")
                confirmButtonLabel: qsTr("Pair")
                btnType: "normal"
                onConfirmButtonClicked: {
                    const error = devicesStore.devicesModule.pairDevice(installationId)
                    if (error) {
                        pairDeviceDialog.confirmationText = qsTr("Error pairing device: %1").arg(error)
                    } else {
                        Global.closePopup()
                    }
                }
            }
        }

        Component {
            id: unpairDeviceDialogComponent
            ConfirmationDialog {
                property string installationId

                id: unpairDeviceDialog
                destroyOnClose: true
                headerSettings.title: qsTr("Unpair Device")
                confirmationText: qsTr("Are you sure you want to unpair this device?")
                confirmButtonLabel: qsTr("Unpair")
                onConfirmButtonClicked: {
                    const error = devicesStore.devicesModule.unpairDevice(installationId)
                    if (error) {
                        unpairDeviceDialog.confirmationText = qsTr("Error unpairing device: %1").arg(error)
                    } else {
                        Global.closePopup()
                    }
                }
            }
        }

        Component {
            id: getSyncCodeInstructionsPopup
            GetSyncCodeInstructionsPopup {
                destroyOnClose: true
            }
        }

        Component {
            id: enableMessagesBackupDialog
            EnableMessagesBackupDialog {
                destroyOnClose: true
                onEnableRequested: {
                    root.backupMessagesEnabledToggled(true)
                    Global.closePopup()
                }
            }
        }

        StatusFileDialog {
            id: importBackupFileDialog

            title: qsTr("Select your backup file")
            nameFilters: [qsTr("Supported backup formats (%1)").arg("*.bkp")]
            currentFolder: root.devicesStore.toFileUri(root.backupPath)
            selectMultiple: false
            onAccepted: root.devicesStore.importLocalBackupFile(importBackupFileDialog.selectedFile)
        }

        StatusFolderDialog {
            id: backupPathDialog

            title: qsTr("Select your backup directory")
            currentFolder: root.devicesStore.toFileUri(root.backupPath)
            onAccepted: root.backupPathSet(backupPathDialog.selectedFolder)
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
}
