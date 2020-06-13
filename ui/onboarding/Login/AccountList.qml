import QtQuick 2.14
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "./samples/"
import "../../imports"

ListView {
    property var accounts: AccountsData {}
    property var isSelected: function () {}
    property var onAccountSelect: function () {}

    id: addressesView
    anchors.fill: parent
    model: accounts
    focus: true
    spacing: Theme.smallPadding

    delegate: AddressView {
        username: model.username
        address: model.address
        identicon: model.identicon
        isSelected: function (index, address) {
            return addressesView.isSelected(index, address)
        }
        onAccountSelect: function (index) {
            addressesView.onAccountSelect(index)
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

