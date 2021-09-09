import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "../../Profile/Sections/Contacts"

ModalPopup {
    id: popup


    //% "Contact requests"
    title: qsTrId("contact-requests")

    ListView {
        id: contactList

        property Component profilePopupComponent: ProfilePopup {
            id: profilePopup
            onClosed: destroy()
        }

        anchors.fill: parent
        anchors.leftMargin: -Style.current.halfPadding
        anchors.rightMargin: -Style.current.halfPadding

        model: profileModel.contacts.contactRequests
        clip: true

        delegate: ContactRequest {
            name: Utils.removeStatusEns(model.name)
            address: model.address
            localNickname: model.localNickname
            identicon: model.thumbnailImage || model.identicon
            profileClick: function (showFooter, userName, fromAuthor, identicon, textParam, nickName) {
                var popup = profilePopupComponent.createObject(contactList);
                popup.openPopup(showFooter, userName, fromAuthor, identicon, textParam, nickName);
            }
            onBlockContactActionTriggered: {
                blockContactConfirmationDialog.contactName = name
                blockContactConfirmationDialog.contactAddress = address
                blockContactConfirmationDialog.open()
            }
        }
    }

    footer: Item {
        width: parent.width
        height: children[0].height

        BlockContactConfirmationDialog {
            id: blockContactConfirmationDialog
            onBlockButtonClicked: {
                profileModel.contacts.blockContact(blockContactConfirmationDialog.contactAddress)
                blockContactConfirmationDialog.close()
            }
        }

        ConfirmationDialog {
            id: declineAllDialog
            //% "Decline all contacts"
            header.title: qsTrId("decline-all-contacts")
            //% "Are you sure you want to decline all these contact requests"
            confirmationText: qsTrId("are-you-sure-you-want-to-decline-all-these-contact-requests")
            onConfirmButtonClicked: {
                const requests = profileModel.contacts.contactRequests
                const pubkeys = []
                for (let i = 0; i < requests.count; i++) {
                    pubkeys.push(requests.rowData(i, "address"))
                }
                profileModel.contacts.rejectContactRequests(JSON.stringify(pubkeys))
                declineAllDialog.close()
            }
        }

        ConfirmationDialog {
            id: acceptAllDialog
            //% "Accept all contacts"
            header.title: qsTrId("accept-all-contacts")
            //% "Are you sure you want to accept all these contact requests"
            confirmationText: qsTrId("are-you-sure-you-want-to-accept-all-these-contact-requests")
            onConfirmButtonClicked: {
                const requests = profileModel.contacts.contactRequests
                const pubkeys = []
                for (let i = 0; i < requests.count; i++) {
                    pubkeys.push(requests.rowData(i, "address"))
                }
                profileModel.contacts.acceptContactRequests(JSON.stringify(pubkeys))
                acceptAllDialog.close()
            }
        }

        StatusButton {
            id: blockBtn
            enabled: contactList.count > 0
            anchors.right: addToContactsButton.left
            anchors.rightMargin: Style.current.padding
            anchors.bottom: parent.bottom
            type: "warn"
            //% "Decline all"
            text: qsTrId("decline-all")
            onClicked: declineAllDialog.open()
        }

        StatusButton {
            id: addToContactsButton
            enabled: contactList.count > 0
            anchors.right: parent.right
            //% "Accept all"
            text: qsTrId("accept-all")
            anchors.bottom: parent.bottom
            onClicked: acceptAllDialog.open()
        }
    }
}
