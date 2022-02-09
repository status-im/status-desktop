import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import utils 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.controls 1.0

import StatusQ.Controls 0.1

// TODO: replace with StatusModal
ModalPopup {
    id: popup

    property var privacyStore

    property bool showWarning: true
    property int seedWord1Idx: -1;
    property int seedWord2Idx: -1;
    property string validationError: ""

    focus: visible

    onOpened: {
        seedWord1Idx = -1;
        seedWord2Idx = -1;
        txtFieldWord.text = "";
        validationError = "";
    }

    header: Item {
        height: 50
        StyledText {
            id: lblTitle
            //% "Back up seed phrase"
            text: qsTrId("back-up-seed-phrase")
            font.pixelSize: 17
            font.bold: true
            anchors.left: parent.left
        }
        StyledText {
            anchors.top: lblTitle.bottom
            anchors.topMargin: Style.current.smallPadding
            //% "Step %1 of 3"
            text: qsTrId("step--1-of-3").arg(seedWord2Idx > -1 ? 3 : (seedWord1Idx > -1 ? 2 : 1))
            font.pixelSize: 14
            anchors.left: parent.left
        }
    }

    Loader {
        active: popup.opened && !showWarning && seedWord1Idx == -1
        width: parent.width
        height: item ? item.height : 0

        sourceComponent:  Component {
            id: seedComponent
            Item {
                id: seed
                width: parent.width
                height: children[0].height

                Rectangle {
                    id: wrapper
                    property int len: mnemonicRepeater.count
                    anchors.top: parent.top
                    anchors.topMargin: Style.current.padding
                    height: 40 * (len / 2)
                    width: 350
                    border.width: 1
                    color: Style.current.background
                    border.color: Style.current.border
                    radius: Style.current.radius
                    anchors.horizontalCenter: parent.horizontalCenter

                    Repeater {
                        id: mnemonicRepeater
                        model: popup.privacyStore.getMnemonic().split(" ")
                        Rectangle {
                            id: word
                            height: 40
                            width: 175
                            color: "transparent"
                            anchors.top: (index == 0
                                          || index == (wrapper.len / 2)) ? parent.top : parent.children[index - 1].bottom
                            anchors.left: (index < (wrapper.len / 2)) ? parent.left : undefined
                            anchors.right: (index >= wrapper.len / 2) ? parent.right : undefined

                            Rectangle {
                                width: 1
                                height: parent.height
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                                anchors.rightMargin: 175
                                color: Style.current.inputBackground
                                visible: index >= wrapper.len / 2
                            }

                            StyledText {
                                id: count
                                text: index + 1
                                color: Style.current.secondaryText
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: Style.current.smallPadding
                                anchors.left: parent.left
                                anchors.leftMargin: Style.current.bigPadding
                                font.pixelSize: 15
                            }

                            StyledTextEdit {
                                text: modelData
                                font.pixelSize: 15
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: Style.current.smallPadding
                                anchors.left: count.right
                                anchors.leftMargin: Style.current.padding
                                selectByMouse: true
                                readOnly: true
                            }
                        }
                    }
                }
            }
        }
    }

    Item {
        visible: showWarning
        anchors.left: parent.left
        anchors.right: parent.right
        StyledText {
            id: lblLoseSeed
            //% "If you lose your seed phrase you lose your data and funds"
            text: qsTrId("your-data-belongs-to-you")
            wrapMode: Text.WordWrap
            font.pixelSize: 17
            font.bold: true
            anchors.left: parent.left
            anchors.right: parent.right
        }
        StyledText {
            anchors.top: lblLoseSeed.bottom
            anchors.topMargin: Style.current.smallPadding
            wrapMode: Text.WordWrap
            //% "If you lose access, for example by losing your phone, you can only access your keys with your seed phrase. No one, but you has your seed phrase. Write it down. Keep it safe"
            text: qsTrId("your-data-belongs-to-you-description")
            anchors.left: parent.left
            anchors.right: parent.right
        }
    }

    Item {
        id: textInput
        visible: seedWord1Idx > -1 || seedWord2Idx > -1
        anchors.left: parent.left
        anchors.right: parent.right
        focus: visible
        onActiveFocusChanged: {
            if (activeFocus)
                txtFieldWord.forceActiveFocus(Qt.MouseFocusReason)
        }
        Keys.onReturnPressed: function(event) {
            confirmButton.clicked()
        }

        StyledText {
            id: txtChk
            //% "Check your seed phrase"
            text: qsTrId("check-your-recovery-phrase")
        }
        StyledText {
            //% "Word #%1"
            text: qsTrId("word---1").arg((seedWord2Idx > -1 ? seedWord2Idx : seedWord1Idx) + 1)
            anchors.left: txtChk.right
            anchors.leftMargin: 5
            color: Style.current.secondaryText
        }

        Input {
            id: txtFieldWord
            anchors.top: txtChk.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: txtChk.left
            anchors.right: parent.right
            //% "Enter word"
            placeholderText: qsTrId("enter-word")
            text: ""
            validationError: popup.validationError
        }

        StyledText {
            anchors.top: txtFieldWord.bottom
            anchors.topMargin: Style.current.padding
            wrapMode: Text.WordWrap
            anchors.left: parent.left
            anchors.right: parent.right
            //% "In order to check if you have backed up your seed phrase correctly, enter the word #%1 above"
            text: qsTrId("in-order-to-check-if-you-have-backed-up-your-seed-phrase-correctly--enter-the-word---1-above").arg((seedWord2Idx > -1 ? seedWord2Idx : seedWord1Idx) + 1)
            color: Style.current.secondaryText
        }

        Component {
            id: removeSeedPhraseConfirmDialogComponent
            ConfirmationDialog {
                id: confirmPopup
                //% "Are you sure?"
                header.title: qsTrId("are-you-sure?")
                //% "You will not be able to see the whole seed phrase again"
                confirmationText: qsTrId("are-you-sure-description")
                onConfirmButtonClicked: {
                    popup.privacyStore.removeMnemonic()
                    popup.close();
                    confirmPopup.close();
                }
                onClosed: {
                    destroy();
                }
            }
        }
    }

    StyledText {
        id: confirmationsInfo
        visible: !showWarning && seedWord1Idx == -1
        //% "With this 12 words you can always get your key back. Write it down. Keep it safe, offline, and separate from this device."
        text: qsTrId(
                  "with-this-12-words-you-can-always-get-your-key-back.-write-it-down.-keep-it-safe,-offline,-and-separate-from-this-device.")
        font.pixelSize: 14
        font.weight: Font.Medium
        color: Style.current.secondaryText
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
        wrapMode: Text.WordWrap
    }



    footer: StatusButton {
        id: confirmButton
        text: showWarning ?
                //% "Okay, continue"
                qsTrId("ok-continue") :
                //% "Next"
                qsTrId("next")
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
        anchors.bottom: parent.bottom
        focus: !textInput.visible
        Keys.onReturnPressed: function(event) {
            confirmButton.clicked()
        }
        onClicked: {
            if(showWarning){
                showWarning = false;
            } else {
                if(seedWord1Idx == -1){
                    seedWord1Idx = Math.floor(Math.random() * 12);
                } else {
                    if(seedWord2Idx == -1){
                        if(popup.privacyStore.getMnemonicWordAtIndex(seedWord1Idx) !== txtFieldWord.text){
                            //% "Wrong word"
                            validationError = qsTrId("wrong-word");
                            return;
                        }

                        validationError = "";
                        txtFieldWord.text = "";

                        do {
                            seedWord2Idx = Math.floor(Math.random() * 12);
                        } while(seedWord2Idx == seedWord1Idx);
                    } else {
                        if(popup.privacyStore.getMnemonicWordAtIndex(seedWord2Idx) !== txtFieldWord.text){
                            //% "Wrong word"
                            validationError = qsTrId("wrong-word");
                            return;
                        }

                        validationError = "";
                        txtFieldWord.text = "";
                        Global.openPopup(removeSeedPhraseConfirmDialogComponent);
                    }
                }
            }
        }
    }
}
