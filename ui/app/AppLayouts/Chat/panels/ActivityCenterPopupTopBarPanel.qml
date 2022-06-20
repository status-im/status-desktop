import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import ".."

Item {
    id: root
    width: parent.width
    height: Style.dp(64)

    property bool allBtnHighlighted: false
    property bool repliesBtnHighlighted: false
    property bool mentionsBtnHighlighted: false
    property alias repliesBtnEnabled: repliesbtn.enabled
    property alias mentionsBtnEnabled: mentionsBtn.enabled
    property alias errorText: errorText.text
    signal allBtnClicked()
    signal repliesBtnClicked()
    signal mentionsBtnClicked()
    signal preferencesClicked()
    signal markAllReadClicked()

    Row {
        id: filterButtons
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        height: allBtn.height
        spacing: Style.current.padding

       StatusFlatButton {
           id: allBtn
           //% "All"
           text: qsTrId("all")
           size: StatusBaseButton.Size.Small
           highlighted: root.allBtnHighlighted
           onClicked: root.allBtnClicked();
       }

       StatusFlatButton {
           id: mentionsBtn
           //% "Mentions"
           text: qsTrId("mentions")
           enabled: hasMentions
           size: StatusBaseButton.Size.Small
           highlighted: root.mentionsBtnHighlighted
           onClicked: {
               root.mentionsBtnClicked();
           }
       }

       StatusFlatButton {
           id: repliesbtn
           //% "Replies"
           text: qsTrId("replies")
           enabled: hasReplies
           size: StatusBaseButton.Size.Small
           highlighted: root.repliesBtnHighlighted
           onClicked: {
               root.repliesBtnClicked();
           }
       }

//       StatusFlatButton {
//           id: contactRequestsBtn
//           //% "Contact requests"
//           text: qsTrId("contact-requests")
//           enabled: hasContactRequests
//           size: StatusBaseButton.Size.Small
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

        StatusFlatRoundButton {
            id: markAllReadBtn
            icon.name: "double-checkmark"
            width: 32
            height: 32
            onClicked: markAllReadClicked()

            StatusToolTip {
              visible: markAllReadBtn.hovered
              //% "Mark all as Read"
              text: qsTrId("mark-all-as-read")
            }
        }

        StatusFlatRoundButton {
            id: moreActionsBtn
            icon.name: "more"
            width: Style.dp(32)
            height: width
            type: StatusFlatRoundButton.Type.Secondary
            onClicked: {
                let p = moreActionsBtn.mapToItem(otherButtons, moreActionsBtn.x, moreActionsBtn.y)
                moreActionsMenu.popup(moreActionsBtn.width - moreActionsMenu.width, p.y + moreActionsBtn.height + 4)
            }

            StatusPopupMenu {
                id: moreActionsMenu

                StatusMenuItem {
                    icon.name: "hide"
                    text: hideReadNotifications ?
                              //% "Show read notifications"
                              qsTrId("show-read-notifications") :
                              //% "Hide read notifications"
                              qsTrId("hide-read-notifications")
                    onTriggered: hideReadNotifications = !hideReadNotifications
                }

                StatusMenuItem {
                    icon.name: "notification"
                    //% "Notification settings"
                    text: qsTrId("chat-notification-preferences")
                    onTriggered: {
                        root.preferencesClicked();
                    }
                }
            }
        }
    }

    StatusBaseText {
        id: errorText
        visible: !!text
        anchors.top: filterButtons.bottom
        anchors.topMargin: Style.current.smallPadding
        color: Theme.palette.dangerColor1
    }
}
