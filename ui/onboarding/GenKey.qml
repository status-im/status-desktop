import QtQuick 2.3
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import QtQuick.Dialogs 1.3
import "../imports"
import "../shared"

SwipeView {
    id: swipeView
    anchors.fill: parent
    currentIndex: 0

    property alias btnExistingKey: btnExistingKey

    onCurrentItemChanged: {
        currentItem.txtPassword.textField.focus = true;
    }

    Item {
        id: wizardStep1
        property int selectedIndex: 0
        Layout.fillHeight: true
        Layout.fillWidth: true

        Text {
            id: title
            text: "Generated accounts"
            font.pointSize: 36
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Item {
            anchors.top: title.bottom
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.topMargin: 20


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
                contentWidth: 200
                model: onboardingModel
                delegate: addressViewDelegate
                anchors.fill: parent
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            Item {
                id: footer
                width: btnExistingKey.width + selectBtn.width + Theme.padding
                height: btnExistingKey.height
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.padding
                anchors.horizontalCenter: parent.horizontalCenter

                StyledButton {
                    id: btnExistingKey
                    label: "Access existing key"
                }

                StyledButton {
                    id: selectBtn
                    anchors.left: btnExistingKey.right
                    anchors.leftMargin: Theme.padding
                    label: "Select"

                    onClicked: {
                        swipeView.incrementCurrentIndex()
                    }
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
            placeholderText: "Enter password"

            Component.onCompleted: {
                this.textField.echoMode = TextInput.Password
            }
            Keys.onReturnPressed: {
                btnNext.clicked()
            }
        }

        StyledButton {
            id: btnNext
            label: "Next"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            onClicked: {
                swipeView.incrementCurrentIndex();
            }
        }
    }

    Item {
        id: wizardStep3
        property Item txtPassword: txtConfirmPassword

        Text {
            text: "Confirm password"
            font.pointSize: 36
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Input {
            id: txtConfirmPassword
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: Theme.padding
            anchors.leftMargin: Theme.padding
            anchors.left: parent.left
            anchors.right: parent.right
            placeholderText: "Confirm entered password"

            Component.onCompleted: {
                this.textField.echoMode = TextInput.Password
            }
            Keys.onReturnPressed: {
                btnFinish.clicked()
            }
        }

        MessageDialog {
            id: passwordsDontMatchError
            title: "Error"
            text: "Passwords don't match"
            icon: StandardIcon.Warning
            standardButtons: StandardButton.Ok
            onAccepted: {
                txtConfirmPassword.clear();
                swipeView.currentIndex = 1;
                txtPassword.focus = true;
            }
        }

        MessageDialog {
            id: storeAccountAndLoginError
            title: "Error storing account and logging in"
            text: "An error occurred while storing your account and logging in: "
            icon: StandardIcon.Critical
            standardButtons: StandardButton.Ok
        }

        Connections {
            target: onboardingModel
            ignoreUnknownSignals: true
            onLoginResponseChanged: {
              if(error){
                storeAccountAndLoginError.text += error;
                storeAccountAndLoginError.open()
              }
            }
        }

        StyledButton {
            id: btnFinish
            label: "Finish"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            onClicked: {
                if (txtConfirmPassword.textField.text != txtPassword.textField.text) {
                    return passwordsDontMatchError.open();
                }
                const selectedAccountIndex = wizardStep1.selectedIndex
                onboardingModel.storeAccountAndLogin(selectedAccountIndex, txtPassword.textField.text)
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/

