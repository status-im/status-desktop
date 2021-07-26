import QtQuick 2.13
import QtQuick.Controls 2.13
import "./samples/"
import "../../imports"

ListView {
    property var accounts: AccountsData {}
    property var isSelected: function () {}
    property var onAccountSelect: function () {}

    id: accountsView
    anchors.fill: parent
    model: accounts
    focus: true
    spacing: Style.current.smallPadding
    clip: true

    delegate: AccountView {
        username: model.username
        identicon: model.thumbnailImage || model.identicon
        keyUid: model.keyUid
        address: model.address || ''
        isSelected: function (index, keyUid) {
            return accountsView.isSelected(index, keyUid)
        }
        onAccountSelect: function (index) {
            accountsView.onAccountSelect(index)
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
