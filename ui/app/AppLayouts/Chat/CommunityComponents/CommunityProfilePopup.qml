import QtQuick 2.12
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
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
    property bool isAdmin: true // TODO: 
    height: isAdmin ? 640 : 509

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

    TextWithLabel {
        id: shareCommunity
        anchors.top: sep1.bottom
        anchors.topMargin: Style.current.bigPadding
        label: qsTr("Share community")
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
        anchors.topMargin: Style.current.padding
        width: parent.width
        spacing: Style.current.padding
        
        
        Loader {
            active: isAdmin
            width: parent.width
            sourceComponent: CommunityPopupButton {
                label: qsTr("Members")
                iconName: "members"
                txtColor: Style.current.textColor
                onClicked: openPopup(communityMembersPopup)
                Component {
                    id: communityMembersPopup
                    CommunityMembersPopup { }
                }
                Item {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    width: 100
                    StyledText {
                        text: nbMembers.toString()
                        anchors.right: caret.left
                        anchors.rightMargin: Style.current.smallPadding
                        anchors.top: parent.top
                        anchors.topMargin: 10
                        padding: 0
                        font.pixelSize: 15
                        color: Style.current.secondaryText
                    }

                    SVGImage {
                        id: caret
                        anchors.right: parent.right
                        anchors.topMargin: Style.current.padding
                        anchors.top: parent.top
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

        Loader {
            active: isAdmin
            width: parent.width
            sourceComponent: CommunityPopupButton {
                label: qsTr("Roles")
                iconName: "roles"
                width: parent.width
                onClicked: console.log("TODO:")
                txtColor: Style.current.textColor
                SVGImage {
                    anchors.top: parent.top
                    anchors.topMargin: Style.current.padding
                    anchors.right: parent.right
                    anchors.rightMargin: 0
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

        CommunityPopupButton {
            id: notificationsBtn
            label: qsTr("Notifications")
            iconName: "notifications"
            width: parent.width
            txtColor: Style.current.textColor
            onClicked: function(){
                notificationSwitch.checked = !notificationSwitch.checked
            }
            StatusSwitch {
                id: notificationSwitch
                anchors.right: parent.right
                onCheckedChanged: function(value) {
                    // TODO: enable/disable notifications
                    console.log("TODO: toggle")
                }
            }
        }

        Separator {
            width: parent.width
        }

        Loader {
            active: isAdmin
            width: parent.width
            sourceComponent: CommunityPopupButton {
                label: qsTr("Edit community")
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
            property string exportResult: ""

            active: isAdmin
            width: parent.width
            sourceComponent: !exportResult ? exportBtn : resultComponent

            Component {
                id: exportBtn
                CommunityPopupButton {
                    label: qsTr("Export community")
                    iconName: "../fetch"
                    onClicked:  exportResult = chatsModel.exportComumnity()
                }
            }

            Component {
                id: resultComponent
                StyledText {
                    property bool isError: !exportResult.startsWith("0x")

                    text: exportResult
                    color: isError ? Style.current.danger : Style.current.textColor
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.smallPadding + copyToClipboardBtn.width
                    wrapMode: TextEdit.WrapAnywhere

                    CopyToClipBoardButton {
                        id: copyToClipboardBtn
                        visible: !isError
                        textToCopy: exportResult
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.right
                        anchors.leftMargin: Style.current.smallPadding
                    }
                }
            }
        }

        CommunityPopupButton {
            label: qsTr("Leave community")
            iconName: "leave"
        }

        Loader {
            active: isAdmin
            width: parent.width
            sourceComponent: CommunityPopupButton {
                id: deleteBtn
                label: qsTr("Delete")
                iconName: "delete"
                txtColor: Style.current.red
                //btnColor: Style.current.red // TODO: statusroundbutton should support changing color
            }
        }
    }
}

