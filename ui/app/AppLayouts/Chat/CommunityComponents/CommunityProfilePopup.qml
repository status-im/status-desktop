import QtQuick 2.12
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "../ContactsColumn"

ModalPopup {
    property QtObject community: chatsModel.communities.activeCommunity
    property string communityId: community.id
    property string name: community.name
    property string description: community.description
    property int access: community.access
    // TODO get the real image once it's available
    property string source: "../../../img/ens-header-dark@2x.png"
    property int nbMembers: community.nbMembers
    property bool isAdmin: true // TODO: 
    height: (isAdmin ? 600 : 590) + descriptionText.height

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
                //% "Public community"
                case Constants.communityChatPublicAccess: return qsTrId("public-community");
                //% "Invitation only community"
                case Constants.communityChatInvitationOnlyAccess: return qsTrId("invitation-only-community");
                //% "On request community"
                case Constants.communityChatOnRequestAccess: return qsTrId("on-request-community");
                //% "Unknown community"
                default: return qsTrId("unknown-community");
                }
            }
            anchors.left: communityName.left
            anchors.top: communityName.bottom
            anchors.topMargin: 2
            font.pixelSize: 15
            font.weight: Font.Thin
            color: Style.current.secondaryText
        }

        Separator {
            anchors.top: communityImg.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
            anchors.leftMargin: -Style.current.padding
        }
    }

    StyledText {
        id: descriptionText
        text: popup.description
        wrapMode: Text.Wrap
        width: parent.width
        font.pixelSize: 15
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

    TextWithLabel {
        id: shareCommunity
        anchors.top: sep1.bottom
        anchors.topMargin: Style.current.bigPadding
        //% "Share community"
        label: qsTrId("share-community")
        text: "https://join.status.im/u/TODO"
        textToCopy: text
    }

    Separator {
        id: sep2
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: shareCommunity.bottom
        anchors.topMargin: Style.current.smallPadding
        anchors.leftMargin: -Style.current.padding
        anchors.rightMargin: -Style.current.padding
    }

    Column {
        anchors.top: sep2.bottom
        anchors.topMargin: Style.current.halfPadding
        width: parent.width
        
        Loader {
            active: isAdmin
            width: parent.width
            sourceComponent: Component {
                CommunityPopupButton {
                    id: memberBtn
                    label: qsTr("Members")
                    iconName: "members"
                    txtColor: Style.current.textColor
                    onClicked: openPopup(communityMembersPopup)

                    Component {
                        id: communityMembersPopup
                        CommunityMembersPopup {}
                    }

                    Item {
                        property int nbRequests: chatsModel.communities.activeCommunity.communityMembershipRequests.nbRequests

                        id: memberBlock
                        anchors.right: parent.right
                        anchors.rightMargin: Style.current.padding
                        anchors.verticalCenter: parent.verticalCenter
                        width: childrenRect.width
                        height: memberBtn.height

                        StyledText {
                            id: nbMemberText
                            text: nbMembers.toString()
                            anchors.verticalCenter: parent.verticalCenter
                            padding: 0
                            font.pixelSize: 15
                            color: Style.current.secondaryText
                        }

                        Rectangle {
                            id: badge
                            visible: memberBlock.nbRequests > 0
                            anchors.left: nbMemberText.right
                            anchors.leftMargin: visible ? Style.current.halfPadding : 0
                            anchors.verticalCenter: parent.verticalCenter
                            color: Style.current.blue
                            width: visible ? 22 : 0
                            height: 22
                            radius: width / 2
                            Text {
                                font.pixelSize: 12
                                color: Style.current.white
                                anchors.centerIn: parent
                                text: memberBlock.nbRequests
                            }
                        }

                        SVGImage {
                            id: caret
                            anchors.left: badge.right
                            anchors.leftMargin: Style.current.padding
                            anchors.verticalCenter: parent.verticalCenter
                            source: "../../../img/caret.svg"
                            width: 13
                            height: 7
                            rotation: -90
                            ColorOverlay {
                                anchors.fill: parent
                                source: parent
                                color: Style.current.secondaryText
                            }
                        }
                    }
                }
            }
        }

        // TODO add this back when roles exist
//        Loader {
//            active: isAdmin
//            width: parent.width
//            sourceComponent: CommunityPopupButton {
//                label: qsTr("Roles")
//                iconName: "roles"
//                width: parent.width
//                onClicked: console.log("TODO:")
//                txtColor: Style.current.textColor
//                SVGImage {
//                    anchors.verticalCenter: parent.verticalCenter
//                    anchors.right: parent.right
//                    anchors.rightMargin: Style.current.padding
//                    source: "../../../img/caret.svg"
//                    width: 13
//                    height: 7
//                    rotation: -90
//                    ColorOverlay {
//                        anchors.fill: parent
//                        source: parent
//                        color: Style.current.secondaryText
//                    }
//                }
//            }
//        }

        CommunityPopupButton {
            id: notificationsBtn
            //% "Notifications"
            label: qsTrId("notifications")
            iconName: "notifications"
            width: parent.width
            txtColor: Style.current.textColor
            onClicked: function(){
                notificationSwitch.checked = !notificationSwitch.checked
            }
            StatusSwitch {
                id: notificationSwitch
                anchors.right: parent.right
                anchors.rightMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
                onCheckedChanged: function(value) {
                    // TODO: enable/disable notifications
                    console.log("TODO: toggle")
                }
            }
        }

        Item {
            id: spacer1
            width: parent.width
            height: Style.current.halfPadding
        }

        Separator {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
            anchors.leftMargin: -Style.current.padding
        }

        Item {
            id: spacer2
            width: parent.width
            height: Style.current.halfPadding
        }

        Loader {
            active: isAdmin
            width: parent.width
            sourceComponent: CommunityPopupButton {
                //% "Edit community"
                label: qsTrId("edit-community")
                iconName: "edit"
                onClicked: openPopup(editCommunityPopup)

                Component {
                    id: editCommunityPopup
                    CreateCommunityPopup {
                        isEdit: true
                    }
                }
            }
        }

        Loader {
            active: isAdmin
            width: parent.width
            sourceComponent: CommunityPopupButton {
                label: qsTr("Transfer ownership")
                iconName: "../transfer"
                onClicked: {
                    const exportResult = chatsModel.communities.exportComumnity()
                    openPopup(transferOwnershipPopup, {privateKey: exportResult})
                }

                Component {
                    id: transferOwnershipPopup
                    TransferOwnershipPopup {}
                }
            }
        }

        CommunityPopupButton {
            //% "Leave community"
            label: qsTrId("leave-community")
            iconName: "leave"
        }

        Loader {
            active: isAdmin
            width: parent.width
            sourceComponent: CommunityPopupButton {
                id: deleteBtn
                //% "Delete"
                label: qsTrId("delete")
                iconName: "delete"
                txtColor: Style.current.danger
                type: "warn"
            }
        }
    }
}

