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
    id: root

    /*!
       \qmlproperty bool StatusActivityCenterButton::hasUnseenNotifications
       This property indicates whether there are unseen notifications
    */
    property bool hasUnseenNotifications: false

    /*!
       \qmlproperty int StatusActivityCenterButton::unreadNotificationsCount
       This property holds the count of notifications.
    */
    property alias unreadNotificationsCount: statusBadge.value

    icon.name: "notification"
    icon.height: 21
    type: StatusFlatRoundButton.Type.Secondary
    objectName: "activityCenterNotificationsButton"

    // initializing the tooltip
    tooltip.text: qsTr("Notifications")
    tooltip.orientation: StatusToolTip.Orientation.Bottom
    tooltip.y: parent.height + 12
    tooltip.offset: -(tooltip.x + tooltip.width/2 - root.width/2) //position arrow center in root center

    StatusBadge {
        id: statusBadge
        visible: value > 0
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -(icon.height / 2.5)
        anchors.horizontalCenterOffset: (width / 2.5)
        color: root.hasUnseenNotifications ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
        border.width: 2
        border.color: parent.hovered ? Theme.palette.baseColor2 : Theme.palette.statusAppLayout.backgroundColor
    }
}
