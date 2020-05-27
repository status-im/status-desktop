import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../imports"
import "../../../shared"

Column {
    id: walletInfoContainer
    width: 340
    spacing: 0

    Text {
        id: title
        x: 143
        y: 16
        text: qsTr("Wallet")
        anchors.top: parent.top
        anchors.topMargin: Theme.padding
        anchors.horizontalCenter: parent.horizontalCenter
        font.weight: Font.Bold
        font.pixelSize: 17
    }

    Item {
        id: walletValueTextContainer
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding
        anchors.top: title.bottom
        anchors.topMargin: Theme.padding

        TextEdit {
            id: walletAmountValue
            color: "black"
            text: qsTr("408.30 USD")
            selectByMouse: true
            cursorVisible: true
            readOnly: true
            anchors.left: tild.right
            anchors.leftMargin: 1
            font.weight: Font.Medium
            font.pixelSize: 30
        }

        Text {
            id: totalValue
            color: Theme.darkGrey
            text: "Total value"
            anchors.left: walletAmountValue.left
            anchors.leftMargin: 0
            anchors.top: walletAmountValue.bottom
            anchors.topMargin: 0
            font.weight: Font.Medium
            font.pixelSize: 13
        }
    }

    // TODO change this with a reused Component
    Rectangle {
        id: addWalletBtn
        width: 36
        height: 36
        color: Theme.blue
        radius: 50
        anchors.right: parent.right
        anchors.rightMargin: Theme.padding
        anchors.top: walletValueTextContainer.bottom
        anchors.topMargin: 0

        Text {
            id: addChatLbl
            color: "#ffffff"
            text: qsTr("+")
            anchors.verticalCenterOffset: -1
            anchors.horizontalCenterOffset: 1
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            lineHeight: 1
            fontSizeMode: Text.FixedSize
            font.bold: true
            font.pixelSize: 28
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:0.75;height:770;width:340}D{i:2;anchors_x:82}
}
##^##*/

