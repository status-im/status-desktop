import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Onboarding.views 1.0
import AppLayouts.Onboarding.stores 1.0

import utils 1.0

import Storybook 1.0

SplitView {
    Logs { id: logs }

    SeedPhraseInputView {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        
        startupStore: StartupStore {
            id: startupStore
            function validMnemonic(mnemonic) {
                return true
            }
            property QtObject startupModuleInst: QtObject {
                property int keycardData: keycardDataCheckbox.checked ? 0 : Constants.predefinedKeycardData.wrongSeedPhrase
                property string flowType: flowTypeComboBox.currentText
            }
            property QtObject currentStartupState: QtObject {
                property string flowType: flowTypeComboBox.currentText
            }
            
            function doPrimaryAction() {
                 logs.logEvent("Primary action clicked")
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200
        SplitView.preferredWidth: 300

        logsView.logText: logs.logText

        ColumnLayout {
            spacing: 10
            width: parent.width

            CheckBox {
                id: keycardDataCheckbox
                text: "Has keycard data"
                checked: startupStore.startupModuleInst.keycardData != Constants.predefinedKeycardData.wrongSeedPhrase
            }


            Label {
                text: "Current startup flow type"
            }
            ComboBox {
                id: flowTypeComboBox
                Layout.fillWidth: true
                model: Object.values(Constants.startupFlow).filter(flow => flow != "" && typeof flow === "string")
            }


        }
    }
}

// category: Panels
