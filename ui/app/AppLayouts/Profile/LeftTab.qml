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
    // property alias currentTab: profileScreenButtons.currentIndex
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

    Profile {}

    Menu {
        id: profileMenu
    }

}

/*##^##
Designer {
    D{i:15;anchors_height:56}
}
##^##*/
