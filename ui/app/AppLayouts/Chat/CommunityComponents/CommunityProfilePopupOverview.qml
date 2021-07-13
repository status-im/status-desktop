import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import QtQuick.Controls.Universal 2.12
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "../ContactsColumn"

Item {
    id: root

    property string headerTitle: ""
    property string headerDescription: ""
    property string headerImageSource: ""
    property string description: ""

    width: parent.width
    height: childrenRect.height

    StyledText {
        id: descriptionText
        text: root.description
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
        text: `${Constants.communityLinkPrefix}${communityId.substring(0, 4)}...${communityId.substring(communityId.length -2)}`
        textToCopy: Constants.communityLinkPrefix + communityId
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
            width: parent.width
            sourceComponent: Component {
                CommunityPopupButton {
                    id: memberBtn
                    label: qsTr("Members")
                    iconName: "members"
                    txtColor: Style.current.textColor
                    onClicked: stack.push(membersList)
                    type: globalSettings.theme === Universal.Dark ? "secondary" : "primary"

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
            type: globalSettings.theme === Universal.Dark ? "secondary" : "primary"
            onClicked: function(){
                notificationSwitch.clicked()
            }
            StatusSwitch {
                id: notificationSwitch
                checked: !chatsModel.communities.activeCommunity.muted
                anchors.right: parent.right
                anchors.rightMargin: Style.current.padding
                anchors.verticalCenter: parent.verticalCenter
                onClicked: function () {
                    chatsModel.communities.setCommunityMuted(chatsModel.communities.activeCommunity.id, notificationSwitch.checked)
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
            // TODO: once Edit is vailable in the app, put back isAdmin
            active: isAdmin
            width: parent.width
            sourceComponent: CommunityPopupButton {
                //% "Edit community"
                label: qsTrId("edit-community")
                iconName: "edit"
                type: globalSettings.theme === Universal.Dark ? "secondary" : "primary"
                onClicked: openPopup(editCommunityPopup)
            }
        }

        Loader {
            active: isAdmin
            width: parent.width
            sourceComponent: CommunityPopupButton {
                label: qsTr("Transfer ownership")
                iconName: "../transfer"
                type: globalSettings.theme === Universal.Dark ? "secondary" : "primary"
                onClicked: openPopup(transferOwnershipPopup, {privateKey: chatsModel.communities.exportComumnity()})
            }
        }

        CommunityPopupButton {
            //% "Leave community"
            label: qsTrId("leave-community")
            iconName: "leave"
            type: "warn"
            txtColor: Style.current.red
            onClicked: chatsModel.communities.leaveCommunity(communityId)
        }
    }
}
