import QtQuick
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core
import StatusQ.Core.Theme

ColumnLayout {
    id: root

    required property var whitelistedDomainsModel

    signal removeWhitelistedDomain(int index)

    spacing: Theme.bigPadding

    StatusBaseText {
        Layout.fillWidth: true
        wrapMode: Text.Wrap
        Layout.preferredWidth: 0

        text: qsTr("Trusted sites")
        font.pixelSize: 28
        font.bold: true
    }

    StatusBaseText {
        Layout.fillWidth: true
        Layout.preferredWidth: 0

        wrapMode: Text.Wrap
        text: qsTr("Manage trusted sites. Their links open without confirmation.")
    }

    StatusBaseText {
        Layout.fillWidth: true
        Layout.preferredWidth: 0
        Layout.topMargin: Theme.xlPadding

        horizontalAlignment: Text.AlignHCenter

        wrapMode: Text.Wrap
        text: qsTr("No trusted sites added yet")
        visible: listView.count === 0
        color: Theme.palette.baseColor1
    }

    StatusListView {
        id: listView

        Layout.fillWidth: true
        Layout.fillHeight: true

        model: root.whitelistedDomainsModel
        delegate: StatusListItem {
            width: ListView.view.width

            title: modelData
            components: [
                StatusFlatButton {
                    icon.name: "close"
                    onClicked: root.removeWhitelistedDomain(index)
                }
            ]
        }
    }
}
