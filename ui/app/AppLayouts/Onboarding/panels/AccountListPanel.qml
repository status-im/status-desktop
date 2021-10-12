import QtQuick 2.13
import QtQuick.Controls 2.13
import "./samples/"

import utils 1.0

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
        username: model.alias
        identicon: model.thumbnailImage || model.identicon
        keyUid: model.keyUid
        address: model.address || ''
        isSelected: function (accountId, keyUid) {
            return accountsView.isSelected(accountId, keyUid)
        }
        onAccountSelect: function (accountId) {
            accountsView.onAccountSelect(accountId)
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
