import QtQuick 2.13
import QtQuick.Controls 2.3

import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0

ScrollView {
    id: contactListPanel

    property alias model: groupMembers.model
    property string searchString
    property bool selectMode: true
    property var onItemChecked

    property var selectedPubKeys: []

    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: groupMembers.contentHeight > groupMembers.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff


    ListView {
        id: groupMembers
        anchors.fill: parent
        spacing: 0
        clip: true
        delegate: StatusListItem {
            id: contactDelegate
            property bool isChecked: selectedPubKeys.indexOf(model.pubKey) !== -1
            title: !model.name.endsWith(".eth") && !!model.localNickname ?
                       model.localNickname : Utils.removeStatusEns(model.name)
            image.source: Global.getProfileImage(model.pubKey) || model.identicon
            image.isIdenticon: !!model.identicon
            visible: {
                if (selectMode) {
                    return !searchString || model.name.toLowerCase().includes(searchString)
                }
                return checkbox.checked
            }

            height: visible ? implicitHeight : 0

            function contactToggled(pubKey) {
                if (contactListPanel.selectMode) {
                    let pubkeys = contactListPanel.selectedPubKeys
                    let idx = pubkeys.indexOf(pubKey)
                    if (idx === -1) {
                        pubkeys.push(pubKey)
                    } else if (idx > -1) {
                        pubkeys.splice(idx, 1);
                    }
                    contactListPanel.selectedPubKeys = pubkeys
                }
            }

            components: [
                StatusCheckBox {
                    id: checkbox
                    visible: contactListPanel.selectMode
                    checked: selectedPubKeys.indexOf(model.pubKey) !== -1
                    onClicked: {
                        contactDelegate.contactToggled(model.pubKey)
                    }
                }
            ]
            onClicked: {
                contactDelegate.contactToggled(model.pubKey)
            }
        }
    }
}
