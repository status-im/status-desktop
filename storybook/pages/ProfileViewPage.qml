import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Profile.views 1.0
import shared.views 1.0 as SharedViews

import Storybook 1.0

import utils 1.0

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        MyProfileView {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            // contentWidth: parent.width

        //     store: QtObject {
        //         function checkForUpdates() {
        //             logs.logEvent("store::checkForUpdates")
        //         }

        //         function getCurrentVersion() {
        //             return "storybook-version"
        //         }

        //         function getReleaseNotes() {
        //             logs.logEvent("store::getReleaseNotes")
        //         }

        //         function openLink(url) {
        //             logs.logEvent("store::openLink", ["url"], arguments)
        //         }
        //     }
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

