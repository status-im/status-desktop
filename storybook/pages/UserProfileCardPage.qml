import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import shared.controls.chat 1.0
import utils 1.0

SplitView {
    id: root



    property bool globalUtilsReady: false

    // globalUtilsInst mock
    QtObject {
        function getEmojiHashAsJson(publicKey) {
            return JSON.stringify(["👨🏻‍🍼", "🏃🏿‍♂️", "🌇", "🤶🏿", "🏮","🤷🏻‍♂️", "🤦🏻", "📣", "🤎", "👷🏽", "😺", "🥞", "🔃", "🧝🏽‍♂️"])
        }
        function getColorId(publicKey) { return 4 }

        function getCompressedPk(publicKey) { return "zx3sh" + publicKey }

        function getColorHashAsJson(publicKey) {
            return JSON.stringify([{4: 0, segmentLength: 1},
                                   {5: 19, segmentLength: 2}])
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


    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Loader {
            anchors.centerIn: parent
            active: root.globalUtilsReady
            sourceComponent: UserProfileCard {
                id: userProfileCard
                userName: nameInput.text
                userPublicKey: "0x1234567890"
                userBio: bioInput.text
                userImage: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAlklEQVR4nOzW0QmDQBAG4SSkl7SUQlJGCrElq9F3QdjjVhh/5nv3cFhY9vUIYQiNITSG0BhCExPynn1gWf9bx498P7/
                            nzPcxEzGExhBdJGYihtAYQlO+tUZvqrPbqeudo5iJGEJjCE15a3VtodH3q2ImYgiNITTlTdG1nUZ5a92VITQxITFiJmIIjSE0htAYQrMHAAD//+wwFVpz+yqXAAAAAElFTkSuQmCC"
                ensVerified: false
            }
        }
    }

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        SplitView.minimumWidth: 300

        ColumnLayout {
            Label {
                text: "userName" 
            }
            TextField {
                id: nameInput
                text: "John Doe"
            }
            Label {
                text: "userBio" 
            }
            TextField {
                id: bioInput
                text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non risus. Suspendisse lectus tortor, dignissim sit amet, adipiscing nec, ultricies sed, dolor."
            }
        }
    }
}