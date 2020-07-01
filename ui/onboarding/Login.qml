import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.13
import "../shared"
import "../imports"
import "../sounds"
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

    ErrorSound {
        id: errorSound
    }

    Item {
        id: element
        width: 360
        height: 200
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        Identicon {
            id: userImage
            width: 40
            height: 40
            anchors.horizontalCenter: parent.horizontalCenter
            source: loginModel.currentAccount.identicon
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
                confirmAddExstingKeyModal.open()
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

            color: isHovered ? Theme.grey : Theme.transparent

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
                color: Theme.darkGrey
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
                        onExistingKeyClicked()
                    }
                }
            }
        }

        StyledText {
            id: addressText
            width: 90
            color: Theme.darkGrey
            text: loginModel.currentAccount.address
            font.family: Theme.fontHexRegular.name
            elide: Text.ElideMiddle
            font.pixelSize: 15
            anchors.top: usernameText.bottom
            anchors.topMargin: 4
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Input {
            id: txtPassword
            anchors.top: addressText.bottom
            anchors.topMargin: Theme.padding * 2
            placeholderText: "Enter password"
            textField.echoMode: TextInput.Password
            textField.focus: true
            Keys.onReturnPressed: {
                submitBtn.clicked()
            }
        }

        Button {
            id: submitBtn
            visible: !loading && txtPassword.text.length > 0
            width: 40
            height: 40
            anchors.left: txtPassword.right
            anchors.leftMargin: Theme.padding
            anchors.verticalCenter: txtPassword.verticalCenter
            onClicked: {
                if (loading) {
                    return;
                }
                setCurrentFlow(true);
                loading = true
                loginModel.login(txtPassword.textField.text)
            }
            SVGImage {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                source: "../app/img/arrowUp.svg"
                width: 13.5
                height: 17.5
                fillMode: Image.PreserveAspectFit
                rotation: 90
            }
            background: Rectangle {
                color: Theme.blue
                radius: 50
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    submitBtn.onClicked()
                }
            }
        }

        SVGImage {
            id: loadingImg
            visible: loading
            anchors.left: txtPassword.right
            anchors.leftMargin: Theme.padding
            anchors.verticalCenter: txtPassword.verticalCenter
            // TODO replace by a real loading image
            source: "../app/img/settings.svg"
            width: 30
            height: 30
            fillMode: Image.Stretch
            RotationAnimator {
                target: loadingImg;
                from: 0;
                to: 360;
                duration: 1200
                running: true
                loops: Animation.Infinite
            }
        }

        MessageDialog {
            id: loginError
            title: "Login failed"
            text: "Login failed. Please re-enter your password and try again."
            icon: StandardIcon.Critical
            standardButtons: StandardButton.Ok
            onAccepted: {
                txtPassword.textField.clear()
                txtPassword.textField.focus = true
                loading = false
            }
        }

        Connections {
            target: loginModel
            ignoreUnknownSignals: true
            onLoginResponseChanged: {
                if (error) {
                    errorSound.play()
                    loginError.open()
                }
            }
        }

        MouseArea {
            id: generateKeysLink
            width: generateKeysLinkText.width
            height: generateKeysLinkText.height
            cursorShape: Qt.PointingHandCursor
            anchors.top: txtPassword.bottom
            anchors.topMargin: 26
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                setCurrentFlow(false);
                onGenKeyClicked()
            }

            StyledText {
                id: generateKeysLinkText
                color: Theme.blue
                text: qsTr("Generate new keys")
                font.pixelSize: 13
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";formeditorZoom:0.75;height:480;width:640}
}
##^##*/
