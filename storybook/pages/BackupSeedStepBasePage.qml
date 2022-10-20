import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Profile.views 1.0
import AppLayouts.Profile.popups 1.0

import Storybook 1.0

import utils 1.0

SplitView {
    Logs { id: logs }

    property var mockData: QtObject {
        property int wordNumber: 0
        property string word: "hello"
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        BackupSeedStepBase {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            wordRandomNumber: mockData.wordNumber
            wordAtRandomNumber: mockData.word
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
            width: parent.width

            Label {
                text: "seed word"
                font.weight: Font.Bold
            }

            TextField {
                Layout.fillWidth: true
                text: mockData.word
                onTextChanged: mockData.word = text
            }

            Label {
                text: "seed number"
                font.weight: Font.Bold
            }

            TextField {
                Layout.fillWidth: true
                text: mockData.wordNumber
                onTextChanged: mockData.wordNumber = parseInt(text)
            }
        }
    }
}
