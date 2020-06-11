import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../../imports"
import "../../shared"

ModalPopup {
    property var onAccountSelect: function () {}
    id: popup
    title: qsTr("Your accounts")

    AccountList {
        id: accountList
        anchors.fill: parent

        accounts: loginModel
        onAccountSelect: function(index) {
            popup.onAccountSelect(index)
            popup.close()
        }
    }


    footer: StyledButton {
        anchors.top: parent.top
        anchors.topMargin: Theme.padding
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        label: "Add another existing key"

        onClicked : {
           console.log('Open other popup for seed')
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:500;width:400}
}
##^##*/
