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

    property var userAllowedDictionary: ({});
    property bool firstLoad: true

    signal userAllowedFetched(string pubkey, bool allowed)

    Timer {
        id: timer
    }

    function doFetch(chatId, pubkey) {
        const request = {
            type: "isUserAllowed",
            payload: [utilsModel.channelHash(chatId), utilsModel.derivedAnUserAddress(pubkey)]
        }
        ethersChannel.postMessage(request, (allowed) => {
                                      try {
                                          userAllowedDictionary[pubkey] = allowed;
                                          userAllowedFetched(pubkey, allowed)
                                      } catch (e) {
                                          // userAllowedDictionary is sometimes undefiend for no reason, even though we check above
                                      }
                                  });
    }

    function fetchUserAllowed(chatId, pubkey) {
        if (userAllowedDictionary[pubkey] !== undefined) {
            return userAllowedDictionary[pubkey];
        }

        userAllowedDictionary[pubkey] = Constants.fetching

        // FIXME use a signal for when the webview is ready instead
        if (firstLoad) {
            timer.setTimeout(function () {
                firstLoad = false
                doFetch(chatId, pubkey)
            }, 1000)
        } else {
            doFetch(chatId, pubkey)
        }



        return Constants.fetching
    }

    property var onActivated: function () {
        chatColumn.onActivated()
    }

    Connections {
        target: applicationWindow
        onSettingsLoaded: {
            // Add recent
            chatView.restoreState(appSettings.chatSplitView)
        }
    }
    Component.onDestruction: appSettings.chatSplitView = this.saveState()

    ContactsColumn {
        id: contactsColumn
        SplitView.preferredWidth: Style.current.leftTabPrefferedSize
        SplitView.minimumWidth: Style.current.leftTabMinimumWidth
        SplitView.maximumWidth: Style.current.leftTabMaximumWidth
    }

    ChatColumn {
        id: chatColumn
        chatGroupsListViewCount: contactsColumn.chatGroupsListViewCount
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
        height: 450
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
            if (profileModel.isAdded(chatColumn.contactToRemove)) {
              profileModel.removeContact(chatColumn.contactToRemove)
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
