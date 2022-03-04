import QtQuick 2.13
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root
    width: titleText.contentWidth + 60
    height: 30
    color: Theme.palette.primaryColor2
    radius: 15

    property string title: ""
    signal clicked()

    property StatusImageSettings image: StatusImageSettings {
        width: 20
        height: 20
        isIdenticon: false
    }

    property StatusIconSettings icon: StatusIconSettings {
        height: 20
        width: 20
        rotation: 0
        isLetterIdenticon: false
        letterSize: 10
        color: Theme.palette.primaryColor1
        background: StatusIconBackgroundSettings {
            width: 15
            height: 15
            color: Theme.palette.primaryColor3
        }
    }

    StatusSmartIdenticon {
        id: iconOrImage
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        image: root.image
        icon: root.icon
        name: root.title
        active: root.icon.isLetterIdenticon ||
                !!root.icon.name ||
                !!root.image.source.toString()
    }

    StatusBaseText {
        id: titleText
        anchors.left: iconOrImage.right
        anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.palette.primaryColor1
        text: root.title
    }
 
    StatusIcon {
        id: closeIcon
        anchors.left: titleText.right
        anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.palette.primaryColor1
        icon: "close"
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: closeIcon
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.clicked()
        }
    }
}