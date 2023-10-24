import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1

import shared.controls 1.0

ColumnLayout {
    id: root

    StatusTabBar {
        id: tabBar

        Layout.fillWidth: true
        Layout.topMargin: 5

        StatusTabButton {
            id: assetsTab
            width: implicitWidth
            text: qsTr("Assets")
        }

        StatusTabButton {
            id: collectiblesTab
            width: implicitWidth
            text: qsTr("Collectibles ")
        }

        StatusTabButton {
            id: tokensListTab
            width: implicitWidth
            text: qsTr("Token lists")
        }
    }

    StackLayout {
        id: stackLayout

        Layout.fillWidth: true
        Layout.fillHeight: true
        currentIndex: tabBar.currentIndex

        ShapeRectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: parent.width - 4 // The rectangular path is rendered outside
            Layout.maximumHeight: 44
            text: qsTr("You’ll be able to manage the display of your assets here")
        }

        ShapeRectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: parent.width - 4 // The rectangular path is rendered outside
            Layout.maximumHeight: 44
            text: qsTr("You’ll be able to manage the display of your collectibles here")
        }

        // TO BE REPLACED: Empty placeholder when no token lists; dashed rounded rectangle
        ShapeRectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: parent.width - 4 // The rectangular path is rendered outside
            Layout.preferredHeight: 44
            text: qsTr("Token List (coming soon)")
        }
    }
}
