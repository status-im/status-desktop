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
        text: qsTr("Trusted sites")
        font.pixelSize: 28
        font.bold: true
    }

    StatusBaseText {
        text: qsTr("Manage trusted sites. Their links open without confirmation.")
    }

    StatusBaseText {
        Layout.topMargin: Theme.xlPadding
        Layout.alignment: Qt.AlignHCenter
        text: qsTr("No trusted sites added yet")
        visible: root.whitelistedDomainsModel.length === 0
        color: Theme.palette.baseColor1
    }

    StatusListView {
        Layout.fillWidth: true
        Layout.fillHeight: true

        model: root.whitelistedDomainsModel
        delegate: StatusListItem {
            Layout.preferredWidth: parent.width
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
