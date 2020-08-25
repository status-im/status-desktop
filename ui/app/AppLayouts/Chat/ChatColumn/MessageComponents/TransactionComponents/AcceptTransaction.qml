import QtQuick 2.3
import "../../../../../../shared"
import "../../../../../../imports"

Item {
    width: parent.width
    height: childrenRect.height

    Separator {
        id: separator1
    }

    StyledText {
        id: acceptText
        color: Style.current.blue
        text: qsTr("Accept and share address")
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.weight: Font.Medium
        anchors.right: parent.right
        anchors.left: parent.left
        bottomPadding: Style.current.halfPadding
        topPadding: Style.current.halfPadding
        anchors.top: separator1.bottom
        font.pixelSize: 15

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                console.log('Accept')
            }
        }
    }

    Separator {
        id: separator2
        anchors.topMargin: 0
        anchors.top: acceptText.bottom
    }

    StyledText {
        id: declineText
        color: Style.current.blue
        text: qsTr("Decline")
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.weight: Font.Medium
        anchors.right: parent.right
        anchors.left: parent.left
        bottomPadding: Style.current.padding
        topPadding: Style.current.padding
        anchors.top: separator2.bottom
        font.pixelSize: 15

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                console.log('Decline')
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.25}
}
##^##*/
