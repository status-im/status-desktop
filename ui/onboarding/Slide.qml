import QtQuick 2.0
import QtQuick.Controls 2.4
import "../imports"

Item {
    id: slide
    property string image: "img/chat@2x.jpg"
    property string title: "Truly private communication"
    property string description: "Chat over a peer-to-peer, encrypted network\n where messages can't be censored or hacked"
    property bool isLast: false

    Image {
        id: img1
        anchors.horizontalCenter: parent.horizontalCenter
        sourceSize.width: 414
        sourceSize.height: 414
        anchors.topMargin: 17
        fillMode: Image.PreserveAspectFit
        source: image
    }

    Text {
        id: txtTitle1
        text: title
        anchors.right: parent.right
        anchors.rightMargin: 177
        anchors.left: parent.left
        anchors.leftMargin: 177
        anchors.top: img1.bottom
        anchors.topMargin: 44
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
        color: Theme.darkGrey
        text: description
        font.weight: Font.Normal
        style: Text.Normal
        anchors.horizontalCenterOffset: 0
        anchors.top: txtTitle1.bottom
        anchors.topMargin: 14
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 15
    }

    Button {
        id: btnNext1
        width: 40
        height: 40
        anchors.top: txtDesc1.top
        anchors.bottomMargin: -2
        anchors.bottom: txtDesc1.bottom
        anchors.topMargin: -2
        anchors.left: txtDesc1.right
        anchors.leftMargin: 32
        onClicked: vwOnboarding.currentIndex++
        visible: !isLast
        background: Rectangle {
            id: rctNext1
            color: Theme.grey
            border.width: 0
            radius: 50

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                source: "img/next.svg"
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:800}
}
##^##*/
