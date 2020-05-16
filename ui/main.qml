import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "./onboarding"
import "./app"


ApplicationWindow {
    id: applicationWindow
    width: 1232
    height: 770
    title: "Nim Status Client"
    visible: true
    font.family: "Inter"
    
    
    Text {
        id: element
        x: 772
        text: logic.lastMessage
        anchors.top: parent.top
        anchors.topMargin: 17
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 17
    }

}



