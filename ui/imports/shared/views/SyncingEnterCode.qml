import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import shared.controls 1.0

ColumnLayout {
    id: root

    property string  firstTabName: qsTr("Scan QR code")
    property string  secondTabName: qsTr("Enter sync code")
    property string  firstInstructionButtonName: qsTr("How to get a sync code")
    property string  secondInstructionButtonName: qsTr("How to get a sync code")
    property string  syncQrErrorMessage: qsTr("This does not look like a sync QR code")
    property string  syncCodeErrorMessage: qsTr("This does not look like a sync code")
    property string  syncCodeLabel: qsTr("Paste sync code")

    property var validateConnectionString: function(stringValue) { return true }

    readonly property bool syncViaQr:  !switchTabBar.currentIndex

    signal displayInstructions()
    signal proceed(string connectionString)

    spacing: 8

    StatusSwitchTabBar {
        id: switchTabBar
        Layout.fillWidth: true
        Layout.leftMargin: 16
        Layout.rightMargin: 16
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
        Layout.preferredHeight: Math.max(syncQr.implicitHeight, syncCode.implicitHeight)
        Layout.topMargin: 24
        currentIndex: switchTabBar.currentIndex

        // StackLayout doesn't support alignment, so we create an `Item` wrappers

        Item {
            StatusSyncCodeScan {
                id: syncQr
                anchors {
                    left: parent.left
                    right: parent.right
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

        ColumnLayout {
            spacing: 20
            StatusSyncCodeInput {
                id: syncCode
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 424

                mode: StatusSyncCodeInput.Mode.WriteMode
                label: root.syncCodeLabel
                input.placeholderText: qsTr("eg. %1").arg("0x2Ef19")

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
                    root.proceed(syncCode.text)
                }
            }
            StatusBaseText {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                color: Theme.palette.baseColor1
                font.pixelSize: Theme.tertiaryTextFontSize
                text: qsTr("Ensure both devices are on the same network")
            }
        }
    }

    StatusFlatButton {
        Layout.alignment: Qt.AlignHCenter
        visible: switchTabBar.currentIndex == 0 && !!root.firstInstructionButtonName ||
                 switchTabBar.currentIndex == 1 && !!root.secondInstructionButtonName
        text: switchTabBar.currentIndex == 0?
                  root.firstInstructionButtonName :
                  root.secondInstructionButtonName
        onClicked: {
            root.displayInstructions()
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }
}
