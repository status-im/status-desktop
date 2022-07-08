import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import StatusQ.Controls 0.1

import shared.popups 1.0

import "../panels"
import "../stores"

// TODO: replace with StatusModal
ModalPopup {
    signal accountSelected(int index)
    signal openModalClicked()
    id: popup
    title: qsTr("Your keys")

    AccountListPanel {
        id: accountList
        anchors.fill: parent

        model: LoginStore.loginModuleInst.accountsModel
        isSelected: function (index, keyUid) {
            return LoginStore.currentAccount.keyUid === keyUid
        }

        onAccountSelect: function(index) {
            popup.accountSelected(index)
            popup.close()
        }
    }

    footer: StatusButton {
        anchors.bottom: parent.bottom
        anchors.topMargin: Style.current.padding
        anchors.right: parent.right
        text: qsTr("Add another existing key")

        onClicked : {
           openModalClicked()
           popup.close()
        }
    }
}
