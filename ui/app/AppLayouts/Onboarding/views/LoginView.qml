import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1 as StatusQControls
import StatusQ.Popups 0.1

import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.controls 1.0
import shared.controls.chat 1.0
import "../panels"
import "../popups"
import "../stores"


import utils 1.0

Item {
    property bool loading: false
    signal addNewUserClicked()
    signal addExistingKeyClicked()

    id: loginView
    anchors.fill: parent

    function doLogin(password) {
        if (loading || password.length === 0)
            return

        loading = true
        LoginStore.login(password)
        txtPassword.textField.clear()
    }

    function resetLogin() {
        if(localAccountSettings.storeToKeychainValue === Constants.storeToKeychainValueStore)
        {
            connection.enabled = true
        }
        else
        {
            txtPassword.visible = true
            txtPassword.forceActiveFocus(Qt.MouseFocusReason)
        }
    }

    Component.onCompleted: {
        resetLogin()
    }

    Connections{
        id: connection
        target: LoginStore.loginModuleInst

        onObtainingPasswordError: {
            enabled = false
            obtainingPasswordErrorNotification.confirmationText = errorDescription
            obtainingPasswordErrorNotification.open()
        }

        onObtainingPasswordSuccess: {
            enabled = false
            doLogin(password)
        }
    }

    ConfirmationDialog {
        id: obtainingPasswordErrorNotification
        height: 270
        confirmButtonLabel: qsTr("Ok")

        onConfirmButtonClicked: {
            close()
        }

        onClosed: {
            txtPassword.visible = true
        }
    }

    Item {
        id: element
        width: 360
        height: childrenRect.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        Image {
            id: statusIcon
            width: 140
            height: 140
            fillMode: Image.PreserveAspectFit
            source: Style.png("status-logo")
            anchors.horizontalCenter: parent.horizontalCenter
        }

        StatusBaseText {
            id: welcomeBackText
            text: qsTr("Welcome back")
            font.weight: Font.Bold
            font.pixelSize: 17
            anchors.top: statusIcon.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.palette.directColor1
        }

        ConfirmAddExistingKeyModal {
            id: confirmAddExstingKeyModal
            onOpenModalClicked: {
                addExistingKeyClicked()
            }
        }

        SelectAnotherAccountModal {
            id: selectAnotherAccountModal
            onAccountSelected: {
                LoginStore.setCurrentAccount(index)
                resetLogin()
            }
            onOpenModalClicked: {
                addExistingKeyClicked()
            }
        }

        Item {
          id: userInfo
          height: userImage.height
          anchors.top: welcomeBackText.bottom
          anchors.topMargin: 64
          width: 318
          anchors.horizontalCenter: parent.horizontalCenter

          UserImage {
              id: userImage
              image: LoginStore.currentAccount.thumbnailImage
              name: LoginStore.currentAccount.username
              colorId: LoginStore.currentAccount.colorId
              colorHash: LoginStore.currentAccount.colorHash
              anchors.left: parent.left
          }

          StatusBaseText {
              id: usernameText
              text: LoginStore.currentAccount.username
              font.pixelSize: 17
              anchors.left: userImage.right
              anchors.leftMargin: 16
              anchors.verticalCenter: userImage.verticalCenter
              color: Theme.palette.directColor1
          }

          StatusQControls.StatusFlatRoundButton {
              icon.name: "chevron-down"
              type: StatusQControls.StatusFlatRoundButton.Type.Tertiary
              width: 24
              height: 24
              id: changeAccountBtn
              anchors.verticalCenter: usernameText.verticalCenter
              anchors.right: parent.right


              onClicked: {
                  if (accountsPopup.opened) {
                      accountsPopup.close()
                  } else {
                      accountsPopup.popup(width-userInfo.width-16, userInfo.height+4)
                  }
              }

              StatusPopupMenu {
                  id: accountsPopup
                  closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                  width: 346
                  dim: false
                  Repeater {
                      id: accounts
                      model: LoginStore.loginModuleInst.accountsModel
                      delegate: AccountMenuItemPanel {
                          label: model.username
                          image: model.thumbnailImage
                          colorId: model.colorId
                          colorHash: model.colorHash
                          onClicked: {
                              LoginStore.setCurrentAccount(index)
                              resetLogin()
                              accountsPopup.close()
                          }
                      }
                  }

                  AccountMenuItemPanel {
                    label: qsTr("Add new user")
                    onClicked: {
                      accountsPopup.close()
                      addNewUserClicked();
                    }
                  }

                  AccountMenuItemPanel {
                    label: qsTr("Add existing Status user")
                    iconSettings.name: "wallet"
                    onClicked: {
                      accountsPopup.close()
                      addExistingKeyClicked();
                    }
                  }
              }
          }
        }

        Input {
            id: txtPassword
            anchors.top: userInfo.bottom
            anchors.topMargin: Style.current.padding * 2
            anchors.left: undefined
            anchors.right: undefined
            anchors.horizontalCenter: parent.horizontalCenter
            width: 318
            enabled: !loading
            placeholderText: loading ?
                qsTr("Connecting...") :
                qsTr("Password")
            textField.echoMode: TextInput.Password
            Keys.onReturnPressed: {
                doLogin(textField.text)
            }
            onTextEdited: {
                errMsg.visible = false
                loading = false
            }
        }

        StatusQControls.StatusRoundButton {
            id: submitBtn
            width: 40
            height: 40
            type: StatusQControls.StatusRoundButton.Type.Secondary
            icon.name: "arrow-right"
            opacity: (loading || txtPassword.text.length > 0) ? 1 : 0
            anchors.left: txtPassword.right
            anchors.leftMargin: (loading || txtPassword.text.length > 0) ? Style.current.padding : Style.current.smallPadding
            anchors.verticalCenter: txtPassword.verticalCenter
            state: loading ? "pending" : "default"
            onClicked: {
                doLogin(txtPassword.textField.text)
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
            target: LoginStore.loginModuleInst
            onAccountLoginError: {
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

        StyledText {
            id: errMsg
            readonly property string incorrectPasswordMsg: qsTr("Password incorrect")
            anchors.top: txtPassword.bottom
            anchors.topMargin: Style.current.padding
            anchors.horizontalCenter: parent.horizontalCenter
            visible: false
            text: incorrectPasswordMsg
            font.pixelSize: 13
            color: Style.current.danger
        }
    }
}
