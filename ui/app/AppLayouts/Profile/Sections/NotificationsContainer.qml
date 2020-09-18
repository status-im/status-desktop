import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

Item {
    id: notificationsContainer
    anchors.right: parent.right
    anchors.rightMargin: contentMargin
    anchors.left: parent.left
    anchors.leftMargin: contentMargin

    StatusSectionHeadline {
      text: qsTr("Notification preferences")
      anchors.top: parent.top
    }
}
