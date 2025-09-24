import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models

import StatusQ
import StatusQ.Core
import StatusQ.Controls
import StatusQ.Core.Theme
import StatusQ.Popups.Dialog

import AppLayouts.Onboarding.controls

Control {
    id: root

    required property bool isBiometricsLogin
    required property bool biometricsSuccessful
    required property bool biometricsFailed

    property string validationError
    property string detailedError
    onValidationErrorChanged: if (!validationError) detailedError = ""

    property alias password: txtPassword.text
    signal passwordEditedManually()

    signal detailedErrorPopupRequested()

    signal biometricsRequested()
    signal loginRequested(string password)

    function clear() {
        txtPassword.clear()
    }

    function forceActiveFocus() {
        txtPassword.forceActiveFocus()
    }

    padding: 0
    background: null
    spacing: Theme.halfPadding

    contentItem: ColumnLayout {
        spacing: root.spacing
        LoginPasswordInput {
            Layout.fillWidth: true
            id: txtPassword
            objectName: "loginPasswordInput"
            isBiometricsLogin: root.isBiometricsLogin
            biometricsSuccessful: root.biometricsSuccessful
            biometricsFailed: root.biometricsFailed
            hasError: !!root.validationError
            onTextEdited: root.passwordEditedManually()
            onBiometricsRequested: root.biometricsRequested()
            onAccepted: root.loginRequested(text)
        }
        StatusBaseText {
            Layout.fillWidth: true
            elide: Text.ElideRight
            text: root.validationError
            color: Theme.palette.dangerColor1
            horizontalAlignment: Qt.AlignRight
            font.pixelSize: Theme.tertiaryTextFontSize
            linkColor: hoveredLink ? Theme.palette.hoverColor(color) : color
            HoverHandler {
                cursorShape: !!parent.hoveredLink ? Qt.PointingHandCursor : undefined
            }
            onLinkActivated: (link) => {
                if (link.startsWith("#password"))
                  forgottenPassInstructionsPopupComp.createObject(root).open()
                else
                  root.detailedErrorPopupRequested()
            }
        }
        StatusButton {
            Layout.topMargin: 20
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 44
            objectName: "loginButton"
            text: qsTr("Log In")
            enabled: {
                if (root.isBiometricsLogin && root.biometricsSuccessful)
                    return false
                return txtPassword.text !== ""
            }

            onClicked: root.loginRequested(txtPassword.text)
        }
    }

    Component {
        id: forgottenPassInstructionsPopupComp
        StatusDialog {
            width: 480
            padding: 20
            title: qsTr("Forgot your password?")
            destroyOnClose: true
            standardButtons: Dialog.Ok
            contentItem: ColumnLayout {
                spacing: 20
                StatusBaseText {
                    Layout.fillWidth: true
                    text: qsTr("To recover your password follow these steps:")
                }
                OnboardingFrame {
                    Layout.fillWidth: true
                    cornerRadius: Theme.radius
                    padding: Theme.padding
                    dropShadow: false
                    contentItem: ColumnLayout {
                        spacing: 4
                        StatusBaseText {
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                            text: qsTr("1. Remove the Status app")
                            font.weight: Font.DemiBold
                        }
                        StatusBaseText {
                            Layout.fillWidth: true
                            Layout.leftMargin: Theme.padding
                            wrapMode: Text.Wrap
                            text: qsTr("This will erase all of your data from the device, including your password")
                        }
                        StatusBaseText {
                            Layout.fillWidth: true
                            Layout.topMargin: 20
                            wrapMode: Text.Wrap
                            text: qsTr("2. Reinstall the Status app")
                            font.weight: Font.DemiBold
                        }
                        StatusBaseText {
                            Layout.fillWidth: true
                            Layout.leftMargin: Theme.padding
                            wrapMode: Text.Wrap
                            text: qsTr("Re-download the app from %1 %2").arg("<a href='#'>status.app</a>").arg("🔗")
                            linkColor: !!hoveredLink ? Theme.palette.primaryColor1 : color
                            onLinkActivated: Qt.openUrlExternally("https://status.app")
                            HoverHandler {
                                cursorShape: !!parent.hoveredLink ? Qt.PointingHandCursor : undefined
                            }
                        }
                        StatusBaseText {
                            Layout.fillWidth: true
                            Layout.topMargin: 20
                            wrapMode: Text.Wrap
                            text:qsTr("3. Sign up with your existing keys")
                            font.weight: Font.DemiBold
                        }
                        StatusBaseText {
                            Layout.fillWidth: true
                            Layout.leftMargin: Theme.padding
                            wrapMode: Text.Wrap
                            text: qsTr("Access with your recovery phrase or Keycard")
                        }
                        StatusBaseText {
                            Layout.fillWidth: true
                            Layout.topMargin: 20
                            wrapMode: Text.Wrap
                            text: qsTr("4. Create a new password")
                            font.weight: Font.DemiBold
                        }
                        StatusBaseText {
                            Layout.fillWidth: true
                            Layout.leftMargin: Theme.padding
                            wrapMode: Text.Wrap
                            text: qsTr("Enter a new password and you’re all set! You will be able to use your new password")
                        }
                    }
                }
            }
        }
    }
}
