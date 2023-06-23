import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import Models 1.0

import AppLayouts.Communities.popups 1.0

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            PopupBackground {
                anchors.fill: parent
            }

            Button {
                anchors.centerIn: parent
                text: "Reopen"

                onClicked: dialog.open()
            }

            AlertPopup {
                id: dialog

                anchors.centerIn: parent
                title: qsTr("Remotely destruct %n token(s)", "", 12)
                acceptBtnText: qsTr("Remotely destruct")
                alertText: qsTr("Continuing will destroy tokens held by members and revoke any perissions they given. To undo you will have to issue them new tokens.")

                onAcceptClicked: logs.logEvent("AlertPopup::onAcceptClicked")
                onCancelClicked: logs.logEvent("AlertPopup::onCancelClicked")

            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 150

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300
    }
}


