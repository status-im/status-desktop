import QtQuick 2.15

import StatusQ.Core 0.1

import shared.views 1.0
import utils 1.0

StatusListView {
    id: root

    property bool inviteButtonVisible

    signal profilePopupRequested(string publicKey)
    signal contextMenuRequested(string publicKey)

    signal sendMessageRequested(string publicKey)
    signal acceptContactRequested(string publicKey)
    signal rejectContactRequested(string publicKey)
    signal rejectionRemoved(string publicKey)

    objectName: "ContactListPanel_ListView"

    header: NoFriendsRectangle {
        width: ListView.view.width
        visible: ListView.view.count === 0
        inviteButtonVisible: root.inviteButtonVisible
    }

    delegate: ContactPanel {
        width: ListView.view.width

        showSendMessageButton: model.isContact && !model.isBlocked
        showRejectContactRequestButton:
            model.contactRequest === Constants.ContactRequestState.Received
        showAcceptContactRequestButton: showRejectContactRequestButton
        showRemoveRejectionButton: model.contactRequest === Constants.ContactRequestState.Dismissed

        contactText: model.contactRequest === Constants.ContactRequestState.Sent
                     ? qsTr("Contact Request Sent") : ""

        onClicked: root.profilePopupRequested(model.pubKey)
        onContextMenuRequested: root.contextMenuRequested(model.pubKey)
        onSendMessageRequested: root.sendMessageRequested(model.pubKey)
        onAcceptContactRequested: root.acceptContactRequested(model.pubKey)
        onRejectRequestRequested: root.rejectContactRequested(model.pubKey)
        onRemoveRejectionRequested: root.rejectionRemoved(model.pubKey)
    }
}
