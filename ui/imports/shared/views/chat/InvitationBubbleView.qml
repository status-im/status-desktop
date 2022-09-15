import QtQuick 2.3
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import shared.panels 1.0
import shared.popups 1.0

Item {
    id: root

    implicitHeight: loader.height
    implicitWidth: loader.width

    property var store
    property string communityId

    QtObject {
        id: d

        property var invitedCommunity
        property bool invitationPending

        readonly property int margin: 12

        function getCommunity() {
            try {
                const communityJson = root.store.getSectionByIdJson(communityId)

                if (!communityJson) {
                    root.store.requestCommunityInfo(communityId)
                    return null
                }

                return JSON.parse(communityJson);
            } catch (e) {
                console.error("Error parsing community", e)
            }

            return null
        }

        function reevaluate() {
            invitedCommunity = getCommunity()
            invitationPending = root.store.isCommunityRequestPending(communityId)
        }
    }

    Component.onCompleted: {
        d.reevaluate()
    }

    Connections {
        target: root.store.communitiesModuleInst
        onCommunityChanged: function (communityId) {
            if (communityId === root.communityId) {
                d.reevaluate()
            }
        }
    }

    Connections {
        target: root.store.communitiesModuleInst
        onCommunityAdded: function (communityId) {
            if (communityId === root.communityId) {
                d.reevaluate()
            }
        }
    }

    Connections {
        target: root.store.communitiesModuleInst
        onCommunityAccessRequested: function (communityId) {
            if (communityId === root.communityId) {
                d.reevaluate()
            }
        }
    }

    Loader {
        id: loader

        active: !!d.invitedCommunity

        sourceComponent: Rectangle {
            id: rectangleBubble

            width: 270
            height: columnLayout.implicitHeight
            radius: 16
            color: Style.current.background
            border.color: Style.current.border
            border.width: 1

            states: [
                State {
                    name: "pending"
                    when: d.invitationPending
                    PropertyChanges {
                        target: joinBtn
                        text: qsTr("Pending")
                        enabled: false
                    }
                },
                State {
                    name: "requiresEns"
                    when: d.invitedCommunity.ensOnly && !userProfile.ensName
                    PropertyChanges {
                        target: joinBtn
                        text: qsTr("Membership requires an ENS username")
                        enabled: false
                    }
                },
                State {
                    name: "inviteOnly"
                    when: d.invitedCommunity.access === Constants.communityChatInvitationOnlyAccess
                    PropertyChanges {
                        target: joinBtn
                        text: qsTr("You need to be invited")
                        enabled: false
                    }
                },
                State {
                    name: "joined"
                    when: (d.invitedCommunity.joined && d.invitedCommunity.isMember) ||
                          (d.invitedCommunity.access === Constants.communityChatPublicAccess &&
                            d.invitedCommunity.joined)
                    PropertyChanges {
                        target: joinBtn
                        text: qsTr("View")
                    }
                },
                State {
                    name: "requestToJoin"
                    when: d.invitedCommunity.access === Constants.communityChatOnRequestAccess &&
                          !d.invitedCommunity.joined
                    PropertyChanges {
                        target: joinBtn
                        text: qsTr("Request Access")

                    }
                },
                State {
                    name: "unjoined"
                    when: d.invitedCommunity.access === Constants.communityChatPublicAccess &&
                          !d.invitedCommunity.joined
                    PropertyChanges {
                        target: joinBtn
                        text: qsTr("Join")
                    }
                }
            ]

            ColumnLayout {
                id: columnLayout

                width: parent.width

                spacing: 0

                ColumnLayout {
                    id: invitationDescriptionLayout

                    Layout.leftMargin: d.margin
                    Layout.rightMargin: d.margin
                    Layout.topMargin: 8
                    Layout.bottomMargin: 8

                    spacing: 4

                    StatusBaseText {
                        id: title

                        Layout.fillWidth: true

                        text: d.invitedCommunity.verifed ? qsTr("Verified community invitation") : qsTr("Community invitation")
                        color: d.invitedCommunity.verifed ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
                        font.weight: Font.Medium
                        font.pixelSize: 13
                    }

                    StatusBaseText {
                        id: invitedYou

                        Layout.fillWidth: true

                        visible: text != ""
                        text: {
                            // Not Refactored Yet
                            return ""
    //                        if (root.store.chatsModelInst.channelView.activeChannel.chatType === Constants.chatType.oneToOne) {
    //                            return isCurrentUser ?
    //                                        qsTr("You invited %1 to join a community").arg(root.store.chatsModelInst.userNameOrAlias(root.store.chatsModelInst.channelView.activeChannel.id))
    //                                      : qsTr("%1 invited you to join a community").arg(displayUserName)
    //                        } else {
    //                            return isCurrentUser ?
    //                                        qsTr("You shared a community")
    //                                      : qsTr("A community has been shared")
    //                        }
                        }
                        wrapMode: Text.WordWrap
                        font.pixelSize: 15
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Style.current.separator
                }

                RowLayout {
                    id: communityDescriptionLayout

                    Layout.leftMargin: d.margin
                    Layout.rightMargin: d.margin
                    Layout.topMargin: 12
                    Layout.bottomMargin: 12

                    spacing: 12

                    StatusSmartIdenticon {
                        Layout.alignment: Qt.AlignTop
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40

                        name: d.invitedCommunity.name

                        asset {
                            width: 40
                            height: 40
                            name: d.invitedCommunity.image
                            color: d.invitedCommunity.color
                            isImage: true
                        }
                    }

                    ColumnLayout {
                        spacing: 2

                        StatusBaseText {
                            Layout.fillWidth: true

                            text: d.invitedCommunity.name
                            font.weight: Font.Bold
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.pixelSize: 17
                            color: Theme.palette.directColor1
                        }

                        StatusBaseText {
                            Layout.fillWidth: true

                            text: d.invitedCommunity.description
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            font.pixelSize: 15
                            color: Theme.palette.directColor1
                        }

                        StatusBaseText {
                            Layout.fillWidth: true

                            text: qsTr("%n member(s)", "", d.invitedCommunity.nbMembers)
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: Theme.palette.baseColor1
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Style.current.separator
                }

                StatusFlatButton {
                    id: joinBtn

                    Layout.fillWidth: true
                    Layout.preferredHeight: 44

                    text: qsTr("Unsupported state")

                    onClicked: {
                        if (rectangleBubble.state === "joined") {
                            root.store.setActiveCommunity(communityId);
                            return
                        }
                        if (rectangleBubble.state === "unjoined") {
                            Global.openPopup(communityIntroDialog, { joinMethod: () => {
                                                        let error = root.store.joinCommunity(communityId, userProfile.name)
                                                        if (error) joiningError.showError(error)
                                                    } });
                        }
                        else if (rectangleBubble.state === "requestToJoin") {
                            Global.openPopup(communityIntroDialog, { joinMethod: () => {
                                                        let error = root.store.requestToJoinCommunity(communityId, userProfile.name)
                                                        if (error) joiningError.showError(error)
                                                    } });
                        }
                    }

                    Component.onCompleted: {
                        // FIXME: extract StatusButtonBackground or expose radius property in StatusBaseButton
                        background.radius = 16
                    }
                }
            }
        }
    }

    Component {
        id: communityIntroDialog

        CommunityIntroDialog {
            anchors.centerIn: parent

            property var joinMethod: () => {}

            name: d.invitedCommunity ? d.invitedCommunity.name : ""
            introMessage: d.invitedCommunity ? d.invitedCommunity.introMessage : ""
            imageSrc: d.invitedCommunity ? d.invitedCommunity.image : ""

            onJoined: joinMethod()
        }
    }

    MessageDialog {
        id: joiningError

        function showError(error) {
            joiningError.text = error
            joiningError.open()
        }

        title: qsTr("Error joining the community")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }
}
