import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.14

import AppLayouts.TradingCenter.controls 1.0

SplitView {
    orientation: Qt.Vertical

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        Paginator {
            id: paginator
            anchors.centerIn: parent
            pageSize: Number(pageSizeInput.text)
            totalCount: Number(tokenCountInput.text)
        }
    }

    ColumnLayout {
        SplitView.fillWidth: true
        Label {
            text: "Total Tokens Count"
        }
        TextInput {
            id: tokenCountInput
            Layout.preferredWidth: 100
            Layout.preferredHeight: 100
            validator: IntValidator { bottom: 0 }
            text: "5000"
        }

        Label {
            text: "Page Size"
        }
        TextInput {
            id: pageSizeInput
            Layout.preferredWidth: 100
            Layout.preferredHeight: 100
            validator: IntValidator { bottom: 0 }
            text: "100"
        }
    }
}

// category: Controls

// https://www.figma.com/design/mh7hMVynZjL3eiV7e5oEyk/Trading?node-id=243-268215&m=dev
