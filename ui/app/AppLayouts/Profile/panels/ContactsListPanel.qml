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

    property string title: ""
    property string searchString: ""
    property string lowerCaseSearchString: searchString.toLowerCase()

    signal contactClicked(string publicKey)
    signal openProfilePopup(string publicKey)
    signal sendMessageActionTriggered(string publicKey)
    signal openChangeNicknamePopup(string publicKey)
    signal contactRequestAccepted(string publicKey)
    signal contactRequestRejected(string publicKey)
    signal rejectionRemoved(string publicKey)
    signal textClicked(string publicKey)

    visible: contactsList.count > 0

    StyledText {
        id: title
        anchors.top: parent.top
        anchors.left: parent.left
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
                    if(item.model.verificationState === Constants.contactVerificationState.verified)
                        visible.push(item);
                }
                else if (panelUsage === Constants.contactsPanelUsage.mutualContacts) {
                    if(item.model.verificationState !== Constants.contactVerificationState.verified)
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

        model: delegateModel
    }

    Component {
        id: contactPanelComponent

        ContactPanel {
            id: panelDelegate
            name: model.name
            publicKey: model.pubKey
            icon: model.icon
            isIdenticon: model.isIdenticon
            isMutualContact: model.isMutualContact
            isBlocked: model.isBlocked
            verificationState: model.verificationState

            searchStr: contactListRoot.searchString

            showSendMessageButton: model.isMutualContact
            showRejectContactRequestButton: {
                if (contactListRoot.panelUsage === Constants.contactsPanelUsage.receivedContactRequest) {
                    return true
                }

                return false
            }
            showAcceptContactRequestButton: {
                if (contactListRoot.panelUsage === Constants.contactsPanelUsage.receivedContactRequest) {
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

            visible: searchString === "" ||
                     panelDelegate.name.toLowerCase().includes(lowerCaseSearchString) ||
                     panelDelegate.publicKey.toLowerCase().includes(lowerCaseSearchString)
        }
    }
}
