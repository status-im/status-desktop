import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import shared.views.chat 1.0
import utils 1.0

import SortFilterProxyModel 0.2

Item {
    id: root

    property var usersModel

    property string label
    property int chatType: Constants.chatType.unknown
    property bool isAdmin
    property int communityMemberReevaluationStatus: Constants.CommunityMemberReevaluationStatus.None

    signal openProfileRequested(string pubKey)
    signal createOneToOneChatRequested(string pubKey)
    signal reviewContactRequestRequested(string pubKey)
    signal sendContactRequestRequested(string pubKey)
    signal editNicknameRequested(string pubKey)
    signal removeNicknameRequested(string pubKey)
    signal blockContactRequested(string pubKey)
    signal unblockContactRequested(string pubKey)
    signal markAsUntrustedRequested(string pubKey)
    signal removeTrustStatusRequested(string pubKey)
    signal removeContactRequested(string pubKey)
    signal removeContactFromGroupRequested(string pubKey)

    StatusBaseText {
        id: titleText

        anchors.top: parent.top
        anchors.topMargin: Theme.padding
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding

        opacity: (root.width > 58) ? 1.0 : 0.0
        visible: (opacity > 0.1)
        font.pixelSize: Theme.primaryTextFontSize
        font.weight: Font.Medium
        color: Theme.palette.directColor1
        text: root.label

        wrapMode: Text.Wrap
    }

    StatusBaseText {
        id: communityMemberReevaluationInProgressText
        visible: root.communityMemberReevaluationStatus === Constants.CommunityMemberReevaluationStatus.InProgress
        height: visible ? implicitHeight : 0
        anchors.top: titleText.bottom
        anchors.topMargin: visible ? Theme.padding : 0
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        font.pixelSize: Theme.secondaryTextFontSize
        color: Theme.palette.directColor1
        text: qsTr("Member re-evaluation in progress...")
        wrapMode: Text.WordWrap

        StatusToolTip {
            text: qsTr("Saving community edits might take longer than usual")
            visible: hoverHandler.hovered
        }
        HoverHandler {
            id: hoverHandler
            enabled: communityMemberReevaluationInProgressText.visible
        }
    }

    Item {
        anchors {
            top: communityMemberReevaluationInProgressText.bottom
            topMargin: Theme.padding
            left: parent.left
            leftMargin: Theme.halfPadding
            right: parent.right
            rightMargin: Theme.halfPadding
            bottom: parent.bottom
        }

        clip: true

        StatusListView {
            id: userListView
            objectName: "userListPanel"

            clip: false

            anchors.fill: parent
            anchors.bottomMargin: Theme.bigPadding
            displayMarginEnd: anchors.bottomMargin

            model: SortFilterProxyModel {
                sourceModel: root.usersModel

                sorters: [
                    RoleSorter {
                        roleName: "onlineStatus"
                        sortOrder: Qt.DescendingOrder
                    },
                    StringSorter {
                        roleName: "preferredDisplayName"
                        caseSensitivity: Qt.CaseInsensitive
                    }
                ]
            }
            section.property: "onlineStatus"
            section.delegate: (root.width > 58) ? sectionDelegateComponent : null
            delegate: StatusMemberListItem {
                width: ListView.view.width

                nickName: model.localNickname
                userName: ProfileUtils.displayName("", model.ensName, model.displayName, model.alias)
                pubKey: model.isEnsVerified ? "" : model.compressedPubKey
                isContact: model.isContact
                isVerified: model.isVerified
                isUntrustworthy: model.isUntrustworthy
                isAdmin: model.memberRole === Constants.memberRole.owner
                icon.name: model.icon
                icon.color: Utils.colorForColorId(model.colorId)
                status: model.onlineStatus
                ringSettings.ringSpecModel: model.colorHash

                onClicked: {
                    if (mouse.button === Qt.RightButton) {
                        const profileType = Utils.getProfileType(model.isCurrentUser, false, model.isBlocked)
                        const contactType = Utils.getContactType(model.contactRequest, model.isContact)

                        const params = {
                            profileType, contactType, chatType, isAdmin,
                            pubKey: model.pubKey,
                            compressedPubKey: model.compressedPubKey,
                            emojiHash: model.emojiHash,
                            colorHash: model.colorHash,
                            colorId: model.colorId,
                            displayName: nickName || userName,
                            userIcon: model.icon,
                            trustStatus: model.trustStatus,
                            onlineStatus: model.onlineStatus,
                            ensVerified: model.isEnsVerified,
                            hasLocalNickname: !!model.localNickname,
                            chatType: root.chatType,
                            isAdmin: root.isAdmin
                        }

                        Global.openMenu(profileContextMenuComponent, this, params)
                    } else if (mouse.button === Qt.LeftButton) {
                        Global.openProfilePopup(model.pubKey)
                    }
                }
            }
        }
    }

    Component {
        id: sectionDelegateComponent

        Item {
            width: ListView.view.width
            height: 24

            StatusBaseText {
                anchors.fill: parent
                anchors.leftMargin: Theme.padding
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.additionalTextSize
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

    Component {
        id: profileContextMenuComponent

        ProfileContextMenu {
            id: profileContextMenu

            property string pubKey

            margins: 8

            onOpenProfileClicked: root.openProfileRequested(pubKey)
            onCreateOneToOneChat: root.createOneToOneChatRequested(pubKey)
            onReviewContactRequest: root.reviewContactRequestRequested(pubKey)
            onSendContactRequest: root.sendContactRequestRequested(pubKey)
            onEditNickname: root.editNicknameRequested(pubKey)
            onRemoveNickname: root.removeNicknameRequested(pubKey)
            onUnblockContact: root.unblockContactRequested(pubKey)
            onMarkAsUntrusted: root.markAsUntrustedRequested(pubKey)
            onRemoveTrustStatus: root.removeTrustStatusRequested(pubKey)
            onRemoveContact: root.removeContactRequested(pubKey)
            onBlockContact: root.blockContactRequested(pubKey)
            onRemoveFromGroup: root.removeContactFromGroupRequested(pubKey)

            onClosed: destroy()
        }
    }
}
