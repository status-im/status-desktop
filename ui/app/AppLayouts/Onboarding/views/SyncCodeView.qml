import QtQuick 2.13
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.13
import QtQuick.Controls.Universal 2.12

import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups.Dialog 0.1

import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.controls 1.0

import "../popups"
import "../controls"
import "../stores"
import "sync"
import "../../Profile/stores"

import utils 1.0

Item {
    id: root

    property StartupStore startupStore

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    QtObject {
        id: d

        property string connectionString

        function validateConnectionString(connectionString) {
            const result = root.startupStore.validateLocalPairingConnectionString(connectionString)
            return result === ""
        }
    }

    Timer {
        id: nextStateDelay
        interval: 1000
        repeat: false
        onTriggered: {
            root.startupStore.setConnectionString(d.connectionString)
            root.startupStore.doPrimaryAction()
        }
    }

    Column {
        id: layout

        anchors.centerIn: parent
        width: 400
        spacing: 24

        StatusBaseText {
            id: headlineText
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 22
            font.weight: Font.Bold
            color: Theme.palette.directColor1
            text: qsTr("Sign in by syncing")
        }

        StatusSwitchTabBar {
            id: switchTabBar
            anchors.horizontalCenter: parent.horizontalCenter
            currentIndex: 0

            StatusSwitchTabButton {
                text: qsTr("Scan QR code")
            }

            StatusSwitchTabButton {
                text: qsTr("Enter sync code")
            }
        }

        StackLayout {
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter

            implicitWidth: Math.max(mobileSync.implicitWidth, desktopSync.implicitWidth)
            implicitHeight: Math.max(mobileSync.implicitHeight, desktopSync.implicitHeight)
            currentIndex: switchTabBar.currentIndex
            clip: true

            // StackLayout doesn't support alignment, so we create an `Item` wrappers

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                implicitWidth: mobileSync.implicitWidth
                implicitHeight: mobileSync.implicitHeight

                SyncDeviceFromMobile {
                    id: mobileSync
                    anchors {
                        verticalCenter: parent.verticalCenter
                        horizontalCenter: parent.horizontalCenter
                    }
                    onConnectionStringFound: {
                        d.processConnectionString(connectionString)
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                implicitWidth: desktopSync.implicitWidth
                implicitHeight: desktopSync.implicitHeight

                SyncDeviceFromDesktop {
                    id: desktopSync
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    input.readOnly: nextStateDelay.running
                    input.validators: [
                        StatusValidator {
                            name: "asyncConnectionString"
                            errorMessage: qsTr("This does not look like a sync code")
                            validate: (value) => {
                                          return d.validateConnectionString(value)
                                      }
                        }
                    ]
                    input.onValidChanged: {
                        if (!input.valid) {
                            d.connectionString = ""
                            return
                        }
                        d.connectionString = desktopSync.input.text
                        nextStateDelay.start()
                    }
                }
            }
        }

        StatusFlatButton {
            text: qsTr("How to get a sync code")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                instructionsPopup.open()
            }
        }
    }

    GetSyncCodeInstructionsPopup {
        id: instructionsPopup
    }
}
