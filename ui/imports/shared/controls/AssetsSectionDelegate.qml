import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

import utils 1.0

ColumnLayout {
    signal openInfoPopup()

    spacing: 0

    StatusDialogDivider {
        Layout.fillWidth: true
        Layout.topMargin: Style.current.padding
        Layout.bottomMargin: Style.current.halfPadding
    }
    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: Style.current.padding
        Layout.rightMargin: Style.current.smallPadding
        Layout.bottomMargin: 4
        StatusBaseText {
            text: qsTr("Community assets")
            color: Theme.palette.baseColor1
        }
        Item { Layout.fillWidth: true }
        StatusFlatButton {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            icon.name: "info"
            textColor: Theme.palette.baseColor1
            horizontalPadding: 0
            verticalPadding: 0
            onClicked: openInfoPopup()
        }
    }
}

