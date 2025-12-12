import QtQuick
import QtQuick.Layouts
import QtQuick.Window

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Popups

Rectangle {
    id: root
    objectName: "statusAppNavBar"

    required property bool thirdpartyServicesEnabled

    property alias topSectionModel: topSectionListview.model
    property alias topSectionDelegate: topSectionListview.delegate

    property alias communityItemsModel: communityItemsListView.model
    property alias communityItemDelegate: communityItemsListView.delegate

    property alias regularItemsModel: regularItemsListView.model
    property alias regularItemDelegate: regularItemsListView.delegate

    property real delegateHeight

    property alias cameraComponent: cameraItemLoader.sourceComponent
    property alias profileComponent: profileItemLoader.sourceComponent

    implicitWidth: 78

    color: root.thirdpartyServicesEnabled ? Theme.palette.statusAppNavBar.backgroundColor :
                                            Theme.palette.privacyColors.primary

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
            topMargin: Qt.platform.os === "osx" && Window.visibility !== Window.FullScreen ? 48 : 12 // space reserved for Mac traffic lights (window icons)
            bottomMargin: 24
        }

        spacing: d.spacing

        ListView {
            id: topSectionListview

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

            visible: topSectionListview.count && communityItemsListView.contentHeight > communityItemsListView.height
        }

        ListView {
            id: communityItemsListView
            objectName: "statusCommunityMainNavBarListView"

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

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Rectangle {
            id: secondSectionSeparator

            implicitHeight: 1
            Layout.preferredWidth: d.separatorWidth
            Layout.alignment: Qt.AlignHCenter
            color: Theme.palette.directColor7
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
