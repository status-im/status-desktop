import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import utils 1.0

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import shared.panels 1.0
import shared.popups 1.0
import "../stores"

// TODO: replace with StatusModal
ModalPopup {
    id: signPhrasePopup

    signal remindLaterClicked()
    signal acceptClicked()

    title: qsTr("Signing phrase")
    height: 390
    closePolicy: Popup.NoAutoClose

    Column {
        anchors.left: parent.left
        anchors.right: parent.right

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("This is your signing phrase")
            font.pixelSize: 17
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
            height: Theme.padding * 3
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("You should see these 3 words before signing each transaction")
            font.pixelSize: 15
            width: 330
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            height: Theme.padding * 4
        }

        Rectangle {
            color: Theme.palette.baseColor2
            height: 44
            width: parent.width
            StyledText {
                id: signingPhrase
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15
                text: RootStore.signingPhrase
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
                source: Theme.svg("exclamation_outline")
            }
        }

        StyledText {
            text: qsTr("If you see a different combination, cancel the transaction and sign out")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            font.pixelSize: 13
            height: 18
            color: Theme.palette.dangerColor1
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    footer: Item {
        width: parent.width
        height: btnRemindLater.height

        StatusFlatButton {
            objectName: "signPhraseModalOkButton"
            anchors.right: btnRemindLater.left
            anchors.rightMargin: Theme.padding
            text: qsTr("Ok, got it")
            onClicked: {
                acceptClicked()
                close()
            }
        }

        StatusButton {
            id: btnRemindLater
            anchors.right: parent.right
            text: qsTr("Remind me later")
            onClicked: {
                remindLaterClicked()
                close()
            }
        }
    }
}
