import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import StatusQ.Controls 0.1

import shared.popups 1.0

import "../panels"
import "../stores"

// TODO: replace with StatusModal
ModalPopup {
    id: root

    property StartupStore startupStore

    signal accountSelected(int index)
    signal openModalClicked()

    title: qsTr("Your keys")

    AccountListPanel {
        id: accountList
        anchors.fill: parent

        model: root.startupStore.startupModuleInst.loginAccountsModel
        isSelected: function (index, keyUid) {
            return root.startupStore.selectedLoginAccount.keyUid === keyUid
        }

        onAccountSelect: function(index) {
            root.accountSelected(index)
            root.close()
        }
    }

    footer: StatusButton {
        anchors.bottom: parent.bottom
        anchors.topMargin: Style.current.padding
        anchors.right: parent.right
        text: qsTr("Add another existing key")

        onClicked : {
           openModalClicked()
           root.close()
        }
    }
}
