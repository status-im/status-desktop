import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Chat.views 1.0
import AppLayouts.Chat.stores 1.0 as ChatStores

import StatusQ.Core.Utils 0.1

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

        function groupMembersUpdateRequested(membersPubKeysList) {
            const pubKeys = membersPubKeysList.split(",");
            const users = [];

            for (let i = 0; i < pubKeys.length; i++) {
                const pubKey = pubKeys[i];

                users.push({
                               pubKey: pubKey,
                               compressedPubKey: "compressed_" + pubKey,
                               displayName: "User_" + pubKey,
                               preferredDisplayName: "User_" + pubKey,
                               localNickname: "",
                               alias: `three word name(${pubKey})`,
                               isVerified: false,
                               isUntrustworthy: false,
                               isContact: true,
                               icon: "",
                               color: "red",
                               onlineStatus: 0,
                               isAdmin: i === 0,
                               memberRole: 0
                           });
            }

            usersModel.clear();
            usersModel.append(users);

            logs.logEvent("UsersStore::updateGroupMembers");
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
                        usersModel: usersStoreMock.usersModel
                        amIChatAdmin: rootStoreMock.amIChatAdmin()
                        contactsModel: contacts

                        onGroupMembersUpdateRequested: {
                            logs.logEvent("MembersEditSelectorView::updateGroupMembers")
                            usersStoreMock.groupMembersUpdateRequested(membersPubKeysList)
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
                    onCheckedChanged: {
                        usersStoreMock.usersModel.clear()
                        for(let i=0; i < 4; i++) {
                            usersStoreMock.usersModel.append(d.createMemberDict(i))
                        }
                    }
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
