import QtQuick 2.15
import QtQuick.Controls 2.15

import utils 1.0

import StatusQ.Core.Theme 0.1
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
        anchors.topMargin: Theme.padding
        anchors.right: parent.right
        text: qsTr("Add another existing key")

        onClicked : {
           openModalClicked()
           root.close()
        }
    }
}
