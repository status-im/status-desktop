import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Dialogs 1.3
import "../imports"
import "../shared"
import "../shared/status"

ModalPopup {
    id: popup
    title: qsTr("Your keys have been successfully recovered")
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
        text: qsTr("You will have to create a new code or password to re-encrypt your keys")
        font.pixelSize: 15
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
        width: 60
        height: 60
    }

    StyledText {
        id: username
        anchors.top: identicon.bottom
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: identicon.horizontalCenter
        text: onboardingModel.currentAccount.username
        font.weight: Font.Bold
        font.pixelSize: 15
    }

    Address {
        anchors.top: username.bottom
        anchors.topMargin: Style.current.halfPadding
        anchors.horizontalCenter: username.horizontalCenter
        text: onboardingModel.currentAccount.address
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
            text: qsTr("Re-encrypt your keys")

            onClicked: {
                popup.buttonClicked()
            }
        }
    }
}
