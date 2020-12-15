import QtQuick 2.12
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "../ContactsColumn"

ModalPopup {
    property QtObject community: chatsModel.activeCommunity
    property string communityId: community.id
    property string name: community.name
    property string description: community.description
    property int access: community.access
    // TODO get the real image once it's available
    property string source: "../../../img/ens-header-dark@2x.png"
    property int nbMembers: community.nbMembers

    id: popup

    header: Item {
        height: childrenRect.height
        width: parent.width

        RoundedImage {
            id: communityImg
            source: popup.source
            width: 40
            height: 40
        }

        StyledTextEdit {
            id: communityName
            text:  popup.name
            anchors.top: parent.top
            anchors.topMargin: 2
            anchors.left: communityImg.right
            anchors.leftMargin: Style.current.smallPadding
            font.bold: true
            font.pixelSize: 17
            readOnly: true
        }

        StyledText {
            text: {
                switch(access) {
                case Constants.communityChatPublicAccess: return qsTr("Public community");
                case Constants.communityChatInvitationOnlyAccess: return qsTr("Invitation only community");
                case Constants.communityChatOnRequestAccess: return qsTr("On request community");
                default: return qsTr("Unknown community");
                }
            }
            anchors.left: communityName.left
            anchors.top: communityName.bottom
            anchors.topMargin: 2
            font.pixelSize: 15
            font.weight: Font.Thin
            color: Style.current.secondaryText
        }
    }

    StyledText {
        id: descriptionText
        text: popup.description
        wrapMode: Text.Wrap
        width: parent.width
        font.pixelSize: 15
        font.weight: Font.Thin
    }


    Separator {
        id: sep1
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: descriptionText.bottom
        anchors.topMargin: Style.current.smallPadding
        anchors.leftMargin: -Style.current.padding
        anchors.rightMargin: -Style.current.padding
    }

    StyledText {
        id: chatsTitle
        text: qsTr("TODO:")
        anchors.top: sep1.bottom
        anchors.topMargin: Style.current.bigPadding
        font.pixelSize: 15
        font.weight: Font.Thin
    }

}

