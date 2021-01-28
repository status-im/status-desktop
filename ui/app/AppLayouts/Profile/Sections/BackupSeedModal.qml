import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    id: popup
    
    property bool showWarning: true
    property int seedWord1Idx: -1;
    property int seedWord2Idx: -1;
    property string validationError: ""

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
            text: qsTr("Back up seed phrase")
            font.pixelSize: 17
            font.bold: true
            anchors.left: parent.left
        }
        StyledText {
            anchors.top: lblTitle.bottom
            anchors.topMargin: Style.current.smallPadding
            text: qsTr("Step %1 of 3").arg(seedWord2Idx > -1 ? 3 : (seedWord1Idx > -1 ? 2 : 1))
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
                        model: profileModel.mnemonic.get.split(" ")
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
                                color: Style.current.darkGrey
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
            text: qsTr("If you lose your seed phrase you lose your data and funds")
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
            text: qsTr("If you lose access, for example by losing your phone, you can only access your keys with your seed phrase. No one, but you has your seed phrase. Write it down. Keep it safe")
            anchors.left: parent.left
            anchors.right: parent.right
        }
    }

    Item {
        visible: seedWord1Idx > -1 || seedWord2Idx > -1
        anchors.left: parent.left
        anchors.right: parent.right
        StyledText {
            id: txtChk
            text: qsTr("Check your seed phrase")
        }
        StyledText {
            text: qsTr("Word #%1").arg((seedWord2Idx > -1 ? seedWord2Idx : seedWord1Idx) + 1)
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
            placeholderText: qsTr("Enter word")
            text: ""
            validationError: popup.validationError
        }

        StyledText {
            anchors.top: txtFieldWord.bottom
            anchors.topMargin: Style.current.padding
            wrapMode: Text.WordWrap
            anchors.left: parent.left
            anchors.right: parent.right
            text: qsTr("In order to check if you have backed up your seed phrase correctly, enter the word #%1 above").arg((seedWord2Idx > -1 ? seedWord2Idx : seedWord1Idx) + 1)
            color: Style.current.secondaryText
        }

        ConfirmationDialog {
            id: removeSeedPhraseConfirm
            title: qsTr("Are you sure?")
            confirmationText: qsTr("You will not be able to see the whole seed phrase again")
            onConfirmButtonClicked: {
                profileModel.mnemonic.remove()
                popup.close();
                removeSeedPhraseConfirm.close();
            }
            onClosed: {
                seedWord1Idx = -1;
                seedWord2Idx = -1;
                txtFieldWord.text = "";
                validationError = "";
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
        color: Style.current.darkGrey
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
        wrapMode: Text.WordWrap
    }

    

    footer: StatusButton {
        text: showWarning ? 
                qsTr("Okay, continue") : 
                qsTrId("Next")
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
        anchors.bottom: parent.bottom
        onClicked: {
            if(showWarning){
                showWarning = false;
            } else {
                if(seedWord1Idx == -1){
                    seedWord1Idx = Math.floor(Math.random() * 12);
                } else {
                    if(seedWord2Idx == -1){
                        if(profileModel.mnemonic.getWord(seedWord1Idx) !== txtFieldWord.text){
                            validationError = qsTr("Wrong word");
                            return;
                        }

                        validationError = "";
                        txtFieldWord.text = "";

                        do {
                            seedWord2Idx = Math.floor(Math.random() * 12);
                        } while(seedWord2Idx == seedWord1Idx);
                    } else {
                        if(profileModel.mnemonic.getWord(seedWord2Idx) !== txtFieldWord.text){
                            validationError = qsTr("Wrong word");
                            return;
                        }

                        validationError = "";
                        txtFieldWord.text = "";
                        removeSeedPhraseConfirm.open();
                    }
                }
            }
        }
    }
}
