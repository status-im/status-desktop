import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../shared"
import "../../../../imports"

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
        text: `<a href="shareKey" style="color:${Style.current.blue};text-decoration:none;">Share your chat key</a> or <a href="invite" style="color:${Style.current.blue};text-decoration:none">invite</a> friends to start messaging in Status`
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
                case "shareKey": console.log('Go to share key'); break;
                case "invite": console.log('Go to invite'); break;
                default: //no idea what was clicked
            }
        }
    }
}
/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";formeditorZoom:2;height:480;width:640}
}
##^##*/
