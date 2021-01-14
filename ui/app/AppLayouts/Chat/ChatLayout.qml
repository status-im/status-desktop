import QtQuick 2.13
import QtQuick.Controls 2.13
import Qt.labs.settings 1.0
import "../../../imports"
import "../../../shared"
import "."
import "components"

SplitView {
    id: chatView
    handle: SplitViewHandle {}

    property alias chatColumn: chatColumn

    property var onActivated: function () {
        chatsModel.restorePreviousActiveChannel()
        chatColumn.onActivated()
    }

    function openPopup(popupComponent, params = {}) {
        const popup = popupComponent.createObject(chatView, params);
        popup.open()
        return popup
    }

    function getContactListObject(dataModel) {
        const nbContacts = profileModel.contacts.list.rowCount()
        const contacts = []
        let contact
        for (let i = 0; i < nbContacts; i++) {
            contact = {
                name: profileModel.contacts.list.rowData(i, "name"),
                localNickname: profileModel.contacts.list.rowData(i, "localNickname"),
                pubKey: profileModel.contacts.list.rowData(i, "pubKey"),
                address: profileModel.contacts.list.rowData(i, "address"),
                identicon: profileModel.contacts.list.rowData(i, "identicon"),
                thumbnailImage: profileModel.contacts.list.rowData(i, "thumbnailImage"),
                isUser: false,
                isContact: profileModel.contacts.list.rowData(i, "isContact") !== "false"
            }

            contacts.push(contact)
            if (dataModel) {
                dataModel.append(contact);
            }
        }
        return contacts
    }

    Connections {
        target: applicationWindow
        onSettingsLoaded: {
            // Add recent
            chatView.restoreState(appSettings.chatSplitView)
        }
    }
    Component.onDestruction: appSettings.chatSplitView = this.saveState()

    Loader {
        id: contactColumnLoader
        SplitView.preferredWidth: Style.current.leftTabPrefferedSize
        SplitView.minimumWidth: Style.current.leftTabMinimumWidth
        SplitView.maximumWidth: Style.current.leftTabMaximumWidth
        sourceComponent: appSettings.communitiesEnabled && chatsModel.activeCommunity.active ? communtiyColumnComponent : contactsColumnComponent
    }

    Component {
        id: contactsColumnComponent
        ContactsColumn {
        }
    }

    Component {
        id: communtiyColumnComponent
        CommunityColumn {}
    }

    ChatColumn {
        id: chatColumn
        chatGroupsListViewCount: contactColumnLoader.item.chatGroupsListViewCount
    }

    function openProfilePopup(userNameParam, fromAuthorParam, identiconParam, textParam, nicknameParam, parentPopup){
        var popup = profilePopupComponent.createObject(chatView);
        if(parentPopup){
            popup.parentPopup = parentPopup;
        }
        popup.openPopup(profileModel.profile.pubKey !== fromAuthorParam, userNameParam, fromAuthorParam, identiconParam, textParam, nicknameParam);
    }

    property Component profilePopupComponent: ProfilePopup {
        id: profilePopup
        height: 504
        onClosed: {
            if(profilePopup.parentPopup){
                profilePopup.parentPopup.close();
            }
            destroy()
        }
    }


    ConfirmationDialog {
        id: removeContactConfirmationDialog
        // % "Remove contact"
        title: qsTrId("remove-contact")
        //% "Are you sure you want to remove this contact?"
        confirmationText: qsTrId("are-you-sure-you-want-to-remove-this-contact-")
        onConfirmButtonClicked: {
            if (profileModel.contacts.isAdded(chatColumn.contactToRemove)) {
              profileModel.contacts.removeContact(chatColumn.contactToRemove)
            }
            removeContactConfirmationDialog.parentPopup.close();
            removeContactConfirmationDialog.close();
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.25;height:770;width:1152}
}
##^##*/
