import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"

Item {
    id: helpContainer
    width: 200
    height: 200
    Layout.fillHeight: true
    Layout.fillWidth: true

    StyledText {
        id: element8
        //% "Help menus: FAQ, Glossary, etc."
        text: qsTrId("help-menus:-faq,-glossary,-etc.")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    // FIXME the link doesn't exist
//    StyledText {
//        anchors.centerIn: parent
//        text: Utils.linkifyAndXSS(link)
//        onLinkActivated: Qt.openUrlExternally(link)

//        MouseArea {
//            anchors.fill: parent
//            acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
//            cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
//        }
//    }
}
