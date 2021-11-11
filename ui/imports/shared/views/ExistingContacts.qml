import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared.status 1.0
// TODO move Contact into shared to get rid of that import
import "../../../app/AppLayouts/Chat/controls"

Item {
    id: root
    anchors.left: parent.left
    anchors.right: parent.right
    property string filterText: ""
    property bool expanded: true
    property bool showCheckbox: false
    property bool hideCommunityMembers: false
    property var pubKeys: ([])
    signal contactClicked(var contact)

    function matchesAlias(name, filter) {
        let parts = name.split(" ")
        return parts.some(p => p.startsWith(filter))
    }

    height: Math.min(contactListView.contentHeight, (expanded ? 320 : 192))

    ScrollView {
        anchors.fill: parent

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: contactListView.contentHeight > contactListView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

        ListView {
            anchors.fill: parent
            spacing: 0
            clip: true
            id: contactListView
            model: contactsModule.model.list
            delegate: Contact {
                showCheckbox: root.showCheckbox
                isChecked: root.pubKeys.indexOf(model.pubKey) > -1
                pubKey: model.pubKey
                isContact: model.isContact
                isUser: false
                name: model.name
                address: model.address
                identicon: model.thumbnailImage || model.identicon
                visible: model.isContact && !model.isBlocked && (root.filterText === "" ||
                    root.matchesAlias(model.name.toLowerCase(), root.filterText.toLowerCase()) ||
                    model.name.toLowerCase().includes(root.filterText.toLowerCase()) ||
                    model.address.toLowerCase().includes(root.filterText.toLowerCase())) &&
                    (!root.hideCommunityMembers || !chatsModel.communities.activeCommunity.hasMember(model.pubKey))
                onContactClicked: function () {
                    root.contactClicked(model)
                }
            }
        }
    }
}


