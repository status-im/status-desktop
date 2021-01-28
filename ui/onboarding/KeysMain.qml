import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Controls.Universal 2.12
import "../shared"
import "../shared/status"
import "../imports"

Page {
    id: page
    property alias btnExistingKey: btnExistingKey
    property alias btnGenKey: btnGenKey

    background: Rectangle {
        color: Style.current.background
    }

    Item {
        id: container
        width: 425
        height: {
            let h = 0
            const children = this.children
            Object.keys(children).forEach(function (key) {
                const child = children[key]
                h += child.height + Style.current.padding
            })
            return h
        }

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        Image {
            id: keysImg
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            fillMode: Image.PreserveAspectFit
            source: Universal.theme === Universal.Dark ? "img/keys-dark@2x.jpg" : "img/keys@2x.jpg"
            width: 160
            height: 160
        }

        StyledText {
            id: txtTitle1
            //% "Get your keys"
            text: qsTrId("intro-wizard-title1")
            anchors.topMargin: Style.current.padding
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: keysImg.bottom
            font.letterSpacing: -0.2
            font.pixelSize: 22
        }

        StyledText {
            id: txtDesc1
            color: Style.current.darkGrey
            //% "A set of keys controls your account. Your keys live on your device, so only you can use them."
            text: qsTrId("a-set-of-keys-controls-your-account.-your-keys-live-on-your-device,-so-only-you-can-use-them.")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: txtTitle1.bottom
            anchors.topMargin: Style.current.padding
            font.pixelSize: 15
        }


        StatusButton {
            id: btnGenKey
            anchors.top: txtDesc1.bottom
            anchors.topMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter
            //% "I'm new, generate keys"
            text: qsTrId("im-new,-generate-keys")
        }

        StatusButton {
            id: btnExistingKey
            //% "Access existing key"
            text: qsTrId("access-existing-key")
            anchors.top: btnGenKey.bottom
            anchors.topMargin: Style.current.padding
            anchors.horizontalCenter: parent.horizontalCenter
            type: "secondary"
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";formeditorZoom:0.8999999761581421;height:760;width:1080}
}
##^##*/
