import QtQuick 2.3
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import QtQuick.Dialogs 1.3
import "../shared"
import "../imports"

SwipeView {
    id: swipeView
    anchors.fill: parent
    currentIndex: 0

    onCurrentItemChanged: {
        currentItem.txtPassword.focus = true
    }

    Item {
        id: wizardStep1
        property int selectedIndex: 0
        Layout.fillHeight: true
        Layout.fillWidth: true
//        width: parent.width
//        height: parent.height

        Text {
            id: title
            text: "Login"
            font.pointSize: 36
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ButtonGroup {
            id: accountGroup
        }

        Component {
            id: addressViewDelegate

            Item {
                height: 56
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                Row {
                    RadioButton {
                        checked: index == 0 ? true : false
                        ButtonGroup.group: accountGroup
                        onClicked: {
                            wizardStep1.selectedIndex = index
                        }
                    }
                    Column {
                        Image {
                            source: identicon
                        }
                    }
                    Column {
                        Text {
                            text: username
                        }
                        Text {
                            text: key
                            width: 160
                            elide: Text.ElideMiddle
                        }
                    }
                }
            }
        }

        ListView {
            id: addressesView
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.bottom: footer.top
            anchors.bottomMargin: 0
            anchors.top: title.bottom
            anchors.topMargin: 16
            contentWidth: 200
            model: loginModel
            delegate: addressViewDelegate
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Item {
            id: footer
            width: btnGenKey.width + selectBtn.width + Theme.padding
            height: btnGenKey.height
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.padding
            anchors.horizontalCenter: parent.horizontalCenter

            StyledButton {
                id: btnGenKey
                label: "Generate new account"
            }

            StyledButton {
                id: selectBtn
                anchors.left: btnGenKey.right
                anchors.leftMargin: Theme.padding
                label: "Select"

                onClicked: {
                    swipeView.incrementCurrentIndex()
                }
            }
        }
    }

    Item {
        id: wizardStep2
        property Item txtPassword: txtPassword

        Text {
            text: "Enter password"
            font.pointSize: 36
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Input {
            id: txtPassword
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: Theme.padding
            anchors.leftMargin: Theme.padding
            anchors.left: parent.left
            anchors.right: parent.right
            otherProps: {
                this.textField.focus = true
                this.textField.focus
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
            onLoginResponseChanged: {
                const loginResponse = JSON.parse(response)
                if (loginResponse.error) {
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
                const selectedAccountIndex = wizardStep1.selectedIndex
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

