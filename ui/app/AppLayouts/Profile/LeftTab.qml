import QtGraphicalEffects 1.12
import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../imports"
import "../../../shared"
import "./LeftTab"

ColumnLayout {
    readonly property int w: 340
    property alias currentTab: profileMenu.profileCurrentIndex

    id: profileInfoContainer
    width: w
    spacing: 0
    anchors.left: parent.left
    anchors.leftMargin: 0
    anchors.top: parent.top
    anchors.topMargin: 0
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 0
    Layout.minimumWidth: 300

    RowLayout {
        id: profileHeader
        height: 240
        Layout.fillWidth: true
        width: profileInfoContainer.w

        Profile {}
    }

    RowLayout {
        width: profileInfoContainer.w
        height: btnheight * 10
        Layout.fillHeight: true
        Layout.fillWidth: true

        Menu {
            id: profileMenu
        }
    }
}


