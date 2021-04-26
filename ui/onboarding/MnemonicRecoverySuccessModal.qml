import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3
import "../imports"
import "../shared"
import "../shared/status"

ModalPopup {
    id: popup
    //% "Your keys have been successfully recovered"
    title: qsTrId("your-keys-have-been-successfully-recovered")
    height: 400 * scaleAction.factor

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
        font.pixelSize: 15 * scaleAction.factor
        color: Style.current.secondaryText
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }

    StatusImageIdenticon {
        id: identicon
        source: onboardingModel.currentAccount.identicon
        anchors.top: info.bottom
        anchors.topMargin: Style.current.bigPadding
        anchors.horizontalCenter: parent.horizontalCenter
        width: 60 * scaleAction.factor
        height: 60 * scaleAction.factor
    }

    StyledText {
        id: username
        anchors.top: identicon.bottom
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: identicon.horizontalCenter
        text: onboardingModel.currentAccount.username
        font.weight: Font.Bold
        font.pixelSize: 15 * scaleAction.factor
    }

    Address {
        anchors.top: username.bottom
        anchors.topMargin: Style.current.halfPadding
        anchors.horizontalCenter: username.horizontalCenter
        text: onboardingModel.currentAccount.address
        width: 120 * scaleAction.factor
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
