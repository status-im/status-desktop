import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1

import utils 1.0
import shared.controls 1.0

ColumnLayout {
    id: root

    spacing: Constants.settingsSection.itemSpacing

    QtObject {
        id: d
    }

    StatusTabBar {
        id: walletTabBar
        Layout.fillWidth: true

        StatusTabButton {
            leftPadding: 0
            width: implicitWidth
            text: qsTr("By dApp")
        }

        StatusTabButton {
            width: implicitWidth
            text: qsTr("By token")
        }

        StatusTabButton {
            width: implicitWidth
            text: qsTr("By account")
        }
    }

    ShapeRectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: implicitHeight
        text: qsTr("Your dApp approvals will appear here")
    }
}
