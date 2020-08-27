import QtQuick 2.13
import "../imports"


StyledText {
    property bool expanded: false
    property int oldWidth
    id: addressComponent
    text: "0x9ce0056c5fc6bb9459a4dcfa35eaad8c1fee5ce9"
    font.pixelSize: 13
    font.family: Style.current.fontHexRegular.name
    elide: expanded ? Text.ElideNone : Text.ElideMiddle
    color: Style.current.darkGrey

    MouseArea {
        width: parent.width
        height: parent.height
        cursorShape: Qt.PointingHandCursor
        onClicked: {

            if (addressComponent.expanded) {
                addressComponent.width = addressComponent.oldWidth
                this.width = addressComponent.width
            } else {

                this.width = addressComponent.implicitWidth
                addressComponent.oldWidth = addressComponent.width
                addressComponent.width = addressComponent.implicitWidth
            }
            addressComponent.expanded = !addressComponent.expanded
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff"}
}
##^##*/
