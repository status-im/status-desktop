import QtQuick 2.12
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    property string privateKey

    id: popup
    height: 504

    title: qsTr("Transfer ownership")

    onClosed: {
        popup.destroy();
    }

    Item {
        anchors.fill: parent

        Input {
            id: pKeyInput
            label: qsTr("Community private key")
            text: popup.privateKey
            copyToClipboard: popup.privateKey
        }

        StyledText {
            id: infoText1
            text: qsTr("You should keep it safe and only share it with people you trust to take ownership of your community")
            anchors.top: pKeyInput.bottom
            wrapMode: Text.WordWrap
            anchors.topMargin: Style.current.padding
            width: parent.width
            font.pixelSize: 13
            color: Style.current.secondaryText
        }

        StyledText {
            id: infoText2
            text: qsTr("You can also use this key to import your community on another device")
            anchors.top: infoText1.bottom
            wrapMode: Text.WordWrap
            anchors.topMargin: Style.current.bigPadding
            width: parent.width
            font.pixelSize: 13
            color: Style.current.secondaryText
        }
    }

    footer: StatusRoundButton {
        id: btnBack
        anchors.left: parent.left
        icon.name: "arrow-right"
        icon.width: 20
        icon.height: 16
        rotation: 180
        onClicked: {
            popup.close()
        }
    }
}

