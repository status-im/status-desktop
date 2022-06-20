import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Controls 0.1

import shared.panels 1.0
import shared.popups 1.0
import "../stores"

// TODO: replace with StatusModal
ModalPopup {
    id: signPhrasePopup

    signal remindLaterClicked()
    signal acceptClicked()

    //% "Signing phrase"
    title: qsTrId("signing-phrase")
    height: Style.dp(390)
    closePolicy: Popup.NoAutoClose

    Column {
        anchors.left: parent.left
        anchors.right: parent.right

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            //% "This is your signing phrase"
            text: qsTrId("this-is-you-signing")
            font.pixelSize: Style.dp(17)
            font.weight: Font.Bold
            horizontalAlignment: Text.AlignHCenter
            height: Style.current.padding * 3
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            //% "You should see these 3 words before signing each transaction"
            text: qsTrId("three-words-description")
            font.pixelSize: Style.current.primaryTextFontSize
            width: Style.dp(330)
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            height: Style.current.padding * 4
        }

        Rectangle {
            color: Style.current.inputBackground
            height: Style.dp(44)
            width: parent.width
            StyledText {
                id: signingPhrase
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: Style.current.primaryTextFontSize
                text: RootStore.signingPhrase
            }
        }

        Item {
            height: Style.dp(30)
            width: parent.width
            SVGImage {
                width: Style.dp(13)
                height: Style.dp(13)
                sourceSize.height: height * 2
                sourceSize.width: width * 2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                fillMode: Image.PreserveAspectFit
                source: Style.svg("exclamation_outline")
            }
        }

        StyledText {
            //% "If you see a different combination, cancel the transaction and sign out"
            text: qsTrId("three-words-description-2")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            font.pixelSize: Style.current.additionalTextSize
            height: Style.dp(18)
            color: Style.current.danger
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    footer: Item {
        width: parent.width
        height: btnRemindLater.height

        StatusFlatButton {
            anchors.right: btnRemindLater.left
            anchors.rightMargin: Style.current.padding
            //% "Ok, got it"
            text: qsTrId("ens-got-it")
            onClicked: {
                acceptClicked()
                close()
            }
        }

        StatusButton {
            id: btnRemindLater
            anchors.right: parent.right
            //% "Remind me later"
            text: qsTrId("remind-me-later")
            onClicked: {
                remindLaterClicked()
                close()
            }
        }
    }
}
