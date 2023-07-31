import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Chat.views 1.0

import Storybook 1.0
import utils 1.0

SplitView {
    id: root

    Logs { id: logs }

    property bool globalUtilsReady: false
    property bool mainModuleReady: false

    QtObject {
        function isCompressedPubKey(publicKey) {
            return true
        }

        function getCompressedPk(publicKey) {
            return "123456789"
        }

        function getColorHashAsJson(publicKey) {
            return JSON.stringify([{colorId: 0, segmentLength: 1},
                                   {colorId: 19, segmentLength: 2}])
        }

        function getColorId(publicKey) {
            return Math.floor(Math.random() * 10)
        }

        function isEnsVerified(publicKey)  {
            return false
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
            return JSON.stringify({ ensVerified: false })
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

    QtObject {
        id: rootStoreMock

        readonly property var contactsModel: ListModel {
            id: contactsModel

            Component.onCompleted: {
                for(let i=0; i < 20; i++) {
                    append(usersModelEditor.getNewUser(i))
                }
            }
        }

        readonly property var contactsStore: QtObject {
            readonly property var mainModuleInst: null
        }

        function amIChatAdmin() {
            return chatAdminSwitch.checked
        }
    }

    QtObject {
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
                        usersStore: usersStoreMock
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
            model: contactsModel

            onRemoveClicked: contactsModel.remove(index, 1)
            onRemoveAllClicked: contactsModel.clear()
            onAddClicked: contactsModel.append(usersModelEditor.getNewUser(contactsModel.count))
        }
    }
}

// category: Components
