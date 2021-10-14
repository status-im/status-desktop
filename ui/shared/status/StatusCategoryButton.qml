import QtQuick 2.13
import QtGraphicalEffects 1.0

import utils 1.0
import "../../shared/panels"

Rectangle {
    property bool active: false
    property var changeCategory: function () {}
    property url source: Style.svg("emojiCategories/recent")

    id: categoryButton
    width: 40
    height: 40
    color: Style.current.transparent

    SVGImage {
        width: 20
        height: 20
        fillMode: Image.PreserveAspectFit
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        source: categoryButton.source

        ColorOverlay {
            anchors.fill: parent
            source: parent
            color: categoryButton.active ? Style.current.primary : Style.current.transparent
        }

        Rectangle {
            visible: categoryButton.active
            width: parent.width
            height: 2
            radius: 1
            color: Style.current.primary
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -Style.current.smallPadding
        }
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onClicked: function () {
           categoryButton.changeCategory()
        }
    }
}



/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:440;width:360}
}
##^##*/
