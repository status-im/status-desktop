import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Profile.views 1.0
import AppLayouts.Profile.popups 1.0

import Storybook 1.0

import utils 1.0

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Label {
            text: "Modal currently not working here"
            font.weight: Font.Bold
        }

        BackupSeedModal {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            privacyStore: QtObject {
                function removeMnemonic() {
                    logs.logEvent("privacyStore::removeMnemonic")
                }

                function getMnemonic() {
                    logs.logEvent("privacyStore::getMnemonic")
                    return "abandon gossip feed snow key resist name citizen tobacco seat invite excuse"
                }

                function getMnemonicWordAtIndex(index) {
                    logs.logEvent("privacyStore::getMnemonicWordAtIndex", ["index"], arguments)
                    return "abandon gossip feed snow key resist name citizen tobacco seat invite excuse".split(" ")[index]
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }
    }

    Control {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        font.pixelSize: 13

        // model editor will go here
    }
}
