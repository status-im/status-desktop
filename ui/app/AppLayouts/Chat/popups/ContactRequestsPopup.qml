import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0

import StatusQ.Controls 0.1

import shared.popups 1.0

import "../panels"

// TODO: Replace with StatusModal
ModalPopup {
    id: popup

    property var store

    title: qsTr("Contact requests")

    ListView {
        id: contactList

        anchors.fill: parent
        anchors.leftMargin: -Style.current.halfPadding
        anchors.rightMargin: -Style.current.halfPadding

        model: popup.store.contactRequestsModel
        clip: true

        delegate: ContactRequestPanel {
            contactPubKey: model.pubKey
            contactName: model.displayName
            contactIcon: model.icon

            onOpenProfilePopup: {
                Global.openProfilePopup(model.pubKey)
            }
            onBlockContactActionTriggered: {
                blockContactConfirmationDialog.contactName = model.displayName
                blockContactConfirmationDialog.contactAddress = model.pubKey
                blockContactConfirmationDialog.open()
            }
            onAcceptClicked: {
                popup.store.acceptContactRequest(model.pubKey)
            }
            onDeclineClicked: {
                popup.store.dismissContactRequest(model.pubKey)
            }
        }
    }

    footer: Item {
        width: parent.width
        height: children[0].height

        BlockContactConfirmationDialog {
            id: blockContactConfirmationDialog
            onBlockButtonClicked: {
                popup.store.blockContact(blockContactConfirmationDialog.contactAddress)
                blockContactConfirmationDialog.close()
            }
        }

        ConfirmationDialog {
            id: declineAllDialog
            header.title: qsTr("Decline all contacts")
            confirmationText: qsTr("Are you sure you want to decline all these contact requests")
            onConfirmButtonClicked: {
                popup.store.dismissAllContactRequests()
                declineAllDialog.close()
                popup.close()
            }
        }

        ConfirmationDialog {
            id: acceptAllDialog
            header.title: qsTr("Accept all contacts")
            confirmationText: qsTr("Are you sure you want to accept all these contact requests")
            onConfirmButtonClicked: {
                popup.store.acceptAllContactRequests()
                acceptAllDialog.close()
                popup.close()
            }
        }

        StatusButton {
            id: blockBtn
            enabled: contactList.count > 0
            anchors.right: addToContactsButton.left
            anchors.rightMargin: Style.current.padding
            anchors.bottom: parent.bottom
            type: StatusBaseButton.Type.Danger
            text: qsTr("Decline all")
            onClicked: declineAllDialog.open()
        }

        StatusButton {
            id: addToContactsButton
            enabled: contactList.count > 0
            anchors.right: parent.right
            text: qsTr("Accept all")
            anchors.bottom: parent.bottom
            onClicked: acceptAllDialog.open()
        }
    }
}
