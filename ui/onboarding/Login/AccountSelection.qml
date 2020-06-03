import QtQuick 2.3
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import QtQuick.Dialogs 1.3
import "../../shared"
import "../../imports"

Item {
    property alias btnGenKey: btnGenKey
//    property alias selectedIndex: selecte

    id: wizardStep1
    property int selectedIndex: 0
    Layout.fillHeight: true
    Layout.fillWidth: true

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

    AccountList {
        id: accountList
        accounts: loginModel
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
                loginModel.setCurrentAccount(accountList.selectedAccount)
                swipeView.incrementCurrentIndex()
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
