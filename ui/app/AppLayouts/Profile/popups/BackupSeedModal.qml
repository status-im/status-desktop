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
            border.color: Theme.palette.baseColor2
            text: qsTr("Not Now")
            onClicked: root.close()
        }

        function getRandomWordNumber() {
            return Math.floor(Math.random() * 12);
        }
    }

    implicitHeight: 748
    width: 480
    header.title: qsTr("Back up your seed phrase")
    rightButtons: [ d.skipButton, nextButton, finishButton ]

    nextButton: StatusButton {
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
        enabled: d.seedStored
        onClicked: {
            root.privacyStore.removeMnemonic();
            root.close();
        }
    }

    subHeaderItem: SubheaderTabBar {
        // Count without Acknowledgements
        steps: root.itemsCount - 1
        currentIndex: root.currentIndex - 1
        visible: root.currentIndex > 0
        height: visible ? implicitHeight : 0
    }

    stackItems: [
        Acknowledgements {
            id: acknowledgment
        },
        ConfirmSeedPhrasePanel {
            id: confirmSeedPhrase
            seedPhrase: root.privacyStore.getMnemonic().split(" ")
        },
        BackupSeedStepBase {
            id: confirmFirstWord
            titleText: qsTr("Confirm word #%1 of your seed phrase").arg(d.firstRandomNo + 1)
            wordRandomNumber: d.firstRandomNo
            wordAtRandomNumber: root.privacyStore.getMnemonicWordAtIndex(d.firstRandomNo)
        },
        BackupSeedStepBase {
            id: confirmSecondWord
            titleText: qsTr("Confirm word #%1 of your seed phrase").arg(d.secondRandomNo + 1)
            wordRandomNumber: d.secondRandomNo
            wordAtRandomNumber: root.privacyStore.getMnemonicWordAtIndex(d.secondRandomNo)
        },
        ConfirmStoringSeedPhrasePanel {
            id: confirmStoringSeedPhrase
        }
    ]
}
