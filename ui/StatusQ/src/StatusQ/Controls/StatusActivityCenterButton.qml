import QtQuick 2.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

/*!
   \qmltype StatusActivityCenterButton
   \inherits StatusFlatRoundButton
   \inqmlmodule StatusQ.Controls
   \since StatusQ.Controls 0.1
   \brief The StatusActivityCenterButton provides the button for Activity Center popup

   Example of how to use it:

   \qml
        StatusActivityCenterButton {
            unreadNotificationsCount: activityCenter.unreadNotificationsCount
            onClicked: activityCenterPopup.open()
        }
   \endqml

   For a list of components available see StatusQ.
*/

StatusFlatRoundButton {
    id: notificationButton

    /*!
       \qmlproperty int StatusActivityCenterButton::unreadNotificationsCount
       This property holds the count of notifications.
    */
    property alias unreadNotificationsCount: statusBadge.value

    icon.name: "notification"
    icon.height: 21
    type: StatusFlatRoundButton.Type.Secondary

    // initializing the tooltip
    tooltip.text: qsTr("Activity")
    tooltip.orientation: StatusToolTip.Orientation.Bottom
    tooltip.y: parent.height + 12

    StatusBadge {
        id: statusBadge

        visible: value > 0
        anchors.top: parent.top
        anchors.left: parent.right
        anchors.topMargin: -3
        anchors.leftMargin: {
            if (statusBadge.value > 99) {
                return -22
            }
            if (statusBadge.value > 9) {
                return -21
            }
            return -18
        }
        border.width: 2
        border.color: parent.hovered ? Theme.palette.baseColor2 : Theme.palette.statusAppLayout.backgroundColor
    }
}
