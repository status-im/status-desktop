import QtQuick 2.0
import QtQuick.Layouts 1.12

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Column {
    spacing: 4

    QtObject {
        id: d
        readonly property int listItemHeight: 40
    }

    RowLayout {
        height: d.listItemHeight

        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: 15
            color: Theme.palette.baseColor1
            text: qsTr("1. Open Status App on your desktop")
        }
    }

    RowLayout {
        height: d.listItemHeight

        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: 15
            color: Theme.palette.baseColor1
            text: qsTr("2. Open")
        }
        StatusRoundIcon {
            id: settingsButton
            icon.name: "settings"
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: 15
            color: Theme.palette.directColor1
            text: qsTr("Settings")
        }

    }

    RowLayout {
        height: d.listItemHeight

        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: 15
            color: Theme.palette.baseColor1
            text: qsTr("3. Navigate to the ")
        }
        StatusRoundIcon {
            icon.name: "rotate"
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            text: qsTr("Syncing tab")
            font.pixelSize: 15
            color: Theme.palette.directColor1
        }
    }

    RowLayout {
        height: d.listItemHeight

        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            text: qsTr("4. Click the")
            font.pixelSize: 15
            color: Theme.palette.baseColor1
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            text: qsTr("Setup Syncing")
            font.pixelSize: 15
            color: Theme.palette.directColor1
        }
        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            text: qsTr("button")
            font.pixelSize: 15
            color: Theme.palette.baseColor1
        }
    }

    RowLayout {
        height: d.listItemHeight

        StatusBaseText {
            Layout.alignment: Qt.AlignVCenter
            text: qsTr("5. Paste the sync code above")
            font.pixelSize: 15
            color: Theme.palette.baseColor1
        }
    }
}
