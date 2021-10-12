import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3

import utils 1.0
import "../../../../shared"
import "../../../../shared/status"
import "../stores"

ModalPopup {
    id: popup
    //% "Your keys have been successfully recovered"
    title: qsTrId("your-keys-have-been-successfully-recovered")
    height: 400

    signal buttonClicked()

    StyledText {
        id: info
        anchors.top: parent.top
        anchors.topMargin: Style.current.bigPadding
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Style.current.bigPadding
        anchors.rightMargin: Style.current.bigPadding
        //% "You will have to create a new code or password to re-encrypt your keys"
        text: qsTrId("recovery-success-text")
        font.pixelSize: 15
        color: Style.current.secondaryText
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }

    StatusImageIdenticon {
        id: identicon
        source: OnboardingStore.currentAccount.identicon
        anchors.top: info.bottom
        anchors.topMargin: Style.current.bigPadding
        anchors.horizontalCenter: parent.horizontalCenter
        width: 60
        height: 60
    }

    StyledText {
        id: username
        anchors.top: identicon.bottom
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: identicon.horizontalCenter
        text: OnboardingStore.currentAccount.username
        font.weight: Font.Bold
        font.pixelSize: 15
    }

    Address {
        anchors.top: username.bottom
        anchors.topMargin: Style.current.halfPadding
        anchors.horizontalCenter: username.horizontalCenter
        text: OnboardingStore.currentAccount.address
        width: 120
    }

    footer: Item {
        width: parent.width
        height: reencryptBtn.height

        StatusButton {
            id: reencryptBtn
            anchors.bottom: parent.bottom
            anchors.topMargin: Style.current.padding
            anchors.right: parent.right
            //% "Re-encrypt your keys"
            text: qsTrId("re-encrypt-key")

            onClicked: {
                popup.buttonClicked()
            }
        }
    }
}
