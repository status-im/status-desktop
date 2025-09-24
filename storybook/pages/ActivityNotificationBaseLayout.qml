import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Storybook

import utils

SplitView {
    id: root

    property alias activityNotificationComponent: notificationLoader.sourceComponent
    property alias additionalEditorComponent: additionalEditorLoader.sourceComponent

    property bool showBaseEditorFields: true
    required property bool communityEditorActive
    required property bool contactEditorActive

    readonly property var baseEditor: baseEditor
    readonly property var communityEditor: communityEditorLoader.item
    readonly property var conntactEditor: contactEditorLoader.item
    readonly property alias logs: logsInternal

    readonly property int leftPanelMaxWidth: 308 // It fits on mobile / portrait + desktop left panel

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Logs { id: logsInternal }

        Item {
            SplitView.fillHeight: true
            SplitView.fillWidth: true
            Loader {
                id: notificationLoader
                anchors.centerIn: parent
                width: root.leftPanelMaxWidth
            }
        }

        LogsAndControlsPanel {
            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 160

            logsView.logText: logs.logText
        }

    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ActivityNotificationBaseEditor {
            id: baseEditor

            showBaseEditorFields: root.showBaseEditorFields

            Loader {
                id: contactEditorLoader
                active: root.contactEditorActive
                sourceComponent: contactEditorComponent
            }

            Loader {
                id: communityEditorLoader
                active: root.communityEditorActive
                sourceComponent: communityEditorComponent
            }

            Loader {
                id: additionalEditorLoader
            }
        }
    }

    Component {
        id: communityEditorComponent

        ActivityNotificationCommunityEditor {
            id: communityEditor
        }
    }

    Component {
        id: contactEditorComponent

        ActivityNotificationContactEditor {
            id: contactEditor
        }
    }
}
