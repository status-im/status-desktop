import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../imports"
import "../components"

Rectangle {
    border.width: 0

    Button {
        id: chatSendBtn
        visible: txtData.length > 0
        width: 30
        height: 30
        text: ""
        anchors.rightMargin: Style.current.padding
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        onClicked: {
            chatsModel.sendMessage(txtData.text)
            txtData.text = ""
        }
        background: Rectangle {
            color: parent.enabled ? Style.current.blue : Style.current.grey
            radius: 50
        }
        Image {
            source: "../../../img/arrowUp.svg"
            width: 12
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Image {
        id: stickersIcon
        visible: txtData.length == 0
        width: 20
        height: 20
        anchors.rightMargin: Style.current.padding
        anchors.right: parent.right
        fillMode: Image.PreserveAspectFit
        source: "../../../img/stickers_icon" + (stickersPopup.opened ? "_open.svg" : ".svg")
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked: {
                if (stickersPopup.opened) {
                    stickersPopup.close()
                } else {
                    stickersPopup.open()
                }
            }
        }
    }

    StickersPopup {
        id: stickersPopup
        width: 360
        height: 440
        x: parent.width - width - 8
        y: parent.height - sendBtns.height - height - 8
        stickerList: chatsModel.stickers
        stickerPackList: chatsModel.stickerPacks
    }
}
/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
