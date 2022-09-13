import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import "../popups"

Item {
    id: root

    property bool hasMentions: false
    property bool hasReplies: false
    property bool hideReadNotifications: false

    property int currentActivityCategory: ActivityCenterPopup.ActivityCategory.All

    property alias errorText: errorText.text

    signal categoryTriggered(int category)
    signal markAllReadClicked()

    height: 64

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin: Style.current.padding
        anchors.rightMargin: Style.current.padding
        spacing: Style.current.padding

        StatusListView {
            id: listView
            // NOTE: some entries are hidden until implimentation
            model: [ { text: qsTr("All"), category: ActivityCenterPopup.ActivityCategory.All, visible: true },
                     { text: qsTr("Admin"), category: ActivityCenterPopup.ActivityCategory.Admin, visible: false },
                     { text: qsTr("Mentions"), category: ActivityCenterPopup.ActivityCategory.Mentions, visible: true },
                     { text: qsTr("Replies"), category: ActivityCenterPopup.ActivityCategory.Replies, visible: true },
                     { text: qsTr("Contact requests"), category: ActivityCenterPopup.ActivityCategory.ContactRequests, visible: true },
                     { text: qsTr("Identity verification"), category: ActivityCenterPopup.ActivityCategory.IdentityVerification, visible: false },
                     { text: qsTr("Transactions"), category: ActivityCenterPopup.ActivityCategory.Transactions, visible: false },
                     { text: qsTr("Membership"), category: ActivityCenterPopup.ActivityCategory.Membership, visible: false },
                     { text: qsTr("System"), category: ActivityCenterPopup.ActivityCategory.System, visible: false } ]
            orientation: StatusListView.Horizontal
            spacing: 0
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            Layout.fillWidth: true
            Layout.fillHeight: true

            delegate: StatusFlatButton {
                visible: modelData.visible
                width: visible ? implicitWidth : 0
                text: modelData.text
                anchors.verticalCenter: parent.verticalCenter
                height: 32
                size: StatusBaseButton.Size.Small
                highlighted: modelData.category == root.currentActivityCategory
                onClicked: root.categoryTriggered(modelData.category)
            }
        }

        StatusFlatRoundButton {
            id: markAllReadBtn
            icon.name: "double-checkmark"
            onClicked: markAllReadClicked()

            StatusToolTip {
              visible: markAllReadBtn.hovered
              text: qsTr("Mark all as Read")
            }
        }

        StatusFlatRoundButton {
            id: hideReadNotificationsBtn
            icon.name: "hide"
            onClicked: hideReadNotifications = !hideReadNotifications

            StatusToolTip {
              visible: markAllReadBtn.hovered
              text: hideReadNotifications ? qsTr("Show read notifications") : qsTr("Hide read notifications")
            }
        }
    }

    StatusBaseText {
        id: errorText
        visible: !!text
        anchors.top: parent.top
        anchors.topMargin: Style.current.smallPadding
        color: Theme.palette.dangerColor1
    }
}
