import QtQuick 2.3
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import QtQuick.Dialogs 1.3

SwipeView {
    id: swipeView
    anchors.fill: parent
    currentIndex: 0

    // property string strGeneratedAccounts: onboardingLogic.generatedAddresses
    //  property var generatedAccounts: {}
    // signal storeAccountAndLoginResult(response: var)
    signal storeAccountAndLoginResult()

    onCurrentItemChanged: {
        currentItem.txtPassword.focus = true;
    }

    ListModel {
        id: generatedAccountsModel
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

//            Item {
//                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
//                transformOrigin: Item.Center
//                anchors.top: parent.top
//                anchors.topMargin: 50

            Row {
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: 10
                ButtonGroup {
                        id: accountGroup
                    }

                    Component {
                        id: addressViewDelegate

                        // Item {
                        //   id: addressViewContainer
                        //   height: 56
                        //   anchors.right: parent.right
                        //   anchors.rightMargin: 0
                        //   anchors.left: parent.left
                        //   anchors.leftMargin: 0

                        //   Text {
                        //     text: "address"
                        //     font.pointSize: 24
                        //     anchors.verticalCenter: parent.verticalCenter
                        //     font.pixelSize: 14
                        //     font.strikeout: false
                        //     anchors.left: parent.left
                        //     anchors.leftMargin: 72
                        //   }
                        // }

                        Item {
                            height: 56
                            // anchors.leftMargin: 20
                            // anchors.rightMargin: 20
                            anchors.right: parent.right
                            anchors.rightMargin: 0
                            anchors.left: parent.left
                            anchors.leftMargin: 0

//                            Text {
//                                id: keyValue
//                                text: key
//                                anchors.verticalCenter: parent.verticalCenter
//                                font.pixelSize: 14
//                                font.strikeout: false
//                                anchors.left: parent.left
//                                anchors.leftMargin: 72
//                            }

                             Row {
                               RadioButton {
                                 // checked: index == 0 ? true : false
                                 checked: false
                                 ButtonGroup.group: accountGroup
                                 // onClicked: {
                                   // wizardStep2.selectedIndex = index;
                                 // }
                               }
                               Column {
                                 Image {
                                   source: identicon
                                  //  source: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAAF0lEQVR42mPk+c9Qz0ACYBzVMKoBOwAA3IgShVgwlIUAAAAASUVORK5CYII="
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

//                        model: ListModel {
//                            ListElement {
//                                username: "Bill Smith"
//                                key: "0x123"
//                            }
//                            ListElement {
//                                username: "Slushy Welltodo Woodborer"
//                                key: "0x234"
//                            }
//                        }
                    }

                    // Repeater {
                    //   model: generatedAccountsModel
                    //   Rectangle {
                    //     height: 32
                    //     width: 32
                    //     anchors.leftMargin: 20
                    //     anchors.rightMargin: 20
                    //     Row {
                    //       RadioButton {
                    //         checked: index == 0 ? true : false
                    //         ButtonGroup.group: accountGroup
                    //         onClicked: {
                    //           wizardStep2.selectedIndex = index;
                    //         }
                    //       }
                    //       Column {
                    //         Image {
                    //           source: identicon
                    //         }
                    //       }
                    //       Column {
                    //         Text {
                    //           text: alias
                    //         }
                    //         Text {
                    //           text: publicKey
                    //           width: 160
                    //           elide: Text.ElideMiddle
                    //         }

                    //       }
                    //     }
                    //   }
                    // }

                }


//            }

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


            // icon: StandardIcon.Error
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

                const storeResponse = onboardingModel.storeAccountAndLogin(selectedAccountIndex, txtPassword.text)

                // const storeResponse = onboardingModel.storeAccountAndLogin(JSON.stringify(selectedAccount), txtPassword.text)

                // const selectedAccount = swipeView.generatedAccounts[wizardStep2.selectedIndex];
                // const storeResponse = onboardingModel.storeAccountAndLogin(JSON.stringify(selectedAccount), txtPassword.text)
                const response = JSON.parse(storeResponse);
                // if (response.error) {
                //     storeAccountAndLoginError.text += response.error;
                //     return storeAccountAndLoginError.open();
                // }
                console.log("=======");
                console.log(storeResponse);
                console.log("=======")
                // swipeView.storeAccountAndLoginResult(response);
                swipeView.storeAccountAndLoginResult();
            }
        }
    }

    // handle the serialised result coming from node and deserialise into JSON
    // TODO: maybe we should figure out a clever to avoid this?
    //  onStrGeneratedAccountsChanged: {
    //    if (generatedAccounts === null || generatedAccounts === "") {
    //      return;
    //    }
    //    swipeView.generatedAccounts = JSON.parse(strGeneratedAccounts);
    //  }

    // handle deserialised data coming from the node
    //  onGeneratedAccountsChanged: {
    // generatedAccountsModel.clear();
    // generatedAccounts.forEach(acc => {
    //   generatedAccountsModel.append({
    //     publicKey: acc.publicKey,
    //     alias: onboardingLogic.generateAlias(acc.publicKey),
    //     identicon: onboardingLogic.identicon(acc.publicKey)
    //   });
    // });
    //  }
}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
