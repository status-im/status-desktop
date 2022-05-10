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
    height: 64

    property bool hasMentions: false
    property bool hasReplies: false
    property bool hideReadNotifications: false
    property bool allBtnHighlighted: false
    property bool repliesBtnHighlighted: false
    property bool mentionsBtnHighlighted: false
    property alias errorText: errorText.text
    signal allBtnClicked()
    signal repliesBtnClicked()
    signal mentionsBtnClicked()
    signal preferencesClicked()
    signal markAllReadClicked()
    signal hideReadNotificationsTriggered()

    Row {
        id: filterButtons
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Style.current.padding
        height: allBtn.height
        spacing: Style.current.padding

       StatusFlatButton {
           id: allBtn
           text: qsTr("All")
           size: StatusBaseButton.Size.Small
           highlighted: root.allBtnHighlighted
           onClicked: root.allBtnClicked();
       }

       StatusFlatButton {
           id: mentionsBtn
           text: qsTr("Mentions")
           enabled: hasMentions
           size: StatusBaseButton.Size.Small
           highlighted: root.mentionsBtnHighlighted
           onClicked: {
               root.mentionsBtnClicked();
           }
       }

       StatusFlatButton {
           id: repliesbtn
           text: qsTr("Replies")
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
//           text: qsTr("Replies")
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
              text: qsTr("Mark all as Read")
            }
        }

        StatusFlatRoundButton {
            id: moreActionsBtn
            icon.name: "more"
            width: 32
            height: 32
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
                              qsTr("Show read notifications") :
                              qsTr("Hide read notifications")
                    onTriggered: hideReadNotifications = !hideReadNotifications
                }

                StatusMenuItem {
                    icon.name: "notification"
                    text: qsTr("Notification settings")
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
