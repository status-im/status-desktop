import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQml.Models 2.13

import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.panels 1.0
import "../../Chat/popups"

import "."

Item {
    id: contactListRoot

    property var contactsModel
    property int panelUsage: Constants.contactsPanelUsage.unknownPosition
    property int contactsListHeight: ((contactsList.count * contactsList.itemAtIndex(0).implicitHeight)+title.height)
    property bool scrollbarOn: false

    property string title: ""
    property string searchString: ""
    property string lowerCaseSearchString: searchString.toLowerCase()
    readonly property int count: contactsList.count

    signal contactClicked(string publicKey)
    signal openProfilePopup(string publicKey)
    signal sendMessageActionTriggered(string publicKey)
    signal showVerificationRequest(string publicKey)
    signal openChangeNicknamePopup(string publicKey)
    signal contactRequestAccepted(string publicKey)
    signal contactRequestRejected(string publicKey)
    signal rejectionRemoved(string publicKey)
    signal textClicked(string publicKey)

    visible: contactsList.count > 0

    StyledText {
        id: title
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        visible: contactListRoot.title !== ""
        text: contactListRoot.title
        font.weight: Font.Medium
        font.pixelSize: 15
        color: Style.current.secondaryText
    }

    DelegateModel {
        id: delegateModel

        function update() {
            var visible = [];
            for (var i = 0; i < items.count; ++i) {
                var item = items.get(i);
                if (panelUsage === Constants.contactsPanelUsage.verifiedMutualContacts) {
                    if(item.model.isVerified)
                        visible.push(item);
                }
                else if(panelUsage === Constants.contactsPanelUsage.mutualContacts) {
                    if(!item.model.isVerified)
                        visible.push(item);
                }
                else {
                    visible.push(item);
                }
            }

            for (i = 0; i < visible.length; ++i) {
                item = visible[i];
                item.inVisible = true;
                if (item.visibleIndex !== i) {
                    visibleItems.move(item.visibleIndex, i, 1);
                }
            }
        }

        model: contactListRoot.contactsModel

        groups: [DelegateModelGroup {
                id: visibleItems
                name: "visible"
                includeByDefault: false
            }]

        filterOnGroup: "visible"
        items.onChanged: update()
        delegate: contactPanelComponent
    }

    ListView {
        id: contactsList
        anchors.top: title.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        interactive: false
        clip: true
        ScrollBar.vertical: ScrollBar {
            policy: contactListRoot.scrollbarOn ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded
        }
        model: delegateModel
    }

    Component {
        id: contactPanelComponent

        ContactPanel {
            id: panelDelegate
            width: (parent.width-10)
            name: model.displayName
            publicKey: model.pubKey
            icon: model.icon
            isContact: model.isContact
            isBlocked: model.isBlocked
            isVerified: model.isVerified
            isUntrustworthy: model.isUntrustworthy
            verificationRequestStatus: model.incomingVerificationStatus

            searchStr: contactListRoot.searchString

            showSendMessageButton: model.isContact
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
            onOpenProfilePopup: contactListRoot.openProfilePopup(publicKey)
            onSendMessageActionTriggered: contactListRoot.sendMessageActionTriggered(publicKey)
            onOpenChangeNicknamePopup: contactListRoot.openChangeNicknamePopup(publicKey)
            onContactRequestAccepted: contactListRoot.contactRequestAccepted(publicKey)
            onContactRequestRejected: contactListRoot.contactRequestRejected(publicKey)
            onRejectionRemoved: contactListRoot.rejectionRemoved(publicKey)
            onTextClicked: contactListRoot.textClicked(publicKey)
            onShowVerificationRequest: contactListRoot.showVerificationRequest(publicKey)

            visible: searchString === "" ||
                     panelDelegate.name.toLowerCase().includes(lowerCaseSearchString) ||
                     panelDelegate.publicKey.toLowerCase().includes(lowerCaseSearchString)
        }
    }
}
