import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3

import utils 1.0

import StatusQ.Popups 0.1
import StatusQ.Controls 0.1

import "../../../../../../shared/controls"

StatusModal {
    id: root
    //% "Select account"
    header.title: qsTrId("select-account")
    height: 284
    property alias accountSelector: selectFromAccount
    signal selectAndShareAddressButtonClicked()

    contentItem: Item {
        width: root.width
        height: childrenRect.height

        TransactionFormGroup {
          anchors.fill: parent
          anchors.leftMargin: Style.current.padding
          anchors.rightMargin: Style.current.padding
          StatusAccountSelector {
              id: selectFromAccount
              accounts: walletModel.accountsView.accounts
              currency: walletModel.balanceView.defaultCurrency
              width: parent.width
              //% "Choose account"
              //% "Select account to share and receive assets"
              label: qsTrId("select-account-to-share-and-receive-assets")
          }
        }
    }

    rightButtons: [
        StatusButton {
            //% "Confirm and share address"
            text: qsTrId("confirm-and-share-address")
            onClicked: root.selectAndShareAddressButtonClicked()
        }
    ]
}
