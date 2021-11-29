import QtQuick 2.13
import QtQuick.Controls 2.3

import utils 1.0

import "../controls"

ScrollView {
    property alias model: groupMembers.model
    property string searchString
    property bool selectMode: true
    property var onItemChecked
    anchors.fill: parent

    id: root
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: groupMembers.contentHeight > groupMembers.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

    ListView {
        id: groupMembers
        anchors.fill: parent
        spacing: 0
        clip: true
        delegate: Contact {
            isVisible: {
                if (selectMode) {
                    return !searchString || model.name.toLowerCase().includes(searchString)
                }

                return isChecked || isUser
            }
            showCheckbox: root.selectMode
            pubKey: model.pubKey
            isContact: !!model.isContact
            isUser: model.isUser
            name: !model.name.endsWith(".eth") && !!model.localNickname ?
                      model.localNickname : Utils.removeStatusEns(model.name)
            address: model.address
            identicon: model.thumbnailImage || model.identicon
            onItemChecked: function (pubKey, itemChecked) {
                root.onItemChecked(pubKey, itemChecked)
            }
        }
    }
}
