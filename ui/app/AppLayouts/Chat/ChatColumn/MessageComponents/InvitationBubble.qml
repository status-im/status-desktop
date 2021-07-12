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

    function getCommunity() {
        let community = JSON.parse(chatsModel.communities.list.getCommunityByIdJson(communityId));
        if (community) {
            community.nbMembers = community.members.length;
        }
        return community
    }

    Component.onCompleted: {
        root.invitedCommunity = getCommunity()
    }

    Connections {
        target: chatsModel.communities
        onCommunityChanged: function (communityId) {
            if (communityId === root.communityId) {
                root.invitedCommunity = getCommunity()
            }
        }
    }

    Component {
        id: confirmationPopupComponent
        ConfirmationDialog {
            property string settingsProp: ""
            property var onConfirmed: (function(){})
            height: 310
            showCancelButton: true
            confirmationText: qsTr("This feature is experimental and is meant for testing purposes by core contributors and the community. It's not meant for real use and makes no claims of security or integrity of funds or data. Use at your own risk.")
            confirmButtonLabel: qsTr("I understand")
            onConfirmButtonClicked: {
                appSettings.communitiesEnabled = true
                onConfirmed()
                close()
            }

            onCancelButtonClicked: {
                close()
            }
            onClosed: {
                destroy()
            }
        }
    }
    

    Loader {
        id: rectangleBubbleLoader
        active: !!invitedCommunity
        width: item.width
        height: item.height

        sourceComponent: Component {
            Rectangle {
                id: rectangleBubble
                property alias button: joinBtn
                property bool isPendingRequest: chatsModel.communities.isCommunityRequestPending(communityId)
                width: 270
                height: childrenRect.height + Style.current.halfPadding
                radius: 16
                color: Style.current.background
                border.color: Style.current.border
                border.width: 1

                states: [
                    State {
                        name: "requiresEns"
                        when: invitedCommunity.ensOnly && !profileModel.profile.ensVerified
                        PropertyChanges {
                            target: joinBtn
                            text: qsTr("Membership requires an ENS username")
                            enabled: false
                        }
                    },
                    State {
                        name: "inviteOnly"
                        when: invitedCommunity.access === Constants.communityChatInvitationOnlyAccess
                        PropertyChanges {
                            target: joinBtn
                            text: qsTr("You need to be invited")
                            enabled: false
                        }
                    },
                    State {
                        name: "pending"
                        when: invitedCommunity.access === Constants.communityChatOnRequestAccess &&
                              rectangleBubble.isPendingRequest
                        PropertyChanges {
                            target: joinBtn
                            text: qsTr("Pending")
                            enabled: false
                        }
                    },
                    State {
                        name: "joined"
                        when: invitedCommunity.joined && invitedCommunity.isMember
                        PropertyChanges {
                            target: joinBtn
                            text: qsTr("View")
                        }
                    },
                    State {
                        name: "requestToJoin"
                        when: invitedCommunity.access === Constants.communityChatOnRequestAccess &&
                            //   !invitedCommunity.joined && !invitedCommunity.isMember
                            invitedCommunity.canRequestAccess
                        PropertyChanges {
                            target: joinBtn
                            text: qsTr("Request Access")

                        }
                    },
                    State {
                        name: "unjoined"
                        when: invitedCommunity.access === Constants.communityChatOnRequestAccess &&
                              invitedCommunity.isMember
                        PropertyChanges {
                            target: joinBtn
                            text: qsTr("Join")
                        }
                    }
                ]

                Connections {
                    target: chatsModel.communities
                    onMembershipRequestChanged: function(communityId, communityName, requestAccepted) {
                        if (communityId === root.communityId) {
                            rectangleBubble.isPendingRequest = false
                        }
                    }
                }

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
                    text: {
                        if (chatsModel.channelView.activeChannel.chatType === Constants.chatTypeOneToOne) {
                            return isCurrentUser ? 
                        qsTr("You invited %1 to join a community").arg(chatsModel.userNameOrAlias(chatsModel.channelView.activeChannel.id))
                                //% "%1 invited you to join a community"
                                : qsTrId("-1-invited-you-to-join-a-community").arg(displayUserName)
                        } else {
                            return isCurrentUser ? 
                                qsTr("You shared a community")
                                : qsTr("A community has been shared")
                        }
                    }
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
                    id: joinBtn
                    type: "secondary"
                    anchors.top: sep2.bottom
                    width: parent.width
                    height: 44
                    enabled: true
                    text: qsTr("Unsupported state")
                    onClicked: {
                        let onBtnClick = function(){
                            let error

                            if (rectangleBubble.state === "joined") {
                                chatsModel.communities.setActiveCommunity(communityId);
                                return
                            } else if (rectangleBubble.state === "unjoined") {
                                error = chatsModel.communities.joinCommunity(communityId, true)
                            }
                            else if (rectangleBubble.state === "requestToJoin") {
                                error = chatsModel.communities.requestToJoinCommunity(communityId,
                                                                        profileModel.profile.ensVerified ? profileModel.profile.username : "")
                                if (!error) {
                                    rectangleBubble.isPendingRequest = chatsModel.communities.isCommunityRequestPending(communityId)
                                }
                            }

                            if (error) {
                                joiningError.text = error
                                return joiningError.open()
                            }
                        }

                        if(appSettings.communitiesEnabled){
                            onBtnClick();
                        } else {
                            openPopup(confirmationPopupComponent, {
                                onConfirmed: onBtnClick
                            });
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
