import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Components 0.1

import Sandbox 0.1

Item {
    id: root

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

    GridLayout {
        id: mainLayout

        columns: 2

        anchors.fill: parent

        columnSpacing: 15
        rowSpacing: 8

        StatusBaseText { text: "StatusAddress\nsimple" }
        StatusAddress {
            text: "0x9ce0056c5fc6bb9459a4dcfa35eaad8c1fee5ce9"
        }

        StatusBaseText { text: "StatusAddress\nclick-expandable" }
        StatusAddress {
            text: "0x9ce0056c5fc6bb9459a4dcfa35eaad8c1fee5ce9"

            Layout.preferredWidth: 200

            expandable: true
        }

        StatusBaseText { text: `StatusAddressPanel\nfont.pixelSize: 13, copyable, no frame`}
        StatusAddressPanel {
            address: "0xDC2c4826f6C56F61C1b9cC6Bb531d0Fe45402fC9"

            font.pixelSize: 13
            font.weight: Font.Normal

            showFrame: false

            onDoCopy: copyAction.text = address
        }

        StatusBaseText { text: `StatusAddressPanel\ncompact; width ${simpleAddressPanel.width}px ${simpleAddressPanel.height}px`}
        StatusAddressPanel {
            id: simpleAddressPanel
            address: "0xd8593DEACe2f44dF35dd23fD2BAFC2daeC2ae033"
            showCopy: false
            expanded: false
            onDoCopy: copyAction.text = address
            expandable: true
        }

        StatusBaseText { text: "StatusAddressPanel\ncopy-icon, non-expandable" }
        StatusAddressPanel {
            address: "0xDd5A0755e99D66a583253372B569231968A6CF7b"
            onDoCopy: copyAction.text = address
        }

        StatusBaseText { text: "StatusAddressPanel\ncopy hiden" }
        StatusAddressPanel {
            address: "0xd2D44C2A1E78975506e474Ecdc7E4F272D7e9A6c"
            autHideCopyIcon: true
            onDoCopy: copyAction.text = address
            expandable: true
        }
        StatusBaseText { text: "StatusAddressPanel\ncopy hiden, non-expandable" }
        StatusAddressPanel {
            address: "0xd2a44BA31E78975506e474Ecdc7E4F272D7F3BC5"
            autHideCopyIcon: true
            expanded: false
            onDoCopy: copyAction.text = address
        }

        Rectangle {
            color: "lightblue"

            Layout.fillWidth: true
            Layout.columnSpan: mainLayout.columns
            Layout.preferredHeight: 2
        }

        StatusBaseText {
            text: qsTr("Copy Action: ")
        }
        StatusBaseText {
            id: copyAction
        }
    }
}
