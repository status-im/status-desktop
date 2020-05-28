import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../../shared"
import "../../../../imports"

Rectangle {
    property alias searchStr: searchText.text
    id: searchBox
    height: 36
    color: Theme.grey
    anchors.top: parent.top
    anchors.topMargin: 59
    radius: 8
    anchors.right: parent.right
    anchors.rightMargin: 65
    anchors.left: parent.left
    anchors.leftMargin: 16

    TextField {
        id: searchText
        placeholderText: qsTr("Search")
        anchors.left: parent.left
        anchors.leftMargin: 32
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 12
        background: Rectangle {
            color: "#00000000"
        }
    }

    Image {
        id: image4
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: "../../img/search.svg"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            searchText.forceActiveFocus(Qt.MouseFocusReason)
        }
    }
}
