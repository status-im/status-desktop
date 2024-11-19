import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import Models 1.0
import Storybook 1.0

import SortFilterProxyModel 0.2

import utils 1.0
import shared.stores 1.0

import AppLayouts.Onboarding2.pages 1.0

import AppLayouts.Profile.popups 1.0
import AppLayouts.Profile.stores 1.0

Item {
    id: root

    // KeycardCreatePinPage {
    //     anchors.fill: parent
    // }

    // KeycardEnterPinPage {
    //     anchors.fill: parent
    //     existingPin: "111111"
    //     remainingAttempts: 5
    //     onKeycardPinEntered: (pin) => console.warn("!!! PIN:", pin)
    //     onReloadKeycardRequested: {
    //         console.warn("!!! RELOAD KEYCARD")
    //         remainingAttempts = 3
    //         state = "entering"
    //     }
    //     onKeycardFactoryResetRequested: {
    //         console.warn("!!! FACTORY RESET KEYCARD")
    //         remainingAttempts = 3
    //         state = "entering"
    //     }
    // }

    // BackupSeedModal {
    //     anchors.centerIn: parent
    //     visible: true
    //     closePolicy: Popup.NoAutoClose
    //     privacyStore: PrivacyStore {
    //         readonly property var words: ["apple", "banana", "cat", "cow", "catalog", "catch", "category", "cattle", "dog", "elephant", "fish", "grape"]

    //         function getMnemonic() {
    //             return words.join(" ")
    //         }

    //         function getMnemonicWordAtIndex(index) {
    //             return words[index]
    //         }

    //         function mnemonicWasShown() {}

    //         function removeMnemonic() {}
    //     }
    // }

    // BackupSeedphraseReveal {
    //     anchors.fill: parent
    //     seedWords: ["apple", "banana", "cat", "cow", "catalog", "catch", "category", "cattle", "dog", "elephant", "fish", "grape"]
    //     onBackupSeedphraseConfirmed: {
    //         console.warn(SQUtils.Utils.nSamples(4, 12))
    //     }
    // }

    // BackupSeedphraseVerify {
    //     anchors.fill: parent
    //     readonly property var words: ["apple", "banana", "cat", "cow", "catalog", "catch", "category", "cattle", "dog", "elephant", "fish", "grape"]

    //     seedWordsToVerify: {
    //         const indexes = SQUtils.Utils.nSamples(4, words.length)
    //         let result = []
    //         for (const i of indexes) {
    //             result.push({seedWordNumber: i+1, seedWord: words[i]})
    //         }
    //         console.warn("Seed indexes:", indexes)
    //         return result
    //     }
    //     onBackupSeedphraseVerified: console.warn("!!! ALL VERIFIED")
    // }

    // BackupSeedphraseOutro {
    //     anchors.fill: parent
    // }

    // LoginPage {
    //     anchors.fill: parent
    // }

    // LoginBySyncingPage {
    //     anchors.fill: parent
    //     validateConnectionString: (stringValue) => !Number.isNaN(parseInt(stringValue))
    //     onSyncProceedWithConnectionString: (connectionString) => console.warn("!!! PROCEED:", connectionString)
    // }

    // CreateProfilePage {
    //     anchors.fill: parent
    // }
}

// category: _
// status: good
