import QtQuick
import QtQuick.Controls

import AppLayouts.Profile.popups

Item {
    id: root

    Button {
        anchors.centerIn: parent
        text: "Open popup"
        onClicked: popup.open()
    }

    BackupSeedModal {
        id: popup
        mnemonic: "apple banana cat cow catalog catch category cattle dog elephant fish grape"
        visible: true
        closePolicy: Popup.NoAutoClose
        onBackupSeedphraseFinished: function(removeSeedphrase) {
            console.info("!!! BACKUP FINISHED, WANT TO REMOVE SEEDPHRASE:", removeSeedphrase)
        }
    }

    Label {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: !!popup.stack.currentItem && popup.stack.currentItem.toString().startsWith("BackupSeedphraseVerify") ?
                  "Hint: %1".arg(popup.stack.currentItem.verificationWordsMap.map((entry) => entry.seedWord))
                : ""
    }
}

// category: Popups
// status: good
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Onboarding----Desktop-Legacy?node-id=683-44710&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Onboarding----Desktop-Legacy?node-id=403-49614&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Onboarding----Desktop-Legacy?node-id=683-45255&m=dev
// https://www.figma.com/design/Lw4nPYQcZOPOwTgETiiIYo/Onboarding----Desktop-Legacy?node-id=683-45414&m=dev
