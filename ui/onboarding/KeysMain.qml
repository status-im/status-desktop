import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../shared"
import "../imports"

Page {
    id: page
    property alias btnExistingKey: btnExistingKey
    property alias btnGenKey: btnGenKey
    
    Item {
        id: container
        width: 425
        height: {
            let h = 0
            const children = this.children
            Object.keys(children).forEach(function (key) {
                const child = children[key]
                h += child.height + Theme.padding
            })
            return h
        }

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        Image {
            id: keysImg
            anchors.horizontalCenter: parent.horizontalCenter
            sourceSize.width: 160
            sourceSize.height: 160
            anchors.top: parent.top
            fillMode: Image.PreserveAspectFit
            source: "img/key@2x.png"
        }

        Text {
            id: txtTitle1
            text: qsTr("Get your keys")
            anchors.topMargin: Theme.padding
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: keysImg.bottom
            font.letterSpacing: -0.2
            font.pixelSize: 22
        }

        Text {
            id: txtDesc1
            color: Theme.darkGrey
            text: qsTr("A set of keys controls your account. Your keys live on your device, so only you can use them.")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: txtTitle1.bottom
            anchors.topMargin: Theme.padding
            font.pixelSize: 15
        }


        StyledButton {
            id: btnGenKey
            height: 44
            anchors.top: txtDesc1.bottom
            anchors.topMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter
            label: "I'm new, generate keys"
        }

        StyledButton {
            id: btnExistingKey
            label: "Access existing key"
            anchors.top: btnGenKey.bottom
            anchors.topMargin: Theme.padding
            anchors.horizontalCenter: parent.horizontalCenter
            height: 44
            background: Rectangle {color: "transparent"}
        }
    }
}


/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";formeditorZoom:0.8999999761581421;height:760;width:1080}
}
##^##*/
