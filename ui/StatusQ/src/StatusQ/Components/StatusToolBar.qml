import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

ToolBar {
    id: root

    property string backButtonName: ""
    property int notificationCount: 0
    property Item headerContent
    property alias notificationButton: notificationButton

    signal backButtonClicked()
    signal notificationButtonClicked()

    objectName: "statusToolBar"
    implicitWidth: visible ? 518 : 0
    implicitHeight: visible ? 56 : 0
    padding: 4
    background: null

    RowLayout {
        anchors.fill: parent
        anchors.rightMargin: 4
        spacing: 0
        StatusFlatButton {
            objectName: "toolBarBackButton"
            icon.name: "arrow-left"
            icon.width: 20
            icon.height: 20
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.leftMargin: 18
            visible: !!root.backButtonName
            text: root.backButtonName
            size: StatusBaseButton.Size.Large
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
            unreadNotificationsCount: root.notificationCount
            onClicked: root.notificationButtonClicked()
        }
    }
}
