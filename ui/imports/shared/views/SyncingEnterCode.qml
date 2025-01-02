import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1

import shared.controls 1.0

ColumnLayout {
    id: root

    property string  firstTabName: qsTr("Scan QR code")
    property string  secondTabName: qsTr("Enter code")
    property string  firstInstructionButtonName: qsTr("How to get a pairing code")
    property string  secondInstructionButtonName: qsTr("How to get a pairing code")
    property string  syncQrErrorMessage: qsTr("This does not look like a pairing QR code")
    property string  syncCodeErrorMessage: qsTr("This does not look like a pairing code")
    property string  syncCodeLabel: qsTr("Type or paste pairing code")
    property alias showBetaTag: betaTag.visible

    property var validateConnectionString: function(stringValue) { return false }

    readonly property bool syncViaQr: !switchTabBar.currentIndex

    signal displayInstructions()
    signal proceed(string connectionString)

    spacing: Theme.halfPadding

    RowLayout {
        spacing: root.spacing
        Layout.fillWidth: true
        Layout.leftMargin: Theme.bigPadding
        Layout.rightMargin: Theme.bigPadding

        StatusSwitchTabBar {
            Layout.fillWidth: true
            Layout.leftMargin: betaTag.visible ? betaTag.width : 0
            id: switchTabBar

            currentIndex: 0

            StatusSwitchTabButton {
                objectName: "firstTab_StatusSwitchTabButton"
                text: root.firstTabName
            }

            StatusSwitchTabButton {
                objectName: "secondTab_StatusSwitchTabButton"
                text: root.secondTabName
            }
        }

        StatusBetaTag {
            id: betaTag
        }
    }

    StackLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.max(syncQr.implicitHeight, syncCode.implicitHeight)
        Layout.topMargin: Theme.bigPadding
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
            Layout.topMargin: Theme.padding
            spacing: Theme.padding
            StatusSyncCodeInput {
                objectName: "syncCodeInput"
                id: syncCode
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 440

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
            }
            StatusBaseText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                color: Theme.palette.baseColor1
                font.pixelSize: Theme.tertiaryTextFontSize
                text: qsTr("Ensure both devices are on the same local network")
            }
            StatusButton {
                objectName: "continue_StatusButton"
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Theme.padding
                text: qsTr("Continue")
                enabled: syncCode.input.valid
                onClicked: root.proceed(syncCode.text)
            }
        }
    }

    StatusFlatButton {
        Layout.topMargin: Theme.xlPadding
        Layout.alignment: Qt.AlignHCenter
        visible: switchTabBar.currentIndex == 0 && !!root.firstInstructionButtonName ||
                 switchTabBar.currentIndex == 1 && !!root.secondInstructionButtonName
        text: switchTabBar.currentIndex == 0?
                  root.firstInstructionButtonName :
                  root.secondInstructionButtonName
        font.pixelSize: Theme.additionalTextSize
        normalColor: "transparent"
        borderWidth: 1
        borderColor: Theme.palette.baseColor2
        onClicked: {
            root.displayInstructions()
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }
}
