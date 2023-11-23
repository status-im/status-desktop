import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

ToolBar {
    id: root

    property string backButtonName: ""
    property int notificationCount: 0
    property bool hasUnseenNotifications: false
    property Item headerContent
    property alias notificationButton: notificationButton

    signal backButtonClicked()
    signal notificationButtonClicked()

    objectName: "statusToolBar"
    leftPadding: 4
    rightPadding: 10
    topPadding: 8
    bottomPadding: 4
    background: null

    contentItem: RowLayout {
        spacing: 0
        StatusFlatButton {
            Layout.leftMargin: 20
            objectName: "toolBarBackButton"
            icon.name: "arrow-left"
            visible: !!root.backButtonName
            text: root.backButtonName
            onClicked: { root.backButtonClicked(); }
        }

        Control {
            id: headerContentItem
            Layout.fillWidth: !!headerContent
            Layout.fillHeight: !!headerContent
            Layout.leftMargin: 8
            background: null
            contentItem: (!!headerContent) ? headerContent : null
        }

        Item {
            Layout.fillWidth: !headerContent
        }

        StatusActivityCenterButton {
            id: notificationButton
            Layout.leftMargin: 8
            unreadNotificationsCount: root.notificationCount
            hasUnseenNotifications: root.hasUnseenNotifications
            onClicked: root.notificationButtonClicked()
        }
    }
}
