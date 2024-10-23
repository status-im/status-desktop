import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.panels 1.0

import "../../Chat/popups"

import AppLayouts.Profile.stores 1.0

import SortFilterProxyModel 0.2

Item {
    id: root
    implicitHeight: (title.height + contactsList.height)

    property ContactsStore contactsStore
    property var contactsModel

    property int panelUsage: Constants.contactsPanelUsage.unknownPosition

    property string title: ""
    property string searchString: ""
    readonly property int count: contactsList.count

    signal openContactContextMenu(string publicKey, string name, string icon)
    signal contactClicked(string publicKey)
    signal sendMessageActionTriggered(string publicKey)
    signal showVerificationRequest(string publicKey)
    signal contactRequestAccepted(string publicKey)
    signal contactRequestRejected(string publicKey)
    signal rejectionRemoved(string publicKey)
    signal textClicked(string publicKey)

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
                if (panelUsage === Constants.contactsPanelUsage.verifiedMutualContacts) return isVerified
                if (panelUsage === Constants.contactsPanelUsage.mutualContacts) return !isVerified
                return true
            }

            function searchPredicate(name, pubkey) {
                const lowerCaseSearchString = root.searchString.toLowerCase()
                const compressedPubkey = Utils.getCompressedPk(pubkey)

                return name.toLowerCase().includes(lowerCaseSearchString) ||
                       pubkey.toLowerCase().includes(lowerCaseSearchString) ||
                       compressedPubkey.toLowerCase().includes(lowerCaseSearchString)
            }

            filters: [
                ExpressionFilter { expression: filteredModel.panelUsagePredicate(model.isVerified) },
                ExpressionFilter {
                    enabled: root.searchString !== ""
                    expression: {
                        root.searchString // ensure expression is reevaluated when searchString changes
                        return filteredModel.searchPredicate(model.displayName, model.pubKey)
                    }
                }
            ]

            sorters: [
                StringSorter {
                    roleName: "preferredDisplayName"
                    caseSensitivity: Qt.CaseInsensitive
                }
            ]
        }

        delegate: ContactPanel {
            id: panelDelegate

            width: ListView.view.width
            contactsStore: root.contactsStore
            name: model.preferredDisplayName
            ensVerified: model.isEnsVerified
            publicKey: model.pubKey
            compressedPk: Utils.getCompressedPk(model.pubKey)
            iconSource: model.icon
            isContact: model.isContact
            isBlocked: model.isBlocked
            isVerified: model.isVerified
            isUntrustworthy: model.isUntrustworthy

            showSendMessageButton: isContact && !isBlocked
            onOpenContactContextMenu: function (publicKey, name, icon) {
                root.openContactContextMenu(publicKey, name, icon)
            }
            showRejectContactRequestButton: {
                if (root.panelUsage === Constants.contactsPanelUsage.receivedContactRequest && !model.verificationRequestStatus) {
                    return true
                }

                return false
            }
            showAcceptContactRequestButton: {
                if (root.panelUsage === Constants.contactsPanelUsage.receivedContactRequest && !model.verificationRequestStatus) {
                    return true
                }

                return false
            }
            showRemoveRejectionButton: {
                if (root.panelUsage === Constants.contactsPanelUsage.rejectedReceivedContactRequest) {
                    return true
                }

                return false
            }
            contactText: {
                if (root.panelUsage === Constants.contactsPanelUsage.sentContactRequest) {
                    return qsTr("Contact Request Sent")
                }
                else if (root.panelUsage === Constants.contactsPanelUsage.rejectedSentContactRequest) {
                    return qsTr("Contact Request Rejected")
                }

                return ""
            }
            contactTextClickable: {
                return false
            }

            onClicked: root.contactClicked(model.pubKey)
            onSendMessageActionTriggered: root.sendMessageActionTriggered(publicKey)
            onContactRequestAccepted: root.contactRequestAccepted(publicKey)
            onContactRequestRejected: root.contactRequestRejected(publicKey)
            onRejectionRemoved: root.rejectionRemoved(publicKey)
            onTextClicked: root.textClicked(publicKey)
            onShowVerificationRequest: root.showVerificationRequest(publicKey)
        }
    }
}
