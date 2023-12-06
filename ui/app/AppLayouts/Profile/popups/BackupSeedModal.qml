import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.14

import utils 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.controls 1.0

import StatusQ.Core 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import "backupseed"

StatusStackModal {
    id: root

    property var privacyStore

    onCurrentIndexChanged: {
        //StatusAnimatedStack doesn't handle well items' visibility,
        //keeping this solution for now until #8024 is fixed
        if (currentIndex === 2) {
            confirmFirstWord.forceInputFocus();
        } else if (currentIndex === 3) {
            confirmSecondWord.forceInputFocus();
        }
    }

    QtObject {
        id: d

        readonly property int firstRandomNo: getRandomWordNumber()
        readonly property int secondRandomNo: {
            var num = firstRandomNo;
            while (num === firstRandomNo) {
                num = getRandomWordNumber();
            }
            return num;
        }

        readonly property alias seedHidden: confirmSeedPhrase.hideSeed
        readonly property alias seedStored: confirmStoringSeedPhrase.seedStored

        readonly property alias validFirstSeedWord: confirmFirstWord.inputValid
        readonly property alias validSecondSeedWord: confirmSecondWord.inputValid

        readonly property Item skipButton: StatusButton {
            visible: currentIndex === 0
            normalColor: "transparent"
            borderColor: Theme.palette.baseColor2
            text: qsTr("Not Now")
            onClicked: root.close()
        }

        function getRandomWordNumber() {
            return Math.floor(Math.random() * 12);
        }
    }

    implicitHeight: 748
    width: 480
    headerSettings.title: qsTr("Back up your seed phrase")
    rightButtons: [ d.skipButton, nextButton, finishButton ]

    nextButton: StatusButton {
        id: nextButton
        objectName: "BackupSeedModal_nextButton"
        enabled: {
            switch (root.currentIndex) {
            case 0:
                return acknowledgment.allAccepted;
            case 1:
                return !d.seedHidden;
            case 2:
                return d.validFirstSeedWord;
            case 3:
                return d.validSecondSeedWord;
            default:
                return true;
            }
        }
        text: {
            switch (root.currentIndex) {
            case 0:
            case 1:
                return qsTr("Confirm Seed Phrase");
            case 2:
            case 3:
                return qsTr("Continue");
            default:
                return "";
            }
        }
        onClicked: root.currentIndex++
    }

    finishButton: StatusButton {
        text: qsTr("Complete & Delete My Seed Phrase")
        objectName: "BackupSeedModal_completeAndDeleteSeedPhraseButton"
        enabled: d.seedStored
        onClicked: {
            root.privacyStore.removeMnemonic();
            root.close();
        }
    }

    // split subHeaderPadding into clip and non-clip parts
    subHeaderPadding: 8
    readonly property int nonClipSubHeaderPadding: 8

    subHeaderItem: SubheaderTabBar {
        // Count without Acknowledgements
        steps: root.itemsCount - 1
        currentIndex: root.currentIndex - 1
        visible: root.currentIndex > 0
        height: visible ? implicitHeight + nonClipSubHeaderPadding - spacing : 0

        Item {
            Layout.fillHeight: true
        }
    }

    stackItems: [
        Acknowledgements {
            id: acknowledgment
        },
        ConfirmSeedPhrasePanel {
            id: confirmSeedPhrase
            seedPhrase: root.privacyStore.getMnemonic().split(" ")
            privacyStore: root.privacyStore
        },
        BackupSeedStepBase {
            id: confirmFirstWord
            objectName: "BackupSeedModal_BackupSeedStepBase_confirmFirstWord"
            titleText: qsTr("Confirm word #%1 of your seed phrase").arg(d.firstRandomNo + 1)
            wordRandomNumber: d.firstRandomNo
            wordAtRandomNumber: root.privacyStore.getMnemonicWordAtIndex(d.firstRandomNo)
            onEnterPressed: {
                nextButton.clicked();
            }
        },
        BackupSeedStepBase {
            id: confirmSecondWord
            objectName: "BackupSeedModal_BackupSeedStepBase_confirmSecondWord"
            titleText: qsTr("Confirm word #%1 of your seed phrase").arg(d.secondRandomNo + 1)
            wordRandomNumber: d.secondRandomNo
            wordAtRandomNumber: root.privacyStore.getMnemonicWordAtIndex(d.secondRandomNo)
        },
        ConfirmStoringSeedPhrasePanel {
            id: confirmStoringSeedPhrase
        }
    ]
}
