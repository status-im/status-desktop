import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../shared"

Page {
    property alias btnExistingKey: btnExistingKey
    property alias btnGenKey: btnGenKey

    Image {
        id: img1
        anchors.horizontalCenter: parent.horizontalCenter
        sourceSize.width: 160
        sourceSize.height: 160
        anchors.topMargin: 24
        anchors.top: parent.top
        fillMode: Image.PreserveAspectFit
        source: "img/key@2x.png"
    }

    Text {
        id: txtTitle1
        text: qsTr("Get your keys")
        anchors.right: parent.right
        anchors.rightMargin: 177
        anchors.left: parent.left
        anchors.leftMargin: 177
        anchors.top: img1.bottom
        anchors.topMargin: 16
        font.letterSpacing: -0.2
        font.weight: Font.Bold
        lineHeight: 1
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        transformOrigin: Item.Center
        font.bold: true
        font.pixelSize: 22
        font.kerning: true

    }

    Text {
        id: txtDesc1
        x: 772
        color: "#939BA1"
        text: qsTr("A set of keys controls your account. Your keys live on\nyour device, so only you can use them.")
        horizontalAlignment: Text.AlignHCenter
        font.weight: Font.Normal
        style: Text.Normal
        anchors.horizontalCenterOffset: 0
        anchors.top: txtTitle1.bottom
        anchors.topMargin: 14
        font.bold: true
        font.family: "Inter"
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 15
    }

    StyledButton {
        id: btnExistingKey
        label: "Access existing key"
        anchors.top: txtDesc1.bottom
        anchors.topMargin: 87
        anchors.horizontalCenter: parent.horizontalCenter
        // onClicked: logic.generateAddresses()
        width: 142
        height: 44
    }

    StyledButton {
        id: btnGenKey
        width: 194
        height: 44
        anchors.top: btnExistingKey.bottom
        anchors.topMargin: 19
        anchors.horizontalCenter: parent.horizontalCenter
        label: "I'm new, generate me a key"
        background: Rectangle {color: "transparent"}
        onClicked: onboardingLogic.generateAddresses()
    }

}



/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:720}
}
##^##*/
