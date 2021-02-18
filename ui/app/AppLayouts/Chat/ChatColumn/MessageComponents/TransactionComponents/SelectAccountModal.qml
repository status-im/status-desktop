import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Dialogs 1.3
import "../../../../../../imports"
import "../../../../../../shared"
import "../../../../../../shared/status"

ModalPopup {
    id: root
    //% "Select account"
    title: qsTrId("select-account")
    height: 284
    property alias accountSelector: selectFromAccount
    signal selectAndShareAddressButtonClicked()

    TransactionFormGroup {
      anchors.fill: parent
      anchors.leftMargin: Style.current.padding
      anchors.rightMargin: Style.current.padding
      AccountSelector {
          id: selectFromAccount
          accounts: walletModel.accounts
          currency: walletModel.defaultCurrency
          width: parent.width
          //% "Choose account"
          //% "Select account to share and receive assets"
          label: qsTrId("select-account-to-share-and-receive-assets")
      }
    }

    footer: Item {
        id: footerContainer
        width: parent.width
        height: children[0].height

        StatusButton {
            anchors.right: parent.right
            anchors.rightMargin: Style.current.smallPadding
            //% "Confirm and share address"
            text: qsTrId("confirm-and-share-address")
            anchors.bottom: parent.bottom
            onClicked: root.selectAndShareAddressButtonClicked()
        }
    }
}
