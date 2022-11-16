import QtQuick 2.14
import QtQuick.Controls 2.14
import AppLayouts.Chat.panels 1.0

import utils 1.0

import Storybook 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    property bool globalUtilsReady: false
    property bool mainModuleReady: false

    ListModel {
        id: model

        ListElement {
            pubKey: "0x043a7ed0e8d1012cf04"
            onlineStatus: 1
            isContact: true
            isVerified: true
            isAdmin: false
            isUntrustworthy: false
            displayName: "Mike"
            alias: ""
            localNickname: ""
            ensName: ""
            icon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/
                  nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
            colorId: 7
        }
        ListElement {
            pubKey: "0x04df12f12f12f12f1234"
            onlineStatus: 0
            isContact: true
            isVerified: true
            isAdmin: false
            isUntrustworthy: false
            displayName: "Jane"
            alias: ""
            localNickname: ""
            ensName: ""
            icon: ""
            colorId: 7
        }
        ListElement {
            pubKey: "0x04d1b7cc0ef3f470f1238"
            onlineStatus: 0
            isContact: true
            isVerified: false
            isAdmin: false
            isUntrustworthy: true
            displayName: "John"
            alias: ""
            localNickname: "Johny Johny"
            ensName: ""
            icon: ""
            colorId: 7
        }
        ListElement {
            pubKey: "0x04d1bed192343f470f1255"
            onlineStatus: 1
            isContact: true
            isVerified: true
            isAdmin: false
            isUntrustworthy: true
            displayName: ""
            alias: "meth"
            localNickname: ""
            ensName: "maria.eth"
            icon: ""
            colorId: 7
        }
    }

    // globalUtilsInst mock
    QtObject {
        function getCompressedPk(publicKey) { return "zx3sh" + publicKey }

        function getColorHashAsJson(publicKey) {
            return JSON.stringify([{colorId: 0, segmentLength: 1},
                                   {colorId: 19, segmentLength: 2}])
        }

        function isCompressedPubKey(publicKey) { return true }

        Component.onCompleted: {
            Utils.globalUtilsInst = this
            root.globalUtilsReady = true
        }
        Component.onDestruction: {
            root.globalUtilsReady = false
            Utils.globalUtilsInst = {}
        }
    }

    // mainModuleInst mock
    QtObject {
        function getContactDetailsAsJson(publicKey, getVerificationRequest) {
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
    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Loader {
            anchors.fill: parent
            active: globalUtilsReady && mainModuleReady

            sourceComponent: UserListPanel {
                usersModel: model
                messageContextMenu: null
                label: "Some label"
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText
    }
}
