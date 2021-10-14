import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0
import "../../../../shared"
import "../../../../shared/popups"
import "../../../../shared/status"

import "../panels"
import "../stores"

// TODO: replace with StatusModal
ModalPopup {
    property var onAccountSelect: function () {}
    property var onOpenModalClick: function () {}
    id: popup
    //% "Your keys"
    title: qsTrId("your-keys")

    AccountListPanel {
        id: accountList
        anchors.fill: parent

        model: LoginStore.loginModelInst
        isSelected: function (index, keyUid) {
            return LoginStore.loginModelInst.currentAccount.keyUid === keyUid
        }

        onAccountSelect: function(index) {
            popup.onAccountSelect(index)
            popup.close()
        }
    }

    footer: StatusButton {
        anchors.bottom: parent.bottom
        anchors.topMargin: Style.current.padding
        anchors.right: parent.right
        //% "Add another existing key"
        text: qsTrId("add-another-existing-key")

        onClicked : {
           onOpenModalClick()
           popup.close()
        }
    }
}
