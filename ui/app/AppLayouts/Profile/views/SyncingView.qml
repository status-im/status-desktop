import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import utils 1.0

import shared.panels 1.0
import shared.popups 1.0
import shared.controls 1.0
import shared.controls.chat 1.0

import SortFilterProxyModel 0.2

import AppLayouts.Profile.stores 1.0 as ProfileStores
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

    ColumnLayout {
        id: layout
        width: root.contentWidth
        spacing: Theme.padding

        QtObject {
            id: d

            readonly property var instructionsModel: [
                qsTr("Verify your login with password or KeyCard"),
                qsTr("Reveal a temporary QR and Sync Code") + "*",
                qsTr("Share that information with your new device"),
            ]


            function personalizeDevice(model) {
                Global.openPopup(personalizeDevicePopup, {
                                     "deviceModel": model
                                 })
            }

            function setupSyncing() {
                root.devicesStore.generateConnectionStringAndRunSetupSyncingPopup()
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
                onSetupSyncingButtonClicked: {
                    d.setupSyncing()
                }
                onClicked: {
                    if (deviceEnabled)
                        d.personalizeDevice(model)
                    else
                        d.setupSyncing()
                }
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 17

            implicitWidth: instructionsLayout.implicitWidth
                           + instructionsLayout.anchors.leftMargin
                           + instructionsLayout.anchors.rightMargin

            implicitHeight: instructionsLayout.implicitHeight
                            + instructionsLayout.anchors.topMargin
                            + instructionsLayout.anchors.bottomMargin

            color: Theme.palette.primaryColor3
            radius: 8

            ColumnLayout {
                id: instructionsLayout

                anchors {
                    fill: parent
                    topMargin: 24
                    bottomMargin: 24
                    leftMargin: 16
                    rightMargin: 16
                }

                spacing: 17

                Item {
                    Layout.alignment: Qt.AlignHCenter
                    height: syncNewDeviceText.height
                    width: syncNewDeviceText.width
                    Layout.topMargin: -8

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
                    font.pixelSize: Theme.primaryTextFontSize
                    font.weight: Font.Medium
                    text: qsTr("You own your data. Sync it among your devices.")
                }

                GridLayout {
                    Layout.alignment: Qt.AlignHCenter
                    rows: d.instructionsModel.length
                    flow: GridLayout.TopToBottom

                    Repeater {
                        model: d.instructionsModel

                        StatusBaseText {
                            Layout.alignment: Qt.AlignVCenter
                            color: Theme.palette.baseColor1
                            font.pixelSize: Theme.additionalTextSize
                            font.weight: Font.Medium
                            text: index + 1
                        }
                    }

                    Repeater {
                        model: d.instructionsModel

                        StatusBaseText {
                            Layout.alignment: Qt.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            color: Theme.palette.directColor1
                            font.pixelSize: Theme.primaryTextFontSize
                            text: modelData
                        }
                    }
                }

                StatusButton {

                    objectName: "setupSyncingStatusButton"           

                    Layout.alignment: Qt.AlignHCenter
                    normalColor: Theme.palette.primaryColor1
                    hoverColor: Theme.palette.miscColor1;
                    textColor: Theme.palette.indirectColor1
                    font.weight: Font.Medium
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

        StatusButton {
            objectName: "setupSyncBackupDataButton"

            id: backupBtn
            visible: !root.isProduction
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Backup Data")
            onClicked : {
                const lastUpdate = root.privacyStore.backupData() * 1000
                console.log("Backup done at: ", LocaleUtils.formatDateTime(lastUpdate))
            }
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
            id: getSyncCodeInstructionsPopup
            GetSyncCodeInstructionsPopup {
                destroyOnClose: true
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
}
