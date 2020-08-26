import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "./"

ModalPopup {
    property string validationError: ""

    property string pubKey : "";
    property string ensUsername : "";
    
    function validate() {
        if (!Utils.isChatKey(chatKey.text) && !Utils.isValidETHNamePrefix(chatKey.text)) {
            validationError = "This needs to be a valid chat key or ENS username";
            ensUsername.text = "";
        } else {
            validationError = ""
        }
        return validationError === ""
    }

    property var resolveENS: Backpressure.debounce(popup, 500, function (ensName){
        chatsModel.resolveENS(ensName)
    });

    function onKeyReleased(){
        if (!validate()) {
            return;
        }

        chatKey.text = chatKey.text.trim();
        
        if(Utils.isChatKey(chatKey.text)){
            pubKey = chatKey.text;
            ensUsername.text = "";
            return;
        }
        
        Qt.callLater(resolveENS, chatKey.text)
    }

    function doJoin() {
        if (!validate() || pubKey.trim() === "") return;
        chatsModel.joinChat(pubKey, Constants.chatTypeOneToOne);
        popup.close();
    }

    id: popup
    //% "New chat"
    title: qsTrId("new-chat")

    onOpened: {
        chatKey.text = "";
        pubKey = "";
        ensUsername.text = "";
        chatKey.forceActiveFocus(Qt.MouseFocusReason)
        noContactsRect.visible = !profileModel.contactList.hasAddedContacts()
    }

    Input {
        id: chatKey
        //% "Enter ENS username or chat key"
        placeholderText: qsTrId("enter-contact-code")
        Keys.onEnterPressed: doJoin()
        Keys.onReturnPressed: doJoin()
        validationError: popup.validationError
        Keys.onReleased: {
            onKeyReleased();
        }

        Connections {
            target: chatsModel
            onEnsWasResolved: {
                if(chatKey.text == ""){
                    ensUsername.text == "";
                    pubKey = "";
                } else if(resolvedPubKey == ""){
                    ensUsername.text = qsTrId("user-not-found");
                    pubKey = "";
                } else {
                    ensUsername.text = chatsModel.formatENSUsername(chatKey.text) + " • " + Utils.compactAddress(resolvedPubKey, 4)
                    pubKey = resolvedPubKey;
                }
            }
        }
    }
    
    StyledText {
        id: ensUsername
        anchors.top: chatKey.bottom
        anchors.topMargin: Style.current.padding
        color: Style.current.darkGrey
        font.pixelSize: 12
    }

    Item {
        anchors.top: ensUsername.bottom
        anchors.topMargin: 90
        anchors.fill: parent

        ScrollView {
            anchors.fill: parent
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: contactListView.contentHeight > contactListView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

            ListView {
                anchors.fill: parent
                spacing: 0
                clip: true
                id: contactListView
                model: profileModel.contactList
                delegate: Contact {
                    showCheckbox: false
                    pubKey: model.pubKey
                    isContact: model.isContact
                    isUser: false
                    name: model.name
                    address: model.address
                    identicon: model.identicon
                    showListSelector: true
                    onItemChecked: function(pubKey, itemChecked){
                        chatsModel.joinChat(pubKey, Constants.chatTypeOneToOne);
                        popup.close()
                    }
                }
            }

            Rectangle {
                id: noContactsRect
                width: 260
                anchors.centerIn: parent
                StyledText {
                    id: noContacts
                    //% "You don’t have any contacts yet. Invite your friends to start chatting."
                    text: qsTrId("you-don-t-have-any-contacts-yet--invite-your-friends-to-start-chatting-")
                    color: Style.current.darkGrey
                    anchors.top: parent.top
                    anchors.topMargin: Style.current.padding
                    anchors.left: parent.left
                    anchors.right: parent.right
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
                StyledButton {
                    //% "Invite friends"
                    label: qsTrId("invite-friends")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: noContacts.bottom
                    anchors.topMargin: Style.current.xlPadding
                    onClicked: {
                        inviteFriendsPopup.open()
                    }
                }
                InviteFriendsPopup {
                    id: inviteFriendsPopup
                }
            }
        }
    }

    footer: Button {
        width: 44
        height: 44
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        SVGImage {
            source: pubKey === "" ? "../../../img/arrow-button-inactive.svg" : "../../../img/arrow-btn-active.svg"
            width: 50
            height: 50
        }
        background: Rectangle {
            color: "transparent"
        }
        MouseArea {
            id: btnMAnewChat
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked : doJoin()
        }
    }
}

/*##^##
Designer {
    D{i:0;height:300;width:300}
}
##^##*/
