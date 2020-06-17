import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/xss.js" as XSS

Item {
    id: helpContainer
    width: 200
    height: 200
    Layout.fillHeight: true
    Layout.fillWidth: true

    function linkify(inputText) {
        //URLs starting with http://, https://, or ftp://
        var replacePattern1 = /(\b(https?|ftp):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/gim;
        replacedText = inputText.replace(replacePattern1, "<a href='$1'>$1</a>");

        //URLs starting with "www." (without // before it, or it'd re-link the ones done above).
        var replacePattern2 = /(^|[^\/])(www\.[\S]+(\b|$))/gim;
        replacedText = replacedText.replace(replacePattern2, "$1<a href='http://$2'>$2</a>");

        replacedText = XSS.filterXSS(replacedText)
        return replacedText;
    }

    StyledText {
        id: element8
        text: qsTr("Help menus: FAQ, Glossary, etc.")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    StyledText {
        anchors.centerIn: parent
        text: linkify(link)
        onLinkActivated: Qt.openUrlExternally(link)

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
            cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
    }
}
