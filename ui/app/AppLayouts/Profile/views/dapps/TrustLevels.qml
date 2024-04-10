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

    ShapeRectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: implicitHeight
        text: qsTr("Your trust level for dApps you have interacted with will appear here")
    }
}
