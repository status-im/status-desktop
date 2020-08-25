import QtQuick 2.3
import "../../../../../../shared"
import "../../../../../../imports"

Item {
    width: parent.width
    height: childrenRect.height

    Separator {
        id: separator
    }

    StyledText {
        id: signText
        color: Style.current.blue
        text: qsTr("Sign and send")
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
                console.log('Sign')
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.25}
}
##^##*/

