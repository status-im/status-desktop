import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

ColumnLayout {
    id: root
    spacing: 8

    property string dappName: ""

    StatusBaseText {
        Layout.fillWidth: true
        objectName: "permissionsTitle"
        text: qsTr("%1 will be able to:").arg(root.dappName)
        Layout.preferredHeight: 18
        font.pixelSize: Theme.additionalTextSize
        elide: Text.ElideMiddle
        color: Theme.palette.baseColor1
    }

    StatusBaseText {
        text: qsTr("Check your account balance and activity")
        Layout.fillWidth: true
        Layout.preferredHeight: 18
        elide: Text.ElideRight
        font.pixelSize: Theme.additionalTextSize
    }

    StatusBaseText {
        text: qsTr("Request transactions and message signing")
        Layout.fillWidth: true
        Layout.preferredHeight: 18
        elide: Text.ElideRight
        font.pixelSize: Theme.additionalTextSize
    }
}
