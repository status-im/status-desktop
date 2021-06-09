import QtQuick 2.3
import QtQuick.Dialogs 1.3
import "../../../../../shared"
import "../../../../../shared/status"
import "../../../../../imports"
import "./TransactionComponents"
import "../../../Wallet/data"

Item {
    property string communityId
    property var invitedCommunity
    property int innerMargin: 12
    property bool isLink: false

    id: root
    anchors.left: parent.left
    height: childrenRect.height
    width: rectangleBubbleLoader.width

    Component.onCompleted: {
        chatsModel.communities.setObservedCommunity(root.communityId)

        root.invitedCommunity = chatsModel.communities.observedCommunity
    }

    Loader {
        id: rectangleBubbleLoader
        active: !!invitedCommunity
        width: item.width
        height: item.height

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
                    text: isCurrentUser ? 
                        qsTr("You invited %1 to join a community").arg(chatsModel.userNameOrAlias(chatsModel.activeChannel.id))
                        //% "%1 invited you to join a community"
                        : qsTrId("-1-invited-you-to-join-a-community").arg(displayUserName)
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
                    property int access: invitedCommunity.access
                    property bool isPendingRequest: {
                        if (invitedCommunity.access !== Constants.communityChatOnRequestAccess) {
                            return false
                        }
                        return chatsModel.communities.isCommunityRequestPending(communityId)
                    }
                    id: joinBtn
                    type: "secondary"
                    anchors.top: sep2.bottom
                    width: parent.width
                    height: 44
                    enabled: {
                        if (invitedCommunity.ensOnly && !profileModel.profile.ensVerified) {
                            return false
                        }
                        if (joinBtn.access === Constants.communityChatInvitationOnlyAccess || isPendingRequest) {
                            return false
                        }
                        
                        return true
                    }
                    text: {
                        if (invitedCommunity.ensOnly && !profileModel.profile.ensVerified) {
                            return qsTr("Membership requires an ENS username")
                        }
                        if (invitedCommunity.canJoin) {
                            return qsTr("Join")
                        }
                        if (invitedCommunity.joined || invitedCommunity.isMember) {
                            return qsTr("View")
                        }
                        if (isPendingRequest) {
                             return qsTr("Pending")
                        }

                        switch(joinBtn.access) {
                        case Constants.communityChatPublicAccess: return qsTr("Join")
                        case Constants.communityChatInvitationOnlyAccess: return qsTr("You need to be invited");
                        case Constants.communityChatOnRequestAccess: return qsTr("Request to join")
                        default: return qsTr("Unknown community");
                        }
                    }

                    onClicked: {
                        let error

                        if (invitedCommunity.joined || invitedCommunity.isMember) {
                            chatsModel.communities.setActiveCommunity(communityId);
                            return
                        }

                        if (joinBtn.access === Constants.communityChatOnRequestAccess) {
                            error = chatsModel.communities.requestToJoinCommunity(communityId,
                                                                      profileModel.profile.ensVerified ? profileModel.profile.username : "")
                            if (!error) {
                                enabled = false
                                text = qsTr("Pending")
                            }
                        } else {
                            error = chatsModel.communities.joinCommunity(communityId, true)
                            enabled = false
                            text = qsTr("Joined")
                        }

                        if (error) {
                            joiningError.text = error
                            return joiningError.open()
                        }
                    }

                    MessageDialog {
                        id: joiningError
                        //% "Error joining the community"
                        title: qsTrId("error-joining-the-community")
                        icon: StandardIcon.Critical
                        standardButtons: StandardButton.Ok
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
