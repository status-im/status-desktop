import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../imports"
import "../../shared"

ModalPopup {
    property var onAccountSelect: function () {}
    property var onOpenModalClick: function () {}
    id: popup
    title: qsTr("Your keys")

    AccountList {
        id: accountList
        anchors.fill: parent

        accounts: loginModel
        isSelected: function (index, address) {
            return loginModel.currentAccount.address === address
        }

        onAccountSelect: function(index) {
            popup.onAccountSelect(index)
            popup.close()
        }
    }

    footer: StyledButton {
        anchors.bottom: parent.bottom
        anchors.topMargin: Style.current.padding
        anchors.right: parent.right
        label: qsTr("Add another existing key")

        onClicked : {
           onOpenModalClick()
           popup.close()
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:500;width:400}
}
##^##*/
