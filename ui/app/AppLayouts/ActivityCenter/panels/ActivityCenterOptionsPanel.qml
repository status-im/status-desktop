import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Core

import utils

Control {
    id: root

    property bool hideReadNotifications: true

    signal markAllAsReadRequested()
    signal hideShowNotificationsRequested()

    contentItem: ColumnLayout {
        Tracer{}
        Layout.fillWidth: true
        spacing: Theme.halfPadding
        visible: true

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.padding
            Tracer{}

            StatusRoundIcon {
                Layout.leftMargin: Theme.padding

                objectName: "markAllReadButton"
                asset.name: "double-checkmark"
            }

            StatusBaseText{
                Tracer{}
                Layout.fillWidth: true
                text: qsTr("Mark all as read")
                elide: Text.ElideRight
            }

            StatusMouseArea {
                Tracer{}
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.markAllAsReadRequested()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: Theme.halfPadding
            spacing: Theme.padding

            StatusRoundIcon {
                Layout.leftMargin: Theme.padding

                objectName: "hideReadNotificationsButton"
                asset.name:  root.hideReadNotifications ? "hide" : "show"
            }

            StatusBaseText{
                Layout.fillWidth: true
                text: qsTr("Hide read notifications")
                elide: Text.ElideRight
            }

            StatusMouseArea {
                Tracer{}
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.hideShowNotificationsRequested()
            }
        }
    }

}
