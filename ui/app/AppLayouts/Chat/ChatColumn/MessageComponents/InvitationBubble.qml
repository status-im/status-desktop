import QtQuick 2.3
import "../../../../../shared"
import "../../../../../shared/status"
import "../../../../../imports"
import "./TransactionComponents"
import "../../../Wallet/data"

Item {
    property string communityId
    property var invitedCommunity
    property int innerMargin: 12
    property bool joined: false
    property bool isLink: false

    id: root
    anchors.left: parent.left
    height: childrenRect.height
    width: rectangleBubbleLoader.width + chatImage.width

    Component.onCompleted: {
        chatsModel.communities.setObservedCommunity(root.communityId)

        root.invitedCommunity = chatsModel.communities.observedCommunity
    }

    UserImage {
        id: chatImage
        visible: (!isLink && authorCurrentMsg !== authorPrevMsg && !isCurrentUser) ||
                 (appSettings.useCompactMode && isCurrentUser && authorCurrentMsg !== authorPrevMsg)
        anchors.left: parent.left
        anchors.leftMargin: visible ? Style.current.padding : 0
        anchors.top: parent.top
    }

    Loader {
        id: rectangleBubbleLoader
        active: !!invitedCommunity
        width: item.width
        height: item.height
        anchors.left: !isLink && (!isCurrentUser || (isCurrentUser === appSettings.useCompactMode)) ? chatImage.right : undefined
        anchors.leftMargin: isLink ? 0 : Style.current.smallPadding
        anchors.right: !appSettings.useCompactMode && isCurrentUser ? parent.right : undefined

        sourceComponent: Component {
            Rectangle {
                id: rectangleBubble
                width: 270
                height: childrenRect.height + Style.current.halfPadding
                radius: 16
                color: Style.current.background
                border.color: Style.current.border
                border.width: 1

                // TODO add check if verified
                StyledText {
                    id: title
                    color: invitedCommunity.verifed ? Style.current.primary : Style.current.secondaryText
                    text: invitedCommunity.verifed ?
                              //% "Verified community invitation"
                              qsTrId("verified-community-invitation") :
                              //% "Community invitation"
                              qsTrId("community-invitation")
                    font.weight: Font.Medium
                    anchors.top: parent.top
                    anchors.topMargin: Style.current.halfPadding
                    anchors.left: parent.left
                    anchors.leftMargin: root.innerMargin
                    font.pixelSize: 13
                }

                StyledText {
                    id: invitedYou
                    //% "%1 invited you to join a community"
                    text: qsTrId("-1-invited-you-to-join-a-community").arg(userName)
                    anchors.top: title.bottom
                    anchors.topMargin: 4
                    anchors.left: parent.left
                    anchors.leftMargin: root.innerMargin
                    anchors.right: parent.right
                    anchors.rightMargin: root.innerMargin
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                }

                Separator {
                    id: sep1
                    anchors.top: invitedYou.bottom
                    anchors.topMargin: Style.current.halfPadding
                }

                // TODO add image when it's supported
                StyledText {
                    id: communityName
                    text: invitedCommunity.name
                    anchors.top: sep1.bottom
                    anchors.topMargin: root.innerMargin
                    anchors.left: parent.left
                    anchors.leftMargin: root.innerMargin
                    anchors.right: parent.right
                    anchors.rightMargin: root.innerMargin
                    font.weight: Font.Bold
                    wrapMode: Text.WordWrap
                    font.pixelSize: 17
                }

                StyledText {
                    id: communityDesc
                    text: invitedCommunity.description
                    anchors.top: communityName.bottom
                    anchors.topMargin: 2
                    anchors.left: parent.left
                    anchors.leftMargin: root.innerMargin
                    anchors.right: parent.right
                    anchors.rightMargin: root.innerMargin
                    wrapMode: Text.WordWrap
                    font.pixelSize: 15
                }

                StyledText {
                    id: communityNbMembers
                    // TODO add the plural support
                    //% "%1 members"
                    text: qsTrId("-1-members").arg(invitedCommunity.nbMembers)
                    anchors.top: communityDesc.bottom
                    anchors.topMargin: 2
                    anchors.left: parent.left
                    anchors.leftMargin: root.innerMargin
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    color: Style.current.secondaryText
                }

                Separator {
                    id: sep2
                    anchors.top: communityNbMembers.bottom
                    anchors.topMargin: Style.current.halfPadding
                }

                StatusButton {
                    type: "secondary"
                    anchors.top: sep2.bottom
                    width: parent.width
                    height: 44
                    enabled: !invitedCommunity.joined
                    //% "Joined"
                    text: root.joined || invitedCommunity.joined ? qsTrId("joined") :
                        //% "Join"
                        qsTrId("join")
                    onClicked: {
                        chatsModel.communities.joinCommunity(communityId, true)
                        root.joined = true
                    }
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#4c4e50";formeditorZoom:1.25}
}
##^##*/
