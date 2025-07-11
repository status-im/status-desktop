import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Popups.Dialog

import utils

ColumnLayout {
    id: root

    property alias text: sectionTitle.text

    signal infoButtonClicked

    spacing: 0

    StatusDialogDivider {
        Layout.fillWidth: true
        Layout.bottomMargin: Theme.halfPadding
    }
    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: Theme.padding
        Layout.rightMargin: Theme.smallPadding
        Layout.bottomMargin: 4
        StatusBaseText {
            id: sectionTitle

            color: Theme.palette.baseColor1
        }
        Item { Layout.fillWidth: true }
        StatusFlatButton {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            visible: !!root.text
            icon.name: "info"
            textColor: Theme.palette.baseColor1
            horizontalPadding: 0
            verticalPadding: 0
            onClicked: root.infoButtonClicked()
        }
    }
}
