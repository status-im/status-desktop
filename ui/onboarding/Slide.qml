import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"
import "../shared"

Item {
    id: slide
    property string image: "img/chat@2x.png"
    property string title: "Truly private communication"
    property string description: "Chat over a peer-to-peer, encrypted network\n where messages can't be censored or hacked"
    property bool isFirst: false
    property bool isLast: false

    Image {
        id: img1
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 17
        fillMode: Image.PreserveAspectFit
        source: image
    }

    StyledText {
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

    Button {
        id: btnPrevious1
        width: 40
        height: 40
        anchors.top: txtDesc1.top
        anchors.bottomMargin: -2
        anchors.bottom: txtDesc1.bottom
        anchors.topMargin: -2
        anchors.right: txtDesc1.left
        anchors.rightMargin: 32
        onClicked: vwOnboarding.currentIndex--
        visible: !isFirst
        background: Rectangle {
            id: rctPrevious1
            color: Style.current.grey
            border.width: 0
            radius: 50

            SVGImage {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                source: "img/next.svg"
                width: 10
                height: 10
                mirror: true
            }
        }
    }

    StyledText {
        id: txtDesc1
        x: 772
        color: Style.current.darkGrey
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
            color: Style.current.grey
            border.width: 0
            radius: 50

            SVGImage {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                source: "img/next.svg"
                width: 10
                height: 10
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:600;width:800}
}
##^##*/
