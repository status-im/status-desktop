import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../imports"
import "../../../shared"
import "../../../shared/status"
import "."

ModalPopup {
    id: signPhrasePopup
    title: qsTr("Signing phrase")
    height: 390
    closePolicy: Popup.NoAutoClose

    Column {
        anchors.horizontalCenter: parent.horizontalCenter

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("This is your signing phrase")
            font.pixelSize: 17
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
            height: Style.current.padding * 3
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("You should see these 3 words before signing each transaction")
            font.pixelSize: 15
            width: 330
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            height: Style.current.padding * 4
        }

        Rectangle {
            color: Style.current.inputBackground
            height: 44
            width: signPhrasePopup.width
            anchors.left: signPhrasePopup.left
            StyledText {
                id: signingPhrase
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15
                text: walletModel.signingPhrase
            }
        }

        Item {
            height: 30
            width: parent.width
            SVGImage {
                width: 13.33
                height: 13.33
                sourceSize.height: height * 2
                sourceSize.width: width * 2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                fillMode: Image.PreserveAspectFit
                source: "../../img/exclamation_outline.svg"
            }
        }

        StyledText {
            text: qsTr("If you see a different combination, cancel the transaction and sign out")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 13
            height: 18
            color: Style.current.danger
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    footer: Item {
        width: parent.width
        height: btnRemindLater.height
        
        StatusButton {
            anchors.right: btnRemindLater.left
            anchors.rightMargin: Style.current.padding
            text: qsTr("Ok, got it")
            type: "secondary"
            onClicked: {
                appSettings.hideSignPhraseModal = true;
                close();
            }
        }


        StatusButton {
            id: btnRemindLater
            anchors.right: parent.right
            text: qsTr("Remind me later")
            onClicked: {
                hideSignPhraseModal = true;
                close();
            }
        }
    }
}