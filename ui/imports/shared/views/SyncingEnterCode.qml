import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import shared.controls 1.0

ColumnLayout {
    id: root

    property string  firstTabName: qsTr("Scan QR code")
    property string  secondTabName: qsTr("Enter sync code")
    property string  syncQrErrorMessage: qsTr("This does not look like a sync QR code")
    property string  syncCodeErrorMessage: qsTr("This does not look like a sync code")
    property string  instructionButtonName: qsTr("How to get a sync code")

    property var validateConnectionString: function(){}

    signal displayInstructions()
    signal proceed(string connectionString)

    Timer {
        id: nextStateDelay

        property string connectionString

        interval: 1000
        repeat: false
        onTriggered: {
            root.proceed(connectionString)
        }
    }


    StatusSwitchTabBar {
        id: switchTabBar
        Layout.alignment: Qt.AlignHCenter
        currentIndex: 0

        StatusSwitchTabButton {
            text: root.firstTabName
        }

        StatusSwitchTabButton {
            text: root.secondTabName
        }
    }

    StackLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.max(mobileSync.implicitHeight, desktopSync.implicitHeight)
        currentIndex: switchTabBar.currentIndex

        // StackLayout doesn't support alignment, so we create an `Item` wrappers

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            StatusSyncCodeScan {
                id: mobileSync
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                validators: [
                    StatusValidator {
                        name: "isSyncQrCode"
                        errorMessage: root.syncQrErrorMessage
                        validate: root.validateConnectionString
                    }
                ]
                onConnectionStringFound: {
                    root.proceed(connectionString)
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            StatusSyncCodeInput {
                id: desktopSync
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                readOnly: nextStateDelay.running
                validators: [
                    StatusValidator {
                        name: "isSyncCode"
                        errorMessage: root.syncCodeErrorMessage
                        validate: root.validateConnectionString
                    }
                ]
                input.onValidChanged: {
                    if (!input.valid)
                        return
                    nextStateDelay.connectionString = desktopSync.text
                    nextStateDelay.start()
                }
            }
        }
    }

    StatusFlatButton {
        Layout.alignment: Qt.AlignHCenter
        visible: !!root.instructionButtonName
        text: root.instructionButtonName
        onClicked: {
            root.displayInstructions()
        }
    }
}
