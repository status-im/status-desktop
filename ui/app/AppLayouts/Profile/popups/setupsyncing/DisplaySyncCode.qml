import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.14
import QtQml.StateMachine 1.14 as DSM


import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import shared.controls 1.0
import shared.panels 1.0
import utils 1.0

ColumnLayout {
    id: root

    spacing: 0

    DSM.StateMachine {
        running: root.visible
        initialState: qrHiddenState

        DSM.State {
            id: qrHiddenState

            onEntered: d.secondsLeft = d.secondsTimeout

            DSM.SignalTransition {
                targetState: qrVisibleState
                signal: revealButton.clicked
            }
        }

        DSM.State {
            id: qrVisibleState

            onEntered: expireTimer.start()

            DSM.SignalTransition {
                targetState: qrExpiredState
                signal: expireTimer.triggered
            }
        }

        DSM.State {
            id: qrExpiredState

            onEntered: syncCodeInput.showPassword = false

            DSM.SignalTransition {
                targetState: qrHiddenState
                signal: revealButton.clicked
            }
        }
    }

    QtObject {
        id: d

        property int secondsTimeout: 5 * 60
        property int secondsLeft: secondsTimeout
        property int secondsRatio: 60 // This property can be used to speed up testing of syncCode expiration
    }

    Timer {
        id: expireTimer
        interval: d.secondsTimeout * 1000 / d.secondsRatio
    }

    Timer {
        id: updateTimer
        interval: 1000 / d.secondsRatio
        repeat: true
        running: qrVisibleState.active
        onTriggered: d.secondsLeft = Math.max(0, --d.secondsLeft)
    }

    Item {
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: 254
        implicitHeight: 254

        StatusIcon {
            id: qrCode
            anchors.fill: parent
            icon: "qr"
            visible: false
        }

        FastBlur {
            anchors.fill: qrCode
            source: qrCode
            radius: qrVisibleState.active ? 0 : 16
            transparentBorder: true

            Behavior on radius {
                NumberAnimation { duration: 500 }
            }
        }

        StatusButton {
            id: revealButton
            anchors.centerIn: parent
            visible: qrHiddenState.active || qrExpiredState.active
            normalColor: Theme.palette.primaryColor1
            hoverColor: Theme.palette.miscColor1;
            textColor: Theme.palette.indirectColor1
            font.weight: Font.Medium
            icon.name: qrExpiredState.active ? "refresh" : "show"
            text: qrExpiredState.active ? qsTr("Regenerate") : qsTr("Reveal QR")
        }
    }

    Row {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 16

        StatusBaseText {
            font.pixelSize: 17
            text: qsTr("Code valid for: ")
        }

        StatusBaseText {
            id: timeoutText
            width: fontMetrics.advanceWidth("10:00")
            horizontalAlignment: Text.AlignLeft
            font.pixelSize: 17
            color: d.secondsLeft < 60 ? Theme.palette.dangerColor1 : Theme.palette.directColor1

            text: {
                const minutes = Math.floor(d.secondsLeft / 60);
                const seconds = d.secondsLeft % 60;
                return `${minutes}:${String(seconds).padStart(2,'0')}`;
            }

            FontMetrics {
                id: fontMetrics
                font: timeoutText.font
            }
        }
    }

    // TODO: Extract this to a component.
    //       Also used in `PasswordView` and several other files.
    //       https://github.com/status-im/status-desktop/issues/6136

    StyledText {
        id: inputLabel
        Layout.fillWidth: true
        Layout.topMargin: 12
        Layout.bottomMargin: 7
        text: qsTr("Sync code")
        font.weight: Font.Medium
        font.pixelSize: 13
        color: Theme.palette.directColor1
    }

    Input {
        id: syncCodeInput

        property bool showPassword

        Layout.fillWidth: true
        Layout.bottomMargin: 24
        readOnly: true
        keepHeight: true
        textField.echoMode: showPassword ? TextInput.Normal : TextInput.Password
        textField.rightPadding: syncCodeButtons.width + Style.current.padding / 2
        textField.color: Style.current.textColor
        text: "0x1234567890abcdefghij"

        Row {
            id: syncCodeButtons
            anchors.verticalCenter: syncCodeInput.verticalCenter
            anchors.right: parent.right
            spacing: 16
            rightPadding: 16
            leftPadding: 16

            StatusFlatRoundButton {
                anchors.right: syncCodeInputCopyButton.left
                width: 24
                height: 24
                icon.name: syncCodeInput.showPassword ? "hide" : "show"
                icon.color: Theme.palette.baseColor1
                onClicked: syncCodeInput.showPassword = !syncCodeInput.showPassword
            }

            StatusButton {
                size: StatusBaseButton.Size.Tiny
                onClicked: {
                    syncCodeInput.textField.selectAll();
                    syncCodeInput.textField.copy();
                    syncCodeInput.textField.deselect();
                }

                text: qsTr("Copy")
            }
        }
    }

    StatusBaseText {
        Layout.fillWidth: true
        Layout.fillHeight: true
        horizontalAlignment: Text.AlignHCenter
        visible: !qrExpiredState.active
        font.pixelSize: 15
        color: Theme.palette.baseColor1
        text: qsTr("On your other device, navigate to the Syncing<br>screen and select Enter Sync Code.")
    }

    StatusBaseText {
        Layout.fillWidth: true
        Layout.fillHeight: true
        horizontalAlignment: Text.AlignHCenter
        visible: qrExpiredState.active
        font.pixelSize: 15
        color: Theme.palette.baseColor1
        text: qsTr("Your QR and Sync Code has expired.")
    }


}
