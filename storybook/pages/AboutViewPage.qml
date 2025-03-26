import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import AppLayouts.Profile.views 1.0

import Storybook 1.0

import utils 1.0

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        AboutView {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            contentWidth: parent.width

            store: QtObject {
                readonly property bool isProduction: ctrlProduction.checked

                function checkForUpdates() {
                    logs.logEvent("store::checkForUpdates")
                }

                function getCurrentVersion() {
                    logs.logEvent("store::getCurrentVersion")
                    return isProduction ? "0.13.2" : "0.13.2-dev"
                }

                function getGitCommit() {
                    logs.logEvent("store::getGitCommit")
                    return "92b88e8a3e1d48f2c39d1db6e4d577ebbe21f7a9"
                }

                function getStatusGoVersion() {
                    logs.logEvent("store::getStatusGoVersion")
                    return "v0.162.9"
                }

                function qtRuntimeVersion() {
                    return SystemUtils.qtRuntimeVersion()
                }

                function getReleaseNotes() {
                    logs.logEvent("store::getReleaseNotes")
                    const link = isProduction ? "https://github.com/status-im/status-desktop/releases/tag/%1".arg(getCurrentVersion()) :
                                                "https://github.com/status-im/status-desktop/commit/%1".arg(getGitCommit())

                    openLink(link)
                }

                function openLink(url) {
                    logs.logEvent("store::openLink", ["url"], arguments)
                    Qt.openUrlExternally(url)
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

    Switch {
        id: ctrlProduction
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300
        text: "Production"
        checked: true
    }
}

// category: Views
// status: good
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=1159%3A114479
// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=1684%3A127762
