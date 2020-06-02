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
        currentItem.txtPassword.textField.focus = true;
    }


    Item {
        id: wizardStep1
        property Item txtPassword: txtMnemonic
        width: 620
        height: 427

        Text {
            id: title
            text: "Enter mnemonic"
            font.pointSize: 36
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Input {
            id: txtMnemonic
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: Theme.padding
            anchors.leftMargin: Theme.padding
            anchors.left: parent.left
            anchors.right: parent.right
            placeholderText: "Enter 12, 15, 21 or 24 words. Separate words by a single space."

            Keys.onReturnPressed: {
                btnImport.clicked()
            }
        }

        StyledButton {
            id: btnImport
            label: "Next"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.padding
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                onboardingModel.importMnemonic(txtMnemonic.textField.text);
                swipeView.incrementCurrentIndex();
            }
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
                  source: onboardingModel.importedAccount.identicon
                }
            }
            Column {
                Text {
                  text: onboardingModel.importedAccount.username
                }
                Text {
                  text: onboardingModel.importedAccount.address
                  width: 160
                  elide: Text.ElideMiddle
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
          id: step3Title
            text: "Confirm password"
            font.pointSize: 36
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: step3Title.bottom
            anchors.topMargin: 30
            Column {
                Image {
                  source: onboardingModel.importedAccount.identicon
                }
            }
            Column {
                Text {
                  text: onboardingModel.importedAccount.username
                }
                Text {
                  text: onboardingModel.importedAccount.address
                  width: 160
                  elide: Text.ElideMiddle
                }

            }
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
            id: importError
            title: "Error importing account"
            text: "An error occurred while importing your account: "
            icon: StandardIcon.Critical
            standardButtons: StandardButton.Ok
            onAccepted: {
                swipeView.currentIndex = 0
            }
        }

        MessageDialog {
            id: importLoginError
            title: "Login failed"
            text: "Login failed. Please re-enter your password and try again."
            icon: StandardIcon.Critical
            standardButtons: StandardButton.Ok
        }

        Connections {
            target: onboardingModel
            ignoreUnknownSignals: true
            onLoginResponseChanged: {
              if(error){
                importLoginError.open()
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
                const result = onboardingModel.storeDerivedAndLogin(txtConfirmPassword.textField.text);
                const error = JSON.parse(result).error;
                if (error) {
                    importError.text += error;
                    importError.open();
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

