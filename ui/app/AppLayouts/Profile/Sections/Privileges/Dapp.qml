import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../../../imports"
import "../../../../../shared"

Item {
    property string name: "Status.im"

    height: 50
    anchors.right: parent.right
    anchors.left: parent.left

    signal dappClicked(string dapp)

    SVGImage {
        id: image
        height: 40
        width: 40
        anchors.top: parent.top
        anchors.topMargin: 4
        anchors.left: parent.left
        fillMode: Image.PreserveAspectFit
        source: "../../../../img/generalDappIcon.svg"
    }

    StyledText {
        id: dappText
        text: name
        elide: Text.ElideRight
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        font.pixelSize: 17
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.left: image.right
        anchors.leftMargin: Style.current.padding
    }

    SVGImage {
        id: arrow
        height: 24
        width: 24
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        fillMode: Image.PreserveAspectFit
        source: "../../../../img/list-next.svg"
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onClicked: dappClicked(name)
    }
}
