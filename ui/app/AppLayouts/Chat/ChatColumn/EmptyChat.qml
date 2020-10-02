import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../shared"
import "../../../../imports"
import "../components"

Item {
    id: element
    Layout.fillHeight: true
    Layout.fillWidth: true

    Image {
        id: walkieTalkieImage
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: "../../../../onboarding/img/chat@2x.jpg"
    }

    StyledText {
        //% "Share your chat key"
        text: `<a href="shareKey" style="color:${Style.current.blue};text-decoration:none;">${qsTrId("share-your-chat-key")}</a>` +
            //% "or"
            ` ${qsTrId("or")} ` +
            //% "invite"
            `<a href="invite" style="color:${Style.current.blue};text-decoration:none">${qsTrId("invite")}</a>`+
            //% "friends to start messaging in Status"
            ` ${qsTrId("friends-to-start-messaging-in-status")}`
        textFormat: Text.RichText
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        anchors.right: walkieTalkieImage.right
        anchors.left: walkieTalkieImage.left
        anchors.top: walkieTalkieImage.bottom
        font.pixelSize: 15
        color: Style.current.darkGrey
        onLinkActivated: function (linkClicked) {
            switch (linkClicked) {
                case "shareKey":
                    openProfilePopup(profileModel.profile.username, profileModel.profile.pubKey, profileModel.profile.identicon);
                    break;
                case "invite": inviteFriendsPopup.open(); break;
                default: //no idea what was clicked
            }
        }
    }

    InviteFriendsPopup {
        id: inviteFriendsPopup
    }
}
/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";formeditorZoom:2;height:480;width:640}
}
##^##*/
