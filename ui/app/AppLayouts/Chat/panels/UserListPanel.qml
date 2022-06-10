import QtQuick 2.13
import QtQuick.Controls 2.13
import StatusQ.Components 0.1
import shared 1.0
import shared.panels 1.0
import shared.status 1.0

import utils 1.0

import "../controls"

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Item {
    id: root
    anchors.fill: parent

    // Important:
    // Each chat/channel has its own ChatContentModule and each ChatContentModule has a single usersModule
    // usersModule on the backend contains everything needed for this component
    property var usersModule
    property var messageContextMenu
    property string label

    property var rootStore

    StatusBaseText {
        id: titleText
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        opacity: (root.width > 58) ? 1.0 : 0.0
        visible: (opacity > 0.1)
        font.pixelSize: Style.current.primaryTextFontSize
        font.weight: Font.Medium
        color: Theme.palette.directColor1
        text: root.label
    }

    ListView {
        id: userListView
        clip: true
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
        anchors {
            top: titleText.bottom
            topMargin: Style.current.padding
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: Style.current.bigPadding
        }
        boundsBehavior: Flickable.StopAtBounds
        model: usersModule.model
        section.property: "onlineStatus"
        section.delegate: (root.width > 58) ? sectionDelegateComponent : null
        delegate: StatusMemberListItem {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.right: parent.right
            anchors.rightMargin: 8
            nickName: model.localNickname
            userName: model.displayName
            pubKey: Utils.getCompressedPk(model.pubKey)
            isContact: model.isContact
            isVerified: model.isVerified
            isUntrustworthy: model.isUntrustworthy
            isAdmin: model.isAdmin
            image.source: {
                if ((!model.isContact &&
                    Global.privacyModuleInst.profilePicturesVisibility !==
                    Constants.profilePicturesVisibility.everyone)) {
                    return "";
                }
                return model.icon;
            }
            image.isIdenticon: false

            status: model.onlineStatus
            icon.color: Theme.palette.userCustomizationColors[Utils.colorIdForPubkey(model.pubKey)] // FIXME: use model.colorId
            ringSettings.ringSpecModel: Utils.getColorHashAsJson(model.pubKey) // FIXME: use model.colorHash
            onClicked: {
                if (mouse.button === Qt.RightButton) {
                    // Set parent, X & Y positions for the messageContextMenu
                    messageContextMenu.parent = this
                    messageContextMenu.setXPosition = function() { return 0; }
                    messageContextMenu.setYPosition = function() { return mouse.y + (Style.current.halfPadding/2); }
                    messageContextMenu.isProfile = true
                    messageContextMenu.myPublicKey = userProfile.pubKey
                    messageContextMenu.selectedUserPublicKey = model.pubKey
                    messageContextMenu.selectedUserDisplayName = model.displayName
                    messageContextMenu.selectedUserIcon = image.source
                    messageContextMenu.popup()
                } else if (mouse.button === Qt.LeftButton && !!messageContextMenu) {
                    Global.openProfilePopup(model.pubKey);
                }
            }
        }
    }

    Component {
        id: sectionDelegateComponent
        Item {
            width: parent.width
            height: 24
            StyledText {
                anchors.fill: parent
                anchors.leftMargin: Style.current.padding
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Style.current.additionalTextSize
                color: Theme.palette.baseColor1
                text: {
                    switch(parseInt(section)) {
                        case Constants.onlineStatus.online:
                            return qsTr("Online")
                        default:
                             return qsTr("Inactive")
                    }
                }
            }
        }
    }
}
