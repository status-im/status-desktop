import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Popups 0.1
import StatusQ.Controls 0.1

StatusModal {
    id: signPhrasePopup
    anchors.centerIn: parent
    height: 390
    closePolicy: Popup.NoAutoClose

    header.title: qsTrId("signing-phrase")
    property string signingPhraseText: ""
    signal remindLaterButtonClicked()

    contentItem: Item {
        width: signPhrasePopup.width
        height: childrenRect.height
        Column {
            anchors.top: parent.top
            anchors.topMargin: 16
            width: parent.width - 32
            anchors.horizontalCenter: parent.horizontalCenter

            StatusBaseText {
                height: (Style.current.padding * 3)
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 17
                font.weight: Font.Bold
                text: qsTrId("this-is-you-signing")
            }

            StatusBaseText {
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
                color: Theme.palette.baseColor2
                StatusBaseText {
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
                StatusIcon {
                    icon: "warning"
                    width: 13.33
                    height: 13.33
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    color: Theme.palette.dangerColor1
                }
            }

            StatusBaseText {
                width: parent.width
                height: 18
                anchors.horizontalCenter: parent.horizontalCenter
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 13
                color: Theme.palette.dangerColor1
                //% "If you see a different combination, cancel the transaction and sign out"
                text: qsTrId("three-words-description-2")
            }
        }
    }

    rightButtons: [
        StatusFlatButton {
            //% "Ok, got it"
            text: qsTrId("ens-got-it")
            onClicked: {
                //TOOD improve this to not use dynamic scoping
                localAccountSensitiveSettings.hideSignPhraseModal = true;
                close();
            }
        },
        StatusButton {
            //% "Remind me later"
            text: qsTrId("remind-me-later")
            onClicked: {
                signPhrasePopup.remindLaterButtonClicked();
            }
        }
    ]
}
