import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.13
import "../shared"
import "../shared/status"
import "../imports"
import "./Login"

Item {
    property var onGenKeyClicked: function () {}
    property var onExistingKeyClicked: function () {}
    property bool loading: false

    id: loginView
    anchors.fill: parent

    function setCurrentFlow(isLogin) {
        loginModel.isCurrentFlow = isLogin;
        onboardingModel.isCurrentFlow = !isLogin;
    }

    Component.onCompleted: {
        txtPassword.forceActiveFocus(Qt.MouseFocusReason)
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
            source: loginModel.currentAccount.thumbnailImage
        }

        StyledText {
            id: usernameText
            text: loginModel.currentAccount.username
            font.weight: Font.Bold
            font.pixelSize: 17
            anchors.top: userImage.bottom
            anchors.topMargin: 4
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ConfirmAddExistingKeyModal {
            id: confirmAddExstingKeyModal
            onOpenModalClick: function () {
                setCurrentFlow(false);
                onExistingKeyClicked()
            }
        }

        SelectAnotherAccountModal {
            id: selectAnotherAccountModal
            onAccountSelect: function (index) {
                loginModel.setCurrentAccount(index)
            }
            onOpenModalClick: function () {
                setCurrentFlow(true);
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
                source: "../app/img/caret.svg"
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
                    if (loginModel.rowCount() > 1) {
                        selectAnotherAccountModal.open()
                    } else {
                        confirmAddExstingKeyModal.open()
                    }
                }
            }
        }

        Address {
            id: addressText
            width: 90
            text: loginModel.currentAccount.address
            font.pixelSize: 15
            anchors.top: usernameText.bottom
            anchors.topMargin: 4
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Input {
            id: txtPassword
            anchors.top: addressText.bottom
            anchors.topMargin: Style.current.padding * 2
            enabled: !loading
            //% "Enter password"
            placeholderText: loading ? qsTr("Connecting...") : qsTrId("enter-password")
            textField.echoMode: TextInput.Password
            textField.focus: true
            Keys.onReturnPressed: {
                submitBtn.clicked()
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
            anchors.left: txtPassword.right
            anchors.leftMargin: (loading || txtPassword.text.length > 0) ? Style.current.padding : Style.current.smallPadding
            anchors.verticalCenter: txtPassword.verticalCenter
            state: loading ? "pending" : "default"
            onClicked: {
                if (loading) {
                    return;
                }
                setCurrentFlow(true);
                loading = true
                loginModel.login(txtPassword.textField.text)
                txtPassword.textField.clear()
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

        Connections {
            target: loginModel
            ignoreUnknownSignals: true
            onLoginResponseChanged: {
                if (error) {
                    // SQLITE_NOTADB: "file is not a database"
                    if (error === "file is not a database") {
                        errMsg.text = errMsg.incorrectPasswordMsg
                    } else {
                        errMsg.text = qsTr("Login failed: %1").arg(error.toUpperCase())
                    }
                    errMsg.visible = true
                    loading = false
                    txtPassword.textField.forceActiveFocus()
                }
            }
        }

        StatusButton {
            id: generateKeysLinkText
            //% "Generate new keys"
            text: qsTrId("generate-new-keys")
            anchors.top: txtPassword.bottom
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 13
            type: "secondary"
            onClicked: {
                setCurrentFlow(false);
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

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";formeditorZoom:0.75;height:480;width:640}
}
##^##*/
