import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0
import "../../../../shared"
import "../../../../shared/status"

Item {
    id: root
    width: parent.width
    height: 64

    property bool allBtnHighlighted: false
    property bool repliesBtnHighlighted: false
    property bool mentionsBtnHighlighted: false
    property alias repliesBtnEnabled: repliesbtn.enabled
    property alias mentionsBtnEnabled: mentionsBtn.enabled
    signal allBtnClicked()
    signal repliesBtnClicked()
    signal mentionsBtnClicked()
    signal preferencesClicked()

    Row {
        id: filterButtons
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        height: allBtn.height
        spacing: Style.current.padding

       StatusButton {
           id: allBtn
           //% "All"
           text: qsTrId("all")
           type: "secondary"
           size: "small"
           highlighted: root.allBtnHighlighted
           onClicked: {
               root.allBtnClicked();
           }
       }

       StatusButton {
           id: mentionsBtn
           //% "Mentions"
           text: qsTrId("mentions")
           type: "secondary"
           size: "small"
           highlighted: root.mentionsBtnHighlighted
           onClicked: {
               root.mentionsBtnClicked();
           }
       }

       StatusButton {
           id: repliesbtn
           //% "Replies"
           text: qsTrId("replies")
           type: "secondary"
           size: "small"
           highlighted: root.repliesBtnHighlighted
           onClicked: {
               root.repliesBtnClicked();
           }
       }

//       StatusButton {
//           id: contactRequestsBtn
//           //% "Contact requests"
//           text: qsTrId("contact-requests")
//           enabled: hasContactRequests
//           type: "secondary"
//           size: "small"
//           highlighted: activityCenter.currentFilter === ActivityCenter.Filter.ContactRequests
//           onClicked: activityCenter.currentFilter = ActivityCenter.Filter.ContactRequests
//       }
    }

    Row {
        id: otherButtons
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        height: markAllReadBtn.height
        spacing: Style.current.padding

       StatusIconButton {
           id: markAllReadBtn
           icon.name: "double-check"
           iconColor: Style.current.primary
           icon.width: 24
           icon.height: 24
           width: 32
           height: 32
           onClicked: {
               errorText.text = chatsModel.activityNotificationList.markAllActivityCenterNotificationsRead()
           }

           StatusToolTip {
             visible: markAllReadBtn.hovered
             //% "Mark all as Read"
             text: qsTrId("mark-all-as-read")
           }
       }

       StatusContextMenuButton {
           id: moreActionsBtn
           onClicked: moreActionsMenu.open()

           PopupMenu {
               id: moreActionsMenu
               x: moreActionsBtn.width - moreActionsMenu.width
               y: moreActionsBtn.height + 4

               Action {
                   icon.source: hideReadNotifications ? Style.svg("eye") : Style.svg("eye-barred")
                   icon.width: 16
                   icon.height: 16
                   text: hideReadNotifications ?
                             //% "Show read notifications"
                             qsTrId("show-read-notifications") :
                             //% "Hide read notifications"
                             qsTrId("hide-read-notifications")
                   onTriggered: hideReadNotifications = !hideReadNotifications
               }
               Action {
                   icon.source: Style.svg("bell")
                   icon.width: 16
                   icon.height: 16
                   //% "Notification settings"
                   text: qsTrId("chat-notification-preferences")
                   onTriggered: {
                       root.preferencesClicked();
                   }
               }
           }
       }
    }

    StyledText {
        id: errorText
        visible: !!text
        anchors.top: filterButtons.bottom
        anchors.topMargin: Style.current.smallPadding
        color: Style.current.danger
    }
}
