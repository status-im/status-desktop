import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import AppLayouts.Onboarding2.pages 1.0

Item {
    id: root

    QtObject {
        id: d
        readonly property string mnemonic: "apple banana cat cow catalog catch category cattle dog elephant fish grape"
        readonly property int numWordsToVerify: 4
    }

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: backupSeedIntroPage
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.BackButton
        enabled: stack.depth > 1 && !stack.busy
        cursorShape: undefined // fall thru
        onClicked: stack.pop()
    }

    StatusBackButton {
        width: 44
        height: 44
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.padding
        opacity: stack.depth > 1 && !stack.busy ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 100 } }
        onClicked: stack.pop()
    }

    Label {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        text: !!stack.currentItem && stack.currentItem instanceof BackupSeedphraseVerify ?
                  "Hint: %1".arg(stack.currentItem.verificationWordsMap.map((entry) => entry.seedWord))
                : ""
    }

    Connections {
        id: mainHandler
        target: stack.currentItem
        ignoreUnknownSignals: true

        function onBackupSeedphraseRequested() {
            stack.push(backupSeedAcksPage)
        }

        function onBackupSeedphraseContinue() {
            stack.push(backupSeedRevealPage)
        }

        function onBackupSeedphraseConfirmed() {
            stack.push(backupSeedVerifyPage)
        }

        function onBackupSeedphraseVerified() {
            stack.push(backupSeedOutroPage)
        }

        function onBackupSeedphraseRemovalConfirmed() {
            console.warn("!!! FLOW FINISHED; RESTART")
            stack.pop(null)
        }
    }

    Component {
        id: backupSeedIntroPage
        BackupSeedphraseIntro {
            onBackupSeedphraseRequested: console.warn("!!! SEED BACKUP REQUESTED")
        }
    }

    Component {
        id: backupSeedAcksPage
        BackupSeedphraseAcks {
            onBackupSeedphraseContinue: console.warn("!!! SEED ACKED")
        }
    }

    Component {
        id: backupSeedRevealPage
        BackupSeedphraseReveal {
            mnemonic: d.mnemonic
            onBackupSeedphraseConfirmed: console.warn("!!! SEED CONFIRMED")
        }
    }

    Component {
        id: backupSeedVerifyPage
        BackupSeedphraseVerify {
            mnemonic: d.mnemonic
            countToVerify: d.numWordsToVerify
            onBackupSeedphraseVerified: console.warn("!!! ALL VERIFIED")
        }
    }

    Component {
        id: backupSeedOutroPage
        BackupSeedphraseOutro {
            onBackupSeedphraseRemovalConfirmed: console.warn("!!! SEED REMOVAL CONFIRMED")
        }
    }
}

// category: Onboarding
// status: good
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=944-40428&node-type=instance&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=944-40730&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=522-36751&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=522-37165&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=783-33987&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=944-44817&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=783-34183&node-type=frame&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Desktop-Onboarding-Redesign?node-id=944-44231&node-type=frame&m=dev
