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
        property string seedPhrase: "abandon gossip feed snow key resist name citizen tobacco seat invite excuse"
        property bool hideSeed: true
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        ConfirmSeedPhrasePanel {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            seedPhrase: mockData.seedPhrase.split(" ")
            hideSeed: mockData.hideSeed
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
                text: "seed phrase"
                font.weight: Font.Bold
            }

            TextField {
                Layout.fillWidth: true
                text: mockData.seedPhrase
                onTextChanged: mockData.seedPhrase = text
            }

            CheckBox {
                text: "hide seed phrase"
                checked: mockData.hideSeed
                onToggled: mockData.hideSeed = !mockData.hideSeed
            }
        }
    }
}
