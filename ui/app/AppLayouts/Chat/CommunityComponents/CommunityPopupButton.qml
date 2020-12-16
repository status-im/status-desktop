import QtQuick 2.12
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "../ContactsColumn"
import QtGraphicalEffects 1.13

Item {
    id: root
    width: contentItem.width
    height: contentItem.height
    

    default property alias actionContent: placeholder.data
    signal clicked()

    property string iconName
    property string label
    property string txtColor: Style.current.blue

    Item {
        id: contentItem
        anchors.verticalCenter: parent.verticalCenter
        width: btn.width + btnLabel.width + Style.current.padding
        height: btn.height

        StatusRoundButton {
            id: btn
            anchors.verticalCenter: parent.verticalCenter
            icon.name: "communities/" + iconName
            icon.color: Style.current.lightBlue
            width: 40
            height: 40
        }

        StyledText {
            id: btnLabel
            text: label
            color: txtColor
            anchors.left: btn.right
            anchors.leftMargin: Style.current.padding
            anchors.verticalCenter: btn.verticalCenter
            font.pixelSize: 15
        }        
    }

    Item {
        id: placeholder
        anchors.right: parent.right
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}