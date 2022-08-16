import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQml.Models 2.13

import StatusQ.Core 0.1

import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.panels 1.0

import "../../Chat/popups"
import "."

import SortFilterProxyModel 0.2

Item {
    id: contactListRoot

    property var contactsStore
    property var contactsModel
    property int panelUsage: Constants.contactsPanelUsage.unknownPosition
    property bool scrollbarOn: false
    readonly property int contactsListHeight: ((contactsList.count * contactsList.itemAtIndex(0).implicitHeight)+title.height)

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
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        visible: contactsList.count > 0 && contactListRoot.title !== ""
        text: contactListRoot.title
        font.weight: Font.Medium
        font.pixelSize: 15
        color: Style.current.secondaryText
    }

    StatusListView {
        id: contactsList
        anchors.top: title.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        interactive: false
        ScrollBar.vertical.policy: contactListRoot.scrollbarOn ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded
        model: SortFilterProxyModel {
            id: filteredModel

            sourceModel: contactListRoot.contactsModel

            function panelUsagePredicate(isVerified) {
                if (panelUsage === Constants.contactsPanelUsage.verifiedMutualContacts) return isVerified
                if (panelUsage === Constants.contactsPanelUsage.mutualContacts) return !isVerified
                return true
            }

            function searchPredicate(name, pubkey) {
                if (contactListRoot.searchString === "") return true

                let lowerCaseSearchString = contactListRoot.searchString.toLowerCase()
                let compressedPubkey = Utils.getCompressedPk(pubkey)

                return name.toLowerCase().includes(lowerCaseSearchString) ||
                       pubkey.toLowerCase().includes(lowerCaseSearchString) ||
                       compressedPubkey.toLowerCase().includes(lowerCaseSearchString)
            }

            filters: [
                ExpressionFilter { expression: filteredModel.panelUsagePredicate(model.isVerified) },
                ExpressionFilter {
                    expression: {
                        contactListRoot.searchString // ensure expression is reevaluated when searchString changes
                        filteredModel.searchPredicate(model.displayName, model.pubKey)
                    }
                }
            ]
        }

        delegate: ContactPanel {
            id: panelDelegate
            width: ListView.view.width
            contactsStore: contactListRoot.contactsStore
            name: model.displayName
            publicKey: model.pubKey
            iconSource: model.icon
            isContact: model.isContact
            isBlocked: model.isBlocked
            isVerified: model.isVerified
            isUntrustworthy: model.isUntrustworthy
            verificationRequestStatus: model.incomingVerificationStatus

            showSendMessageButton: isContact && !isBlocked
            onOpenContactContextMenu: function (publicKey, name, icon) {
                contactListRoot.openContactContextMenu(publicKey, name, icon)
            }
            showRejectContactRequestButton: {
                if (contactListRoot.panelUsage === Constants.contactsPanelUsage.receivedContactRequest && !model.verificationRequestStatus) {
                    return true
                }

                return false
            }
            showAcceptContactRequestButton: {
                if (contactListRoot.panelUsage === Constants.contactsPanelUsage.receivedContactRequest && !model.verificationRequestStatus) {
                    return true
                }

                return false
            }
            showRemoveRejectionButton: {
                if (contactListRoot.panelUsage === Constants.contactsPanelUsage.rejectedReceivedContactRequest) {
                    return true
                }

                return false
            }
            contactText: {
                if (contactListRoot.panelUsage === Constants.contactsPanelUsage.sentContactRequest) {
                    return qsTr("Contact Request Sent")
                }
                else if (contactListRoot.panelUsage === Constants.contactsPanelUsage.rejectedSentContactRequest) {
                    return qsTr("Contact Request Rejected")
                }

                return ""
            }
            contactTextClickable: {
                return false
            }

            onClicked: contactListRoot.contactClicked(model.pubKey)
            onSendMessageActionTriggered: contactListRoot.sendMessageActionTriggered(publicKey)
            onContactRequestAccepted: contactListRoot.contactRequestAccepted(publicKey)
            onContactRequestRejected: contactListRoot.contactRequestRejected(publicKey)
            onRejectionRemoved: contactListRoot.rejectionRemoved(publicKey)
            onTextClicked: contactListRoot.textClicked(publicKey)
            onShowVerificationRequest: contactListRoot.showVerificationRequest(publicKey)
        }
    }
}
