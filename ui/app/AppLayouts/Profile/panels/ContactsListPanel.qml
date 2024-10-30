import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import utils 1.0

import SortFilterProxyModel 0.2

Item {
    id: root
    implicitHeight: (title.height + contactsList.height)

    property var contactsModel

    property int panelUsage: Constants.contactsPanelUsage.unknownPosition

    property string title: ""
    property string searchString: ""
    readonly property int count: contactsList.count

    signal openContactContextMenu(string publicKey)
    signal sendMessageActionTriggered(string publicKey)
    signal showVerificationRequest(string publicKey)
    signal contactRequestAccepted(string publicKey)
    signal contactRequestRejected(string publicKey)
    signal rejectionRemoved(string publicKey)

    StyledText {
        id: title
        height: visible ? contentHeight : 0
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
        visible: contactsList.count > 0 && root.title !== ""
        text: root.title
        font.weight: Font.Medium
        font.pixelSize: 15
        color: Theme.palette.secondaryText
    }

    StatusListView {
        id: contactsList
        objectName: "ContactListPanel_ListView"
        anchors.top: title.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        onCountChanged: {
            height = (count*64);
        }
        interactive: false
        model: SortFilterProxyModel {
            id: filteredModel

            sourceModel: root.contactsModel

            function panelUsagePredicate(isVerified) {
                if (panelUsage === Constants.contactsPanelUsage.verifiedMutualContacts)
                    return isVerified
                if (panelUsage === Constants.contactsPanelUsage.mutualContacts)
                    return !isVerified

                return true
            }

            function searchPredicate(name, pubkey, compressedPubKey) {
                const lowerCaseSearchString = root.searchString.toLowerCase()

                return name.toLowerCase().includes(lowerCaseSearchString) ||
                       pubkey.toLowerCase().includes(lowerCaseSearchString) ||
                       compressedPubKey.toLowerCase().includes(lowerCaseSearchString)
            }

            filters: [
                FastExpressionFilter {
                    expression: filteredModel.panelUsagePredicate(model.isVerified)
                    expectedRoles: ["isVerified"]
                },
                FastExpressionFilter {
                    enabled: root.searchString !== ""
                    expression: {
                        root.searchString // ensure expression is reevaluated when searchString changes
                        return filteredModel.searchPredicate(model.displayName, model.pubKey, model.compressedPubKey)
                    }
                    expectedRoles: ["displayName", "pubKey", "compressedPubKey"]
                }
            ]

            sorters: StringSorter {
                roleName: "preferredDisplayName"
                caseSensitivity: Qt.CaseInsensitive
            }
        }

        delegate: ContactPanel {
            id: panelDelegate

            width: ListView.view.width
            name: model.preferredDisplayName
            iconSource: model.thumbnailImage

            subTitle: model.ensVerified ? "" : Utils.getElidedCompressedPk(model.pubKey)
            pubKeyColor: Utils.colorForPubkey(model.pubKey)
            colorHash: Utils.getColorHashAsJson(model.pubKey, model.ensVerified)

            showSendMessageButton: model.isContact && !model.isBlocked
            showRejectContactRequestButton: {
                if (root.panelUsage === Constants.contactsPanelUsage.receivedContactRequest
                        && !model.verificationRequestStatus)
                    return true

                return false
            }
            showAcceptContactRequestButton: {
                if (root.panelUsage === Constants.contactsPanelUsage.receivedContactRequest
                        && !model.verificationRequestStatus)
                    return true

                return false
            }
            showRemoveRejectionButton: {
                if (root.panelUsage === Constants.contactsPanelUsage.rejectedReceivedContactRequest)
                    return true

                return false
            }
            contactText: {
                if (root.panelUsage === Constants.contactsPanelUsage.sentContactRequest)
                    return qsTr("Contact Request Sent")

                if (root.panelUsage === Constants.contactsPanelUsage.rejectedSentContactRequest)
                    return qsTr("Contact Request Rejected")

                return ""
            }


            onContextMenuRequested: root.openContactContextMenu(model.pubKey)
            onSendMessageRequested: root.sendMessageActionTriggered(model.pubKey)
            onAcceptContactRequested: root.contactRequestAccepted(model.pubKey)
            onRejectRequestRequested: root.contactRequestRejected(model.pubKey)
            onRemoveRejectionRequested: root.rejectionRemoved(model.pubKey)
            onShowVerificationRequestRequested: root.showVerificationRequest(model.pubKey)
        }
    }
}
