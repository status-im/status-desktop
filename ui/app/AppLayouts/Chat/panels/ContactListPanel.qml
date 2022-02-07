import QtQuick 2.13
import QtQuick.Controls 2.3

import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0

ScrollView {
    id: contactListPanel

    property var chatContentModule
    property alias model: groupMembers.model
    property string searchString
    property bool selectMode: true
    property var onItemChecked

    property var isMember: function (pubkey) {
        return false
    }

    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: groupMembers.contentHeight > groupMembers.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

    ListView {
        id: groupMembers
        anchors.fill: parent
        spacing: 0
        clip: true
        delegate: StatusListItem {
            id: contactDelegate
            property bool isChecked: false
            title: !model.name.endsWith(".eth") && !!model.localNickname ?
                       model.localNickname : Utils.removeStatusEns(model.name)
            image.source: Global.getProfileImage(model.pubKey) || model.identicon
            image.isIdenticon: !!model.identicon
            visible: {
                if (selectMode) {
                    return (!searchString || model.name.toLowerCase().includes(searchString))
                            && !isMember(model.pubKey)
                }
                return checkbox.checked
            }
            components: [
                StatusCheckBox {
                    id: checkbox
                    visible: contactListPanel.selectMode && !isMember(model.pubKey)
                    checked: contactDelegate.isChecked
                    onClicked: {
                        contactDelegate.isChecked = !contactDelegate.isChecked
                        onItemChecked(model.pubKey, contactDelegate.isChecked)
                    }
                }
            ]
            onClicked: {
                contactDelegate.isChecked = !contactDelegate.isChecked
                onItemChecked(model.pubKey, contactDelegate.isChecked)
            }
        }
    }
}
