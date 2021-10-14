import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import "../../../../shared"
import "../../../../shared/popups"
import "../../../../shared/status"
import "."

// TODO: replace with StatusModal
ModalPopup {
    id: signPhrasePopup
    title: qsTrId("signing-phrase")
    height: 390
    closePolicy: Popup.NoAutoClose

    property string signingPhraseText: ""
    signal remindLaterButtonClicked()

    Column {
        anchors.left: parent.left
        anchors.right: parent.right

        StyledText {
            height: (Style.current.padding * 3)
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 17
            font.weight: Font.Bold
            text: qsTrId("this-is-you-signing")
        }

        StyledText {
            width: 330
            height: Style.current.padding * 4
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 15
            wrapMode: Text.WordWrap
            text: qsTrId("three-words-description")
        }

        Rectangle {
            width: parent.width
            height: 44
            color: Style.current.inputBackground
            StyledText {
                id: signingPhrase
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15
                text: signPhrasePopup.signingPhraseText
            }
        }

        Item {
            width: parent.width
            height: 30
            SVGImage {
                width: 13.33
                height: 13.33
                sourceSize.height: (height * 2)
                sourceSize.width: (width * 2)
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                fillMode: Image.PreserveAspectFit
                source: Style.svg("exclamation_outline")
            }
        }

        StyledText {
            width: parent.width
            height: 18
            anchors.horizontalCenter: parent.horizontalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 13
            color: Style.current.danger
            //% "If you see a different combination, cancel the transaction and sign out"
            text: qsTrId("three-words-description-2")
        }
    }

    footer: Item {
        width: parent.width
        height: btnRemindLater.height
        StatusButton {
            anchors.right: btnRemindLater.left
            anchors.rightMargin: Style.current.padding
            type: "secondary"
            //% "Ok, got it"
            text: qsTrId("ens-got-it")
            onClicked: {
                //TOOD improve this to not use dynamic scoping
                appSettings.hideSignPhraseModal = true;
                close();
            }
        }


        StatusButton {
            id: btnRemindLater
            anchors.right: parent.right
            //% "Remind me later"
            text: qsTrId("remind-me-later")
            onClicked: {
                signPhrasePopup.remindLaterButtonClicked();
            }
        }
    }
}
