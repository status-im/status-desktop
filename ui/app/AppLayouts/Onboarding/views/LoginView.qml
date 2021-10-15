import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.13

import "../../../../shared"
import "../../../../shared/popups"
import "../../../../shared/panels"
import "../../../../shared/controls"
import "../../../../shared/status"
import "../popups"
import "../stores"

import utils 1.0

Item {
    property var onGenKeyClicked: function () {}
    property var onExistingKeyClicked: function () {}
    property bool loading: false

    id: loginView
    anchors.fill: parent

    function doLogin(password) {
        if (loading || password.length === 0)
            return

        loading = true
        LoginStore.login(password)
        // NEED TO HANDLE IT
        //applicationWindow.checkForStoringPassToKeychain(LoginStore.currentAccount.username, password, false)
        txtPassword.textField.clear()
    }

    function resetLogin() {
        if(accountSettings.storeToKeychain === Constants.storeToKeychainValueStore)
        {
            connection.enabled = true
            txtPassword.visible = false
            LoginStore.tryToObtainPassword()
        }
        else
        {
            txtPassword.visible = true
            txtPassword.forceActiveFocus(Qt.MouseFocusReason)
        }
    }

    Component.onCompleted: {
        resetLogin()
    }

    // NEED TO HANDLE IT
//    Connections{
//        id: connection
//        target: LoginStore.loginModelInst

//        onObtainingPasswordError: {
//            enabled = false
//            obtainingPasswordErrorNotification.confirmationText = errorDescription
//            obtainingPasswordErrorNotification.open()
//        }

//        onObtainingPasswordSuccess: {
//            enabled = false
//            doLogin(password)
//        }
//    }

    ConfirmationDialog {
        id: obtainingPasswordErrorNotification
        height: 270
        confirmButtonLabel: qsTr("Ok")

        onConfirmButtonClicked: {
            close()
        }

        onClosed: {
            txtPassword.visible = true
        }
    }

    Item {
        id: element
        width: 360
        height: 200
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        StatusImageIdenticon {
            id: userImage
            anchors.horizontalCenter: parent.horizontalCenter
            source: LoginStore.currentAccount.thumbnailImage ||
                    LoginStore.currentAccount.identicon
        }

        StyledText {
            id: usernameText
            text: LoginStore.currentAccount.username
            font.weight: Font.Bold
            font.pixelSize: 17
            anchors.top: userImage.bottom
            anchors.topMargin: 4
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ConfirmAddExistingKeyModal {
            id: confirmAddExstingKeyModal
            onOpenModalClick: function () {
                onExistingKeyClicked()
            }
        }

        SelectAnotherAccountModal {
            id: selectAnotherAccountModal
            onAccountSelect: function (index) {
                LoginStore.setCurrentAccount(index)
                resetLogin()
            }
            onOpenModalClick: function () {
                onExistingKeyClicked()
            }
        }

        Rectangle {
            property bool isHovered: false
            id: changeAccountBtn
            width: 24
            height: 24
            anchors.left: usernameText.right
            anchors.leftMargin: 4
            anchors.verticalCenter: usernameText.verticalCenter

            color: isHovered ? Style.current.backgroundHover : Style.current.transparent

            radius: 4

            SVGImage {
                id: caretImg
                width: 10
                height: 6
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                source: Style.svg("caret")
                fillMode: Image.PreserveAspectFit
            }
            ColorOverlay {
                anchors.fill: caretImg
                source: caretImg
                color: Style.current.secondaryText
            }
            MouseArea {
                hoverEnabled: true
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    changeAccountBtn.isHovered = true
                }
                onExited: {
                    changeAccountBtn.isHovered = false
                }
                onClicked: {
                    if (LoginStore.rowCount() > 1) {
                        selectAnotherAccountModal.open()
                    } else {
                        confirmAddExstingKeyModal.open()
                    }
                }
            }
        }

        Input {
            id: txtPassword
            anchors.top: changeAccountBtn.bottom
            anchors.topMargin: Style.current.padding * 2
            enabled: !loading
            placeholderText: loading ?
                //% "Connecting..."
                qsTrId("connecting") :
                //% "Enter password"
                qsTrId("enter-password")
            textField.echoMode: TextInput.Password
            textField.focus: true
            Keys.onReturnPressed: {
                doLogin(textField.text)
            }
            onTextEdited: {
                errMsg.visible = false
                loading = false
            }
        }

        StatusRoundButton {
            id: submitBtn
            size: "medium"
            type: "secondary"
            icon.name: "arrow-right"
            icon.width: 18
            icon.height: 14
            opacity: (loading || txtPassword.text.length > 0) ? 1 : 0
            anchors.left: txtPassword.visible? txtPassword.right : changeAccountBtn.right
            anchors.leftMargin: (loading || txtPassword.text.length > 0) ? Style.current.padding : Style.current.smallPadding
            anchors.verticalCenter: txtPassword.visible? txtPassword.verticalCenter : changeAccountBtn.verticalCenter
            state: loading ? "pending" : "default"
            onClicked: {
                doLogin(txtPassword.textField.text)
            }

            // https://www.figma.com/file/BTS422M9AkvWjfRrXED3WC/%F0%9F%91%8B-Onboarding%E2%8E%9CDesktop?node-id=6%3A0
            Behavior on opacity {
                OpacityAnimator {
                    from: 0.5
                    duration: 200
                }
            }
            Behavior on anchors.leftMargin {
                NumberAnimation {
                    duration: 200
                }
            }
        }

        // NEED TO HANDLE IT
//        Connections {
//            target: LoginStore.loginModelInst
//            ignoreUnknownSignals: true
//            onLoginResponseChanged: {
//                if (error) {
//                    // SQLITE_NOTADB: "file is not a database"
//                    if (error === "file is not a database") {
//                        errMsg.text = errMsg.incorrectPasswordMsg
//                    } else {
//                        //% "Login failed: %1"
//                        errMsg.text = qsTrId("login-failed---1").arg(error.toUpperCase())
//                    }
//                    errMsg.visible = true
//                    loading = false
//                    txtPassword.textField.forceActiveFocus()
//                }
//            }
//        }

        StatusButton {
            id: generateKeysLinkText
            //% "Generate new keys"
            text: qsTrId("generate-new-keys")
            anchors.top: txtPassword.visible? txtPassword.bottom : changeAccountBtn.bottom
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 13
            type: "secondary"
            onClicked: {
                onGenKeyClicked()
            }
        }

        StyledText {
            id: errMsg
            //% "Login failed. Please re-enter your password and try again."
            readonly property string incorrectPasswordMsg: qsTrId("login-failed--please-re-enter-your-password-and-try-again-")
            anchors.top: generateKeysLinkText.bottom
            anchors.topMargin: Style.current.smallPadding
            anchors.horizontalCenter: parent.horizontalCenter
            visible: false
            text: incorrectPasswordMsg
            font.pixelSize: 13
            color: Style.current.danger
        }
    }
}
