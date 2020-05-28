import QtQuick 2.3
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import QtQuick.Dialogs 1.3

SwipeView {
    id: swipeView
    anchors.fill: parent
    currentIndex: 0

    property alias btnGenKey: btnGenKey

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
                text: "Login"
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
                    model: loginModel
                    delegate: addressViewDelegate
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    anchors.topMargin: 36
                    anchors.fill: parent
                }
            }

            Button {
                id: btnGenKey
                text: "Generate new account"
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
            }

            Button {
                text: "Select"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                onClicked: {
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

        MessageDialog {
            id: loginError
            title: "Login failed"
            text: "Login failed. Please re-enter your password and try again."
            icon: StandardIcon.Critical
            standardButtons: StandardButton.Ok
            onAccepted: {
                txtPassword.clear();
                txtPassword.focus = true
            }
        }

        Connections {
            target: loginModel
            onLoginResponseChanged: {
              const loginResponse = JSON.parse(response);
              if(loginResponse.error){
                loginError.open()
              }
            }
        }

        Button {
            text: "Finish"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            onClicked: {
              const selectedAccountIndex = wizardStep2.selectedIndex
              const response = loginModel.login(selectedAccountIndex, txtPassword.text)
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
