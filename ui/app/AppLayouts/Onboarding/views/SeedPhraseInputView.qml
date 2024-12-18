import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Onboarding.controls 1.0
import AppLayouts.Onboarding.stores 1.0

import utils 1.0
import shared.panels 1.0
import shared.stores 1.0
import shared.controls 1.0

Item {
    id: root

    property StartupStore startupStore

    QtObject {
        id: d

        property bool wrongSeedPhrase: root.startupStore.startupModuleInst.keycardData & Constants.predefinedKeycardData.wrongSeedPhrase

        onWrongSeedPhraseChanged: {
            if (wrongSeedPhrase) {
                if (root.startupStore.startupModuleInst.flowType === Constants.startupFlow.firstRunOldUserImportSeedPhrase) {
                    seedPhraseView.setWrongSeedPhraseMessage(qsTr("Profile key pair for the inserted recovery phrase is already set up"))
                    return
                }
                seedPhraseView.setWrongSeedPhraseMessage(qsTr("Recovery phrase doesn’t match the profile of an existing Keycard user on this device"))
            }
            else {
                seedPhraseView.setWrongSeedPhraseMessage("")
            }
        }
    }

    ColumnLayout {
        width: 565
        implicitHeight: contentItem.implicitHeight
        anchors.centerIn: parent
        spacing: 24

        StatusBaseText {
            id: headlineText
            font.pixelSize: 22
            font.weight: Font.Bold
            color: Theme.palette.directColor1
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Enter recovery phrase")
        }

        EnterSeedPhrase {
            id: seedPhraseView
            isSeedPhraseValid: root.startupStore.validMnemonic
            Layout.alignment: Qt.AlignHCenter
        }

        StatusButton {
            id: submitButton
            objectName: "seedPhraseViewSubmitButton"
            Layout.alignment: Qt.AlignHCenter
            enabled: seedPhraseView.seedPhraseIsValid
            text: {
                if (root.startupStore.currentStartupState.flowType === Constants.startupFlow.firstRunNewUserImportSeedPhrase) {
                    return qsTr("Import")
                }
                else if (root.startupStore.currentStartupState.flowType === Constants.startupFlow.firstRunOldUserImportSeedPhrase) {
                    return qsTr("Restore Status Profile")
                }
                else if (root.startupStore.currentStartupState.flowType === Constants.startupFlow.firstRunOldUserKeycardImport ||
                         root.startupStore.currentStartupState.flowType === Constants.startupFlow.appLogin) {
                    return qsTr("Recover Keycard")
                }
                else if (root.startupStore.currentStartupState.flowType === Constants.startupFlow.firstRunNewUserImportSeedPhraseIntoKeycard ||
                         root.startupStore.currentStartupState.flowType === Constants.startupFlow.lostKeycardReplacement ||
                         root.startupStore.currentStartupState.flowType === Constants.startupFlow.lostKeycardConvertToRegularAccount) {
                    return qsTr("Next")
                }
                return ""
            }
            onClicked: root.startupStore.doPrimaryAction()
        }
    }
}
