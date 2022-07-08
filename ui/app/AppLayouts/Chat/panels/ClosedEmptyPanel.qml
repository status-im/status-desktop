import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import shared 1.0
import shared.panels 1.0

import utils 1.0

Item {
    id: closedEmptyView
    Layout.fillHeight: true
    Layout.fillWidth: true

    StyledText {
        text: qsTr("Your chats will appear here. To start new chats press the  button at the top")
        anchors.verticalCenterOffset: -80
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        anchors.right: parent.right
        anchors.rightMargin: 56
        anchors.left: parent.left
        anchors.leftMargin: 56
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 15
        color: Style.current.darkGrey
    }
}
