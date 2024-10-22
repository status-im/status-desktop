import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.views.chat 1.0
import shared.stores 1.0 as SharedStores

import utils 1.0

import SortFilterProxyModel 0.2

import AppLayouts.Chat.stores 1.0 as ChatStores

Item {
    id: root

    property ChatStores.RootStore store
    property SharedStores.UtilsStore utilsStore

    property var usersModel
    property string label
    property int communityMemberReevaluationStatus: Constants.CommunityMemberReevaluationStatus.None

    StatusBaseText {
        id: titleText
        anchors.top: parent.top
        anchors.topMargin: Theme.padding
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
        opacity: (root.width > 58) ? 1.0 : 0.0
        visible: (opacity > 0.1)
        font.pixelSize: Theme.primaryTextFontSize
        font.weight: Font.Medium
        color: Theme.palette.directColor1
        text: root.label
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
                pubKey: model.isEnsVerified ? "" : Utils.getCompressedPk(model.pubKey)
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
                        const { profileType, trustStatus, contactType, ensVerified, onlineStatus, hasLocalNickname } = root.store.contactsStore.getProfileContext(model.pubKey)
                        const chatType = chatContentModule.chatDetails.type
                        const isAdmin = chatContentModule.amIChatAdmin()

                        Global.openMenu(profileContextMenuComponent, this, {
                                            profileType, trustStatus, contactType, ensVerified, onlineStatus, hasLocalNickname, chatType, isAdmin,
                                            publicKey: model.pubKey,
                                            emojiHash: root.utilsStore.getEmojiHash(model.pubKey),
                                            displayName: nickName || userName,
                                            userIcon: model.icon,
                                        })
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
            margins: 8
            onOpenProfileClicked: Global.openProfilePopup(profileContextMenu.publicKey, null)
            onCreateOneToOneChat: {
                Global.changeAppSectionBySectionType(Constants.appSection.chat)
                root.store.chatCommunitySectionModule.createOneToOneChat("", profileContextMenu.publicKey, "")
            }
            onReviewContactRequest: {
                const contactDetails = profileContextMenu.publicKey === "" ? {} : Utils.getContactDetailsAsJson(profileContextMenu.publicKey, true, true)
                Global.openReviewContactRequestPopup(profileContextMenu.publicKey, contactDetails, null)
            }
            onSendContactRequest: {
                const contactDetails = profileContextMenu.publicKey === "" ? {} : Utils.getContactDetailsAsJson(profileContextMenu.publicKey, true, true)
                Global.openContactRequestPopup(profileContextMenu.publicKey, contactDetails, null)
            }
            onEditNickname: {
                const contactDetails = profileContextMenu.publicKey === "" ? {} : Utils.getContactDetailsAsJson(profileContextMenu.publicKey, true, true)
                Global.openNicknamePopupRequested(profileContextMenu.publicKey, contactDetails, null)
            }
            onRemoveNickname: (displayName) => {
                root.store.contactsStore.changeContactNickname(profileContextMenu.publicKey, "", displayName, true)
            }
            onUnblockContact: {
                const contactDetails = profileContextMenu.publicKey === "" ? {} : Utils.getContactDetailsAsJson(profileContextMenu.publicKey, true, true)
                Global.unblockContactRequested(profileContextMenu.publicKey, contactDetails)
            }
            onMarkAsUntrusted: {
                const contactDetails = profileContextMenu.publicKey === "" ? {} : Utils.getContactDetailsAsJson(profileContextMenu.publicKey, true, true)
                Global.markAsUntrustedRequested(profileContextMenu.publicKey, contactDetails)
            }
            onRemoveTrustStatus: root.store.contactsStore.removeTrustStatus(profileContextMenu.publicKey)
            onRemoveContact: {
                const contactDetails = profileContextMenu.publicKey === "" ? {} : Utils.getContactDetailsAsJson(profileContextMenu.publicKey, true, true)
                Global.removeContactRequested(profileContextMenu.publicKey, contactDetails)
            }
            onBlockContact: {
                const contactDetails = profileContextMenu.publicKey === "" ? {} : Utils.getContactDetailsAsJson(profileContextMenu.publicKey, true, true)
                Global.blockContactRequested(profileContextMenu.publicKey, contactDetails)
            }
            onRemoveFromGroup: {
                root.store.removeMemberFromGroupChat(profileContextMenu.publicKey)
            }
            onClosed: destroy()
        }
    }
}
