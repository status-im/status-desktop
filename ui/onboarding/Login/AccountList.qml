import QtQuick 2.14
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "./samples/"

ListView {
    property var accounts: AccountsData {}
    property var onAccountSelect: function() {}

    id: addressesView
    anchors.right: parent.right
    anchors.rightMargin: 0
    anchors.left: parent.left
    anchors.leftMargin: 0
    anchors.bottom: footer.top
    anchors.bottomMargin: 0
    anchors.top: title.bottom
    anchors.topMargin: 16
    contentWidth: 200
    height: parent.height
    model: accounts

    delegate: AddressView {
      username: model.username
      identicon: model.identicon
      onAccountSelect: function(index) {
        addressesView.onAccountSelect(index)
      }
    }

    Layout.fillHeight: true
    Layout.fillWidth: true
    focus: true
}

