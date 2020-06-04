import QtQuick 2.3
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import QtQuick.Dialogs 1.3
import "../shared"
import "../imports"
import "./Login"

SwipeView {
    property alias btnGenKey: accountSelection.btnGenKey

    id: swipeView
    anchors.fill: parent
    currentIndex: 0
    interactive: false

    onCurrentItemChanged: {
        if(currentItem.txtPassword) {
            currentItem.txtPassword.textField.focus = true
        }
    }

    AccountSelection {
        id: accountSelection
        onAccountSelect: function() {
            loginModel.setCurrentAccount(this.selectedIndex)
            swipeView.incrementCurrentIndex()
        }
    }

    Item {
        id: wizardStep2
        property Item txtPassword: txtPassword

        Text {
            id: step2Title
            text: "Enter password"
            font.pointSize: 36
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: step2Title.bottom
            anchors.topMargin: 30
            Column {
                Image {
                  source: loginModel.currentAccount.identicon
                }
            }
            Column {
                Text {
                  text: loginModel.currentAccount.username
                }
            }
        }

        Input {
            id: txtPassword
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: Theme.padding
            anchors.leftMargin: Theme.padding
            anchors.left: parent.left
            anchors.right: parent.right
            placeholderText: "Enter password"

            Component.onCompleted: {
                this.textField.echoMode = TextInput.Password
            }
            Keys.onReturnPressed: {
                submitBtn.clicked()
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
            }
        }

        Connections {
            target: loginModel
            ignoreUnknownSignals: true
            onLoginResponseChanged: {
              if(error){
                  loginError.open()
              }
            }
        }

        StyledButton {
            id: submitBtn
            label: "Finish"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            onClicked: {
                const selectedAccountIndex = accountSelection.selectedIndex
                const response = loginModel.login(selectedAccountIndex, txtPassword.textField.text)
                // TODO: replace me with something graphical (ie spinner)
                console.log("Logging in...")
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

