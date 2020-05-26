import QtQuick 2.3
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import QtQuick.Dialogs 1.3

SwipeView {
    id: swipeView
    anchors.fill: parent
    currentIndex: 0

    signal loginDone()

    onCurrentItemChanged: {
        currentItem.txtPassword.focus = true;
    }

    Item {
        id: wizardStep2
        property int selectedIndex: 0

        ColumnLayout {
            id: columnLayout
            width: 620
            height: 427

            Text {
                text: "Generated accounts"
                font.pointSize: 36
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.horizontalCenter: parent.horizontalCenter
            }

            RowLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: 10
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
                                   wizardStep2.selectedIndex = index;
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
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        anchors.topMargin: 36
                        anchors.fill: parent
                    }
                }

            Button {
                text: "Select"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                onClicked: {
                    console.log("button: " + wizardStep2.selectedIndex);

                    swipeView.incrementCurrentIndex();
                }
            }

        }
    }

    Item {
        id: wizardStep3
        property Item txtPassword: txtPassword

        Text {
            text: "Enter password"
            font.pointSize: 36
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            color: "#EEEEEE"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.centerIn: parent
            height: 32
            width: parent.width - 40
            TextInput {
                id: txtPassword
                anchors.fill: parent
                focus: true
                echoMode: TextInput.Password
                selectByMouse: true
            }
        }

        Button {
            text: "Next"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            onClicked: {
                console.log("password: " + txtPassword.text);

                swipeView.incrementCurrentIndex();
            }
        }
    }

    Item {
        id: wizardStep4
        property Item txtPassword: txtConfirmPassword

        Text {
            text: "Confirm password"
            font.pointSize: 36
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            color: "#EEEEEE"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.centerIn: parent
            height: 32
            width: parent.width - 40

            TextInput {
                id: txtConfirmPassword
                anchors.fill: parent
                focus: true
                echoMode: TextInput.Password
                selectByMouse: true
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
                swipeView.currentIndex = 1
                txtPassword.focus = true
            }
        }

        MessageDialog {
            id: storeAccountAndLoginError
            title: "Error storing account and logging in"
            text: "An error occurred while storing your account and logging in: "
            icon: StandardIcon.Warning
            standardButtons: StandardButton.Ok
        }

        Button {
            text: "Finish"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            onClicked: {
                console.log("confirm clicked " + txtConfirmPassword.text + " : " + txtPassword.text);

                if (txtConfirmPassword.text != txtPassword.text) {
                  return passwordsDontMatchError.open();
                }

                const selectedAccountIndex = wizardStep2.selectedIndex
                onboardingModel.storeAccountAndLogin(selectedAccountIndex, txtPassword.text)

               swipeView.loginDone();
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
