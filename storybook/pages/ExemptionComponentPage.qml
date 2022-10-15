import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Profile.views 1.0
import AppLayouts.Profile.views.notifications 1.0

import AppLayouts.Profile.stores 1.0

import Storybook 1.0

import utils 1.0

import "./ExemptionsComponent/"

SplitView {
    Logs { id: logs }

    ImageSelectPopup {
        id: imageSelector

        parent: root
        anchors.centerIn: parent
        width: parent.width * 0.8
        height: parent.height * 0.8

        model: ListModel {
            id: iconsModel
        }

        Component.onCompleted: {
            const uniqueIcons = StorybookUtils.getUniqueValuesFromModel(root.modelData, "image")
            uniqueIcons.map(image => iconsModel.append( { image }))
        }
    }

    property var modelData: ExemptionsComponentData {}

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        ExemptionView {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            contentWidth: parent.width
            exemptionsModel: modelData
            notificationsStore: NotificationsStore {
                function saveExemptions(itemId, muteAllMessages, personalMentions, globalMentions, allMessages) {
                    logs.logEvent("notificationsModule::sendTestNotification", ["itemId", "muteAllMessages", "personalMentions", "globalMentions", "allMessages"], arguments)
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

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12

            ExemptionsComponentControls {
                model: modelData
            }
        }
    }
}
