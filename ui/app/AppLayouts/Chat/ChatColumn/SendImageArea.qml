import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "./"

Rectangle {
    id: sendImageArea
    height: 70

    property string image: ""

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    color: "#00000000"

    Rectangle {
        id: closeButton
        height: 32
        width: 32
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding
        anchors.right: parent.right
        radius: 8

        SVGImage {
            id: closeModalImg
            source: "../../../../shared/img/close.svg"
            width: 25
            height: 25
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        MouseArea {
            id: closeImageArea
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            hoverEnabled: true
            onExited: {
                closeButton.color = Style.current.white
            }
            onEntered: {
                closeButton.color = Style.current.grey
            }
            onClicked: {
                chatColumn.hideExtendedArea();
            }
        }
    }

    Image {
        id: chatImage
        width: 36
        height: 36
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        anchors.top: parent.top
        fillMode: Image.PreserveAspectFit
        source: image
        mipmap: true
        smooth: false
        antialiasing: true
    }
}