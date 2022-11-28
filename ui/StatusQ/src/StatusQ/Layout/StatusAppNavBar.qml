import QtQuick 2.13
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

Rectangle {
    id: root

    property alias chatItemsModel: chatItemsListView.model
    property alias chatItemDelegate: chatItemsListView.delegate

    property alias communityItemsModel: communityItemsListView.model
    property alias communityItemDelegate: communityItemsListView.delegate

    property alias regularItemsModel: regularItemsListView.model
    property alias regularItemDelegate: regularItemsListView.delegate

    property real delegateHeight

    property alias cameraComponent: cameraItemLoader.sourceComponent
    property alias profileComponent: profileItemLoader.sourceComponent

    implicitWidth: 78
    implicitHeight: layout.implicitHeight

    color: Theme.palette.statusAppNavBar.backgroundColor

    QtObject {
        id: d

        readonly property real spacing: 12
        readonly property real separatorWidth: 30

        function implicitListViewHeight(listView) {
            return listView.count ? listView.count * root.delegateHeight + (listView.count - 1) * listView.spacing : 0
        }
    }

    ColumnLayout {
        id: layout

        anchors {
            fill: parent
            topMargin: 48
            bottomMargin: 24
        }

        spacing: d.spacing

        ListView {
            id: chatItemsListView

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: root.delegateHeight
            Layout.preferredHeight: d.implicitListViewHeight(this)
            Layout.maximumHeight: Layout.preferredHeight

            objectName: "statusChatNavBarListView"

            visible: count
            clip: true
            spacing: d.spacing
            boundsBehavior: contentHeight > height ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
        }

        Rectangle {
            id: firstSectionSeparator

            implicitHeight: 1
            Layout.preferredWidth: d.separatorWidth
            Layout.alignment: Qt.AlignHCenter
            color: Theme.palette.directColor7

            visible: chatItemsListView.count && communityItemsListView.contentHeight > communityItemsListView.height
        }

        ListView {
            id: communityItemsListView

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: root.delegateHeight
            Layout.preferredHeight: d.implicitListViewHeight(this)
            Layout.maximumHeight: Layout.preferredHeight

            visible: count
            clip: true
            spacing: d.spacing
            boundsBehavior: contentHeight > height ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
        }

        Rectangle {
            id: secondSectionSeparator

            implicitHeight: 1
            Layout.preferredWidth: d.separatorWidth
            Layout.alignment: Qt.AlignHCenter
            color: Theme.palette.directColor7
            visible: chatItemsListView.count || communityItemsListView.count
        }

        ListView {
            id: regularItemsListView

            Layout.fillWidth: true
            Layout.preferredHeight: d.implicitListViewHeight(this)

            objectName: "statusMainNavBarListView"

            visible: count
            clip: true
            spacing: d.spacing
            boundsBehavior: contentHeight > height ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Loader {
            id: cameraItemLoader
            Layout.alignment: Qt.AlignHCenter
        }

        Loader {
            id: profileItemLoader
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
