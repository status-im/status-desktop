import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0

import "../stores"

Item {
    id: root

    property AddAccountStore store

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Style.current.padding

        StatusListItem {
            title: qsTr("Add new master key")
            enabled: false
        }

        StatusListItem {
            objectName: "AddAccountPopup-ImportUsingSeedPhrase"
            title: qsTr("Import using seed phrase")
            asset {
                name: "key_pair_seed_phrase"
                color: Theme.palette.primaryColor1
                bgColor: Theme.palette.primaryColor3
            }
            components: [
                StatusIcon {
                    icon: "tiny/chevron-right"
                    color: Theme.palette.baseColor1
                }
            ]

            onClicked: {
                root.store.cleanSeedPhrase()
                root.store.currentState.doPrimaryAction()
            }
        }

        StatusListItem {
            objectName: "AddAccountPopup-ImportPrivateKey"
            title: qsTr("Import private key")
            asset {
                name: "objects"
                color: Theme.palette.primaryColor1
                bgColor: Theme.palette.primaryColor3
            }
            components: [
                StatusIcon {
                    icon: "tiny/chevron-right"
                    color: Theme.palette.baseColor1
                }
            ]

            onClicked: {
                root.store.cleanPrivateKey()
                root.store.currentState.doSecondaryAction()
            }
        }

        StatusListItem {
            objectName: "AddAccountPopup-GenerateNewMasterKey"
            title: qsTr("Generate new master key")
            asset {
                name: "objects"
                color: Theme.palette.primaryColor1
                bgColor: Theme.palette.primaryColor3
            }
            components: [
                StatusIcon {
                    icon: "tiny/chevron-right"
                    color: Theme.palette.baseColor1
                }
            ]

            onClicked: {
                root.store.resetStoreValues()
                root.store.currentState.doTertiaryAction()
            }
        }

        StatusModalDivider {
            width: parent.width
        }

        StatusListItem {
            title: qsTr("Use Keycard")
            sensor.enabled: false
            sensor.hoverEnabled: false
            statusListItemIcon.enabled: false
            statusListItemIcon.hoverEnabled: false
            asset {
                name: "keycard"
                color: Theme.palette.primaryColor1
                bgColor: Theme.palette.primaryColor3
            }
            components: [
                StatusButton {
                    objectName: "AddAccountPopup-GoToKeycardSettings"
                    text: qsTr("Continue in Keycard settings")
                    onClicked: {
                        Global.changeAppSectionBySectionType(Constants.appSection.profile, Constants.settingsSubsection.keycard)
                    }
                }
            ]
        }
    }
}
