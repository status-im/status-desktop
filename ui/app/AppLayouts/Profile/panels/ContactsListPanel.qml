import QtQuick 2.15

import StatusQ.Core 0.1

import shared 1.0
import utils 1.0

import SortFilterProxyModel 0.2

StatusListView {
    id: root

    required property var contactsModel
    property int panelUsage: Constants.contactsPanelUsage.unknownPosition
    property string searchString: ""

    signal openContactContextMenu(string publicKey)
    signal sendMessageActionTriggered(string publicKey)
    signal contactRequestAccepted(string publicKey)
    signal contactRequestRejected(string publicKey)

    objectName: "ContactListPanel_ListView"

    model: SortFilterProxyModel {
        id: filteredModel

        sourceModel: root.contactsModel

        filters: [
            UserSearchFilterContainer {
                searchString: root.searchString
            }
        ]

        sorters: [
            FilterSorter { // Trusted contacts first
                enabled: root.panelUsage === Constants.contactsPanelUsage.mutualContacts
                ValueFilter { roleName: "isVerified"; value: true }
            },
            FilterSorter { // Received CRs first
                id: pendingFilter
                readonly property int received: Constants.ContactRequestState.Received
                enabled: root.panelUsage === Constants.contactsPanelUsage.pendingContacts
                ValueFilter { roleName: "contactRequest"; value: pendingFilter.received }
            },
            StringSorter {
                roleName: "preferredDisplayName"
                caseSensitivity: Qt.CaseInsensitive
            }
        ]
    }

    delegate: ContactPanel {
        width: ListView.view.width

        showSendMessageButton: model.isContact && !model.isBlocked
        showRejectContactRequestButton: root.panelUsage === Constants.contactsPanelUsage.pendingContacts &&
                                        model.contactRequest === Constants.ContactRequestState.Received
        showAcceptContactRequestButton: showRejectContactRequestButton

        contactText: root.panelUsage === Constants.contactsPanelUsage.pendingContacts &&
                     model.contactRequest === Constants.ContactRequestState.Sent ? qsTr("Contact Request Sent")
                                                                                 : ""

        onClicked: Global.openProfilePopup(model.pubKey)
        onContextMenuRequested: root.openContactContextMenu(model.pubKey)
        onSendMessageRequested: root.sendMessageActionTriggered(model.pubKey)
        onAcceptContactRequested: root.contactRequestAccepted(model.pubKey)
        onRejectRequestRequested: root.contactRequestRejected(model.pubKey)
    }
}
