import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Chat.views 1.0
import AppLayouts.Chat.stores 1.0 as ChatStores

import Storybook 1.0
import utils 1.0
import shared.stores 1.0 as SharedStores

SplitView {
    id: root

    Logs { id: logs }

    property bool globalUtilsReady: false
    property bool mainModuleReady: false

    QtObject {
        function getColorHashAsJson(publicKey) {
            return JSON.stringify([{colorId: 0, segmentLength: 1},
                                   {colorId: 19, segmentLength: 2}])
        }

        function getColorId(publicKey) {
            return Math.floor(Math.random() * 10)
        }

        Component.onCompleted: {
            Utils.globalUtilsInst = this
            root.globalUtilsReady = true
        }

        Component.onDestruction: {
            root.globalUtilsReady = false
            Utils.globalUtilsInst = {}
        }
    }

    QtObject {
        function getContactDetailsAsJson() {
            return JSON.stringify({
                                      ensVerified: false,
                                      isCurrentUser: false,
                                      contactRequestState: Constants.ContactRequestState.Mutual
                                  })
        }

        Component.onCompleted: {
            Utils.mainModuleInst = this
            root.mainModuleReady = true
        }
        Component.onDestruction: {
            root.mainModuleReady = false
            Utils.mainModuleInst = {}
        }
    }

    ListModel {
        id: contacts

        Component.onCompleted: {
            for(let i=0; i < 20; i++) {
                append(usersModelEditor.getNewUser(i))
            }
        }
    }

    ChatStores.RootStore {
        id: rootStoreMock

        readonly property var contactsStore: QtObject {
            readonly property var mainModuleInst: null
        }

        function amIChatAdmin() {
            return chatAdminSwitch.checked
        }
    }

    ChatStores.UsersStore {
        id: usersStoreMock

        readonly property var usersModel: ListModel {
            Component.onCompleted: {
                for(let i=0; i < 4; i++) {
                    append(d.createMemberDict(i))
                }
            }
        }

        readonly property var temporaryModel: ListModel {
            Component.onCompleted: usersStoreMock.resetTemporaryModel()
        }

        function appendTemporaryModel(pubKey, displayName) {
            temporaryModel.append({
                                      pubKey: pubKey,
                                      displayName: displayName,
                                  })
        }

        function removeFromTemporaryModel(pubKey) {
            for(let i = 0; i < temporaryModel.count; i++) {
                if (temporaryModel.get(i).pubKey === pubKey) {
                    temporaryModel.remove(i, 1)
                    return
                }
            }
        }

        function resetTemporaryModel() {
            temporaryModel.clear()
            for(let i = 0; i < usersModel.count; i++) {
                const obj = usersModel.get(i)
                temporaryModel.append(obj)
            }
        }

        function updateGroupMembers() {
            const users = []
            for(let i = 0; i < temporaryModel.count; i++) {
                const obj = temporaryModel.get(i)
                users.push({
                               pubKey: obj.pubKey,
                               compressedPubKey: "compressed_" + obj.pubKey,
                               displayName: obj.displayName,
                               localNickname: "",
                               alias: "three word name(%1)".arg(obj.pubKey),
                               isVerified: false,
                               isUntrustworthy: false,
                               isContact: true,
                               icon: "",
                               color: "red",
                               onlineStatus: 0,
                               isAdmin: i == 0 ? true : false
                           })
            }
            usersModel.clear()
            usersModel.append(users)

            logs.logEvent("UsersStore::updateGroupMembers")
        }
    }

    QtObject {
        id: d

        function createMemberDict(seed: int) {
            var member = usersModelEditor.getNewUser(seed)
            member["isAdmin"] = seed === 0
            return member
        }
    }

    SplitView {
        orientation: Qt.Vertical

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        SwipeView {
            id: swipeView

            SplitView.fillWidth: true
            SplitView.fillHeight: true

            interactive: false
            currentIndex: selectorsSwitch.checked

            Item {
                Loader {
                    active: root.globalUtilsReady && root.mainModuleReady

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: 64
                    }

                    sourceComponent: MembersSelectorView {
                        rootStore: rootStoreMock
                        utilsStore: SharedStores.UtilsStore {
                            function isChatKey() {
                                return true
                            }

                            function isCompressedPubKey(publicKey) {
                                return true
                            }
                        }

                        contactsModel: contacts
                    }
                }
            }

            Item {
                Loader {
                    active: root.globalUtilsReady && root.mainModuleReady

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: 64
                    }

                    sourceComponent: MembersEditSelectorView {
                        rootStore: rootStoreMock
                        usersModel: usersStoreMock.usersModel
                        temporaryUsersModel: usersStoreMock.temporaryModel
                        amIChatAdmin: rootStoreMock.amIChatAdmin()
                        contactsModel: contacts

                        onUpdateGroupMembers: {
                            logs.logEvent("MembersEditSelectorView::updateGroupMembers")
                            usersStoreMock.updateGroupMembers()
                        }
                        onResetTemporaryUsersModel: {
                            logs.logEvent("MembersEditSelectorView::resetTemporaryUsersModel")
                            usersStoreMock.resetTemporaryModel()
                        }
                        onAppendTemporaryUsersModel: {
                            logs.logEvent("MembersEditSelectorView::appendTemporaryUsersModel")
                            usersStoreMock.appendTemporaryModel(pubKey, displayName)
                        }
                        onRemoveFromTemporaryUsersModel: {
                            logs.logEvent("MembersEditSelectorView::removeFromTemporaryUsersModel")
                            usersStoreMock.removeFromTemporaryModel(pubKey)
                        }
                    }
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText

            ColumnLayout {
                Switch {
                    id: selectorsSwitch
                    text: "members editor"
                }

                Switch {
                    id: chatAdminSwitch
                    visible: selectorsSwitch.checked
                    text: "chat admin"
                    onCheckedChanged: usersStore.resetTemporaryModel()
                }
            }
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        UsersModelEditor {
            id: usersModelEditor
            anchors.fill: parent
            model: contacts

            onRemoveClicked: contacts.remove(index, 1)
            onRemoveAllClicked: contacts.clear()
            onAddClicked: contacts.append(usersModelEditor.getNewUser(contacts.count))
        }
    }
}

// category: Components
