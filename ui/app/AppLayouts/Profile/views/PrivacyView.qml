import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared.panels 1.0
import shared.status 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1 as StatusQControls

import "../popups"
import "../stores"

SettingsContentBase {
    id: root

    property PrivacyStore privacyStore

    ColumnLayout {
        spacing: Constants.settingsSection.itemSpacing
        width: root.contentWidth

        StatusListItem {
            id: backupSeedPhrase
            Layout.fillWidth: true
            //% "Backup Seed Phrase"
            title: qsTrId("backup-seed-phrase")
            enabled: !root.privacyStore.mnemonicBackedUp
            implicitHeight: 52
            components: [
                StatusBadge {
                    value: !root.privacyStore.mnemonicBackedUp
                    visible: !root.privacyStore.mnemonicBackedUp
                    anchors.verticalCenter: parent.verticalCenter
                },
                StatusIcon {
                    icon: "chevron-down"
                    rotation: 270
                    color: Theme.palette.baseColor1
                }
            ]
            sensor.onClicked: Global.openBackUpSeedPopup()
        }

        StatusListItem {
            Layout.fillWidth: true
            title: qsTr("Change password")
            implicitHeight: 52
            components: [
                StatusIcon {
                    icon: "chevron-down"
                    rotation: 270
                    color: Theme.palette.baseColor1
                }
            ]
            sensor.onClicked: changePasswordModal.open()
        }

        StatusListItem {
            Layout.fillWidth: true
            title: qsTr("Store pass to Keychain")
            implicitHeight: 52
            visible: Qt.platform.os == "osx" // For now, this is available only on MacOS
            label: {
                let value = localAccountSettings.storeToKeychainValue
                if(value == Constants.storeToKeychainValueStore)
                    return qsTr("Store")

                if(value == Constants.storeToKeychainValueNever)
                    return qsTr("Never")

                return qsTr("Not now")
            }
            components: [
                StatusIcon {
                    icon: "chevron-down"
                    rotation: 270
                    color: Theme.palette.baseColor1
                }
            ]
            sensor.onClicked: Global.openPopup(storeToKeychainSelectionModal)

            Component {
                id: storeToKeychainSelectionModal
                StoreToKeychainSelectionModal {
                    privacyStore: root.privacyStore
                }
            }
        }

        ChangePasswordModal {
            id: changePasswordModal
            privacyStore: root.privacyStore
            anchors.centerIn: parent

            onPasswordChanged: successPopup.open()
        }

        ChangePasswordSuccessModal {
            id: successPopup
            anchors.centerIn: parent
        }
    }
}
