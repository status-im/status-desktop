import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.views.chat 1.0
import utils 1.0

import SortFilterProxyModel 0.2

import AppLayouts.Chat.stores 1.0 as ChatStores

Item {
    id: root

    property ChatStores.RootStore store
    property var chatCommunitySectionModule
    property string activeChatId: chatCommunitySectionModule && chatCommunitySectionModule.activeItem.id
    property string label
    property int communityMemberReevaluationStatus: Constants.CommunityMemberReevaluationStatus.None

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

    StatusBaseText {
        id: communityMemberReevaluationInProgressText
        visible: root.communityMemberReevaluationStatus === Constants.CommunityMemberReevaluationStatus.InProgress
        height: visible ? implicitHeight : 0 
        anchors.top: titleText.bottom
        anchors.topMargin: visible ? Style.current.padding : 0
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        font.pixelSize: Style.current.secondaryTextFontSize
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
            topMargin: Style.current.padding
            left: parent.left
            leftMargin: Style.current.halfPadding
            right: parent.right
            rightMargin: Style.current.halfPadding
            bottom: parent.bottom
        }

        clip: true

        Loader {
            id: loadingUsersView

            anchors.fill: parent

            active: messageStore.loading
            visible: active
            sourceComponent: MessagesLoadingView {
                // anchors.margins: 16
                isUserList: true
                anchors.fill: parent
            }
        }


        Repeater {
            id: chatRepeater
            model: chatCommunitySectionModule && chatCommunitySectionModule.model

            Loader {
                id: listLoader

                property bool makeActive: model.type !== Constants.chatType.category && model.type !== Constants.chatType.unknown && model.loaderActive
                property string chatId: model.itemId

                anchors.fill: parent
                active: false
                asynchronous: true

                onMakeActiveChanged: {
                    if (!listLoader.active && listLoader.makeActive) {
                        loadingUsersView.active = true
                        userListDelay.start()
                    } else if (!listLoader.makeActive) {
                        listLoader.active = false
                    }
                }

                Timer {
                    id: userListDelay
                    repeat: false
                    running: false
                    interval: 500
                    onTriggered: {
                        listLoader.active = true
                        loadingUsersView.active = false
                    }
                }

                sourceComponent: StatusListView {
                    id: userListView
                    objectName: "userListPanel"

                    clip: false

                    visible: listLoader.chatId === root.activeChatId

                    anchors.fill: parent
                    anchors.bottomMargin: Style.current.bigPadding
                    displayMarginEnd: anchors.bottomMargin

                    model: SortFilterProxyModel {
                        sourceModel: {
                            root.chatCommunitySectionModule.prepareChatContentModuleForChatId(listLoader.chatId)
                            const chatContentModule = root.chatCommunitySectionModule.getChatContentModule()
                            if (!chatContentModule || !chatContentModule.usersModule) {
                                return null
                            }
                            return chatContentModule.usersModule.model
                        }
                        
                        // sourceModel: root.usersModel

                        proxyRoles: FastExpressionRole {
                            function displayNameProxy(nickname, ensName, displayName, aliasName) {
                                return ProfileUtils.displayName(nickname, ensName, displayName, aliasName)
                            }
                            name: "preferredDisplayName"
                            expectedRoles: ["localNickname", "ensName", "displayName", "alias"]
                            expression: displayNameProxy(model.localNickname, model.ensName, model.displayName, model.alias)
                        }

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
                        asset.name: model.icon
                        asset.isImage: (asset.name !== "")
                        asset.isLetterIdenticon: (asset.name === "")
                        asset.color: Utils.colorForColorId(model.colorId)
                        status: model.onlineStatus
                        ringSettings.ringSpecModel: model.colorHash
                        onClicked: {
                            if (mouse.button === Qt.RightButton) {
                                Global.openMenu(profileContextMenuComponent, this, {
                                                    myPublicKey: userProfile.pubKey,
                                                    selectedUserPublicKey: model.pubKey,
                                                    selectedUserDisplayName: nickName || userName,
                                                    selectedUserIcon: model.icon,
                                                })
                            } else if (mouse.button === Qt.LeftButton) {
                                Global.openProfilePopup(model.pubKey);
                            }
                        }
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

    Component {
        id: profileContextMenuComponent

        ProfileContextMenu {
            store: root.store
            margins: 8
            onOpenProfileClicked: {
                Global.openProfilePopup(publicKey, null)
            }
            onCreateOneToOneChat: {
                Global.changeAppSectionBySectionType(Constants.appSection.chat)
                root.store.chatCommunitySectionModule.createOneToOneChat(communityId, chatId, ensName)
            }
            onClosed: {
                destroy()
            }
        }
    }
}
