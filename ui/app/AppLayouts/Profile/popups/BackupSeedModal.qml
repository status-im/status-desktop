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

StatusModal {
    id: popup
    width: Style.dp(480)
    height: Style.dp(748)
    header.title: qsTr("Back up your seed phrase")

    property var privacyStore

    rightButtons: [
        StatusFlatButton {
            text: "Not Now"
            visible: (stack.currentIndex === 0)
            border.color: Theme.palette.baseColor2
            onClicked: {
                popup.close();
            }
        },
        StatusButton {
            enabled: {
                if (stack.currentIndex === 0) {
                    return acknowledgment.allAccepted;
                } else {
                    switch (backUp.bar.currentIndex) {
                    case 0:
                        return !backUp.seedHidden;
                    case 1:
                        return backUp.validFirstSeedWord;
                    case 2:
                        return backUp.validSecondSeedWord;
                    case 3:
                        return backUp.seedStored;
                    default:
                        return true;
                    }
                }
            }
            text: {
                if (stack.currentIndex === 1) {
                    if (backUp.bar.currentIndex === 0) {
                        return qsTr("Confirm Seed Phrase");
                    } else if (backUp.bar.currentIndex === 1 ||
                               backUp.bar.currentIndex === 2) {
                        return qsTr("Continue");
                    } else {
                        return qsTr("Complete & Delete My Seed Phrase");
                    }
                } else {
                    return qsTr("Confirm Seed Phrase");
                }
            }
            onClicked: {
                if (stack.currentIndex === 0) {
                    stack.currentIndex = 1;
                } else {
                    switch (backUp.bar.currentIndex) {
                        case 0:
                        case 1:
                        case 2:
                            backUp.bar.currentIndex++;
                            break;
                        case 3:
                            popup.privacyStore.removeMnemonic();
                            popup.close();
                            break;
                    }
                }
            }
        }
    ]

    leftButtons: [
        StatusRoundButton {
            visible: (stack.currentIndex === 1)
            icon.name: "arrow-right"
            rotation: 180
            onClicked: {
                if (backUp.bar.currentIndex === 0) {
                    stack.currentIndex = 0;
                } else {
                    backUp.bar.currentIndex--;
                }
            }
        }
    ]

    contentItem: StackLayout {
        id: stack
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.top: parent.top
        anchors.topMargin: Style.dp(80)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.dp(88)
        Acknowledgements { id: acknowledgment }
        Backup { id: backUp; privacyStore: popup.privacyStore }
    }
}
