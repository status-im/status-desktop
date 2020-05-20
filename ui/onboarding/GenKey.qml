import QtQuick 2.3
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import QtQuick.Dialogs 1.3

SwipeView {
  id: swipeView
  anchors.fill: parent
  currentIndex: 0

  property string strGeneratedAccounts: onboardingLogic.generatedAddresses
  property var generatedAccounts: {}
  signal storeAccountAndLoginResult(response: var)

  onCurrentItemChanged: {
    currentItem.txtPassword.focus = true;
  }

  ListModel {
    id: generatedAccountsModel
  }

  Item {
    id: wizardStep2
    property int selectedIndex: 0

    Text {
      text: "Generated accounts"
      font.pointSize: 36
      anchors.top: parent.top
      anchors.topMargin: 20
      anchors.horizontalCenter: parent.horizontalCenter
    }

    Item {
      anchors.top: parent.top
      anchors.topMargin: 50

      Column {
        spacing: 10
        ButtonGroup {
          id: accountGroup
        }

        Repeater {
          model: generatedAccountsModel
          Rectangle {
            height: 32
            width: 32
            anchors.leftMargin: 20
            anchors.rightMargin: 20
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
                  text: alias
                }
                Text {
                  text: publicKey
                  width: 160
                  elide: Text.ElideMiddle
                }

              }
            }
          }
        }
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
      icon: StandardIcon.Error
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

        const selectedAccount = swipeView.generatedAccounts[wizardStep2.selectedIndex];
        const storeResponse = onboardingModel.storeAccountAndLogin(JSON.stringify(selectedAccount), txtPassword.text)
        const response = JSON.parse(storeResponse);
        if (response.error) {
          storeAccountAndLoginError.text += response.error;
          return storeAccountAndLoginError.open();
        }
        swipeView.storeAccountAndLoginResult(response);
      }
    }
  }

  // handle the serialised result coming from node and deserialise into JSON
  // TODO: maybe we should figure out a clever to avoid this?
  onStrGeneratedAccountsChanged: {
    if (generatedAccounts === null || generatedAccounts === "") {
      return;
    }
    swipeView.generatedAccounts = JSON.parse(strGeneratedAccounts);
  }

  // handle deserialised data coming from the node
  onGeneratedAccountsChanged: {
    generatedAccountsModel.clear();
    generatedAccounts.forEach(acc => {
      generatedAccountsModel.append({
        publicKey: acc.publicKey,
        alias: onboardingLogic.generateAlias(acc.publicKey),
        identicon: onboardingLogic.identicon(acc.publicKey)
      });
    });
  }
}
/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

