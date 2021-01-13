import QtQuick 2.12
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "../ContactsColumn"

ModalPopup {
    property QtObject community: chatsModel.observedCommunity
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
            // TODO get this from access property
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

    Item {
        id: memberContainer
        width: parent.width
        height: memberImage.height
        anchors.top: descriptionText.bottom
        anchors.topMargin: Style.current.padding

        SVGImage {
            id: memberImage
            source: "../../../img/member.svg"
            width: 16
            height: 16
        }


        StyledText {
            text: nbMembers === 1 ? 
                  qsTr("1 member") : 
                  qsTr("%1 members").arg(popup.nbMembers)
            wrapMode: Text.WrapAnywhere
            width: parent.width
            anchors.left: memberImage.right
            anchors.leftMargin: 4
            font.pixelSize: 15
            font.weight: Font.Medium
        }
    }


    Separator {
        id: sep1
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: memberContainer.bottom
        anchors.topMargin: Style.current.smallPadding
        anchors.leftMargin: -Style.current.padding
        anchors.rightMargin: -Style.current.padding
    }

    StyledText {
        id: chatsTitle
        text: qsTr("Chats")
        anchors.top: sep1.bottom
        anchors.topMargin: Style.current.bigPadding
        font.pixelSize: 15
        font.weight: Font.Thin
    }


    ListView {
        id: chatsList
        width: parent.width
        anchors.top: chatsTitle.bottom
        anchors.topMargin: 4
        anchors.bottom: parent.bottom
        clip: true
        model: community.chats
        boundsBehavior: Flickable.StopAtBounds
        delegate: Channel {
            id: channelItem
            unviewedMessagesCount: ""
            width: parent.width
            name: model.name
            lastMessage: model.description
            contentType: Constants.messageType
            border.width: 0
            color: Style.current.transparent
            enableMouseArea: false
        }
    }

    footer: Item {
        width: parent.width
        height: backButton.height

        StatusIconButton {
            id: backButton
            icon.name: "leave_chat"
            width: 44
            height: 44
            iconColor: Style.current.primary
            highlighted: true
            icon.color: Style.current.primary
            icon.width: 28
            icon.height: 28
            radius: width / 2
            onClicked: {
                openPopup(communitiesPopupComponent)
                popup.close()
            }
        }

        StatusButton {
            text: qsTr("Join ‘%1’").arg(popup.name)
            anchors.right: parent.right
            onClicked: {
                const error = chatsModel.joinCommunity(popup.communityId)

                if (error) {
                    joiningError.text = error
                    return joiningError.open()
                }

                popup.close()
            }
        }

        MessageDialog {
            id: joiningError
            title: qsTr("Error joining the community")
            icon: StandardIcon.Critical
            standardButtons: StandardButton.Ok
        }
    }
}

