import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.panels 1.0
import shared.controls 1.0
import shared.status 1.0
import shared.popups.keycard 1.0

import "../stores"

SettingsContentBase {
    id: root

    property KeycardStore keycardStore

    titleRowComponentLoader.sourceComponent: StatusButton {
        text: qsTr("Get Keycard")
        onClicked: {
            console.warn("TODO: Go to purchase page...")
        }
    }

    ColumnLayout {
        id: contentColumn
        spacing: Constants.settingsSection.itemSpacing

        Connections {
            target: root.keycardStore.keycardModule

            onDisplayKeycardSharedModuleFlow: {
                keycardPopup.active = true
            }
            onDestroyKeycardSharedModuleFlow: {
                keycardPopup.active = false
            }
        }

        Loader {
            id: keycardPopup
            active: false
            sourceComponent: KeycardPopup {
                sharedKeycardModule: root.keycardStore.keycardModule.keycardSharedModule
            }

            onLoaded: {
                keycardPopup.item.open()
            }
        }

        Image {
            Layout.alignment: Qt.AlignCenter
            Layout.preferredHeight: sourceSize.height
            Layout.preferredWidth: sourceSize.width
            fillMode: Image.PreserveAspectFit
            antialiasing: true
            source: Style.png("keycard/security-keycard@2x")
            mipmap: true
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.current.halfPadding
        }

        StyledText {
            Layout.alignment: Qt.AlignCenter
            font.pixelSize: Constants.settingsSection.importantInfoFontSize
            color: Style.current.directColor1
            text: qsTr("Secure your funds. Keep your profile safe.")
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.current.halfPadding
        }

        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Setup a new Keycard with an existing account")
            components: [
                StatusIcon {
                    icon: "chevron-down"
                    rotation: 270
                    color: Theme.palette.baseColor1
                }
            ]
            onClicked: {
                root.keycardStore.runSetupKeycardPopup()
            }
        }

        StatusSectionHeadline {
            Layout.preferredWidth: root.contentWidth
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            text: qsTr("Create, import or restore a Keycard account")
        }

        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Generate a seed phrase")
            components: [
                StatusIcon {
                    icon: "chevron-down"
                    rotation: 270
                    color: Theme.palette.baseColor1
                }
            ]
            onClicked: {
                console.warn("TODO: Generate a seed phrase...")
            }
        }

        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Import or restore via a seed phrase")
            components: [
                StatusIcon {
                    icon: "chevron-down"
                    rotation: 270
                    color: Theme.palette.baseColor1
                }
            ]
            onClicked: {
                console.warn("TODO: Import or restore via a seed phrase...")
            }
        }

        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Import from Keycard to Status Desktop")
            components: [
                StatusIcon {
                    icon: "chevron-down"
                    rotation: 270
                    color: Theme.palette.baseColor1
                }
            ]
            onClicked: {
                console.warn("TODO: Import from Keycard to Status Desktop...")
            }
        }

        StatusSectionHeadline {
            Layout.preferredWidth: root.contentWidth
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            text: qsTr("Other")
        }

        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Check what’s on a Keycard")
            components: [
                StatusIcon {
                    icon: "chevron-down"
                    rotation: 270
                    color: Theme.palette.baseColor1
                }
            ]
            onClicked: {
                root.keycardStore.runDisplayKeycardContentPopup()
            }
        }

        StatusListItem {
            Layout.preferredWidth: root.contentWidth
            title: qsTr("Factory reset a Keycard")
            components: [
                StatusIcon {
                    icon: "chevron-down"
                    rotation: 270
                    color: Theme.palette.baseColor1
                }
            ]
            onClicked: {
                root.keycardStore.runFactoryResetPopup()
            }
        }
    }
}
