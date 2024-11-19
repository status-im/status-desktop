import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Onboarding2.components 1.0

import shared.stores 1.0

import SortFilterProxyModel 0.2

OnboardingPage {
    id: root

    required property var seedWordsToVerify // [{seedWordNumber:int, seedWord:string}, ...]

    signal backupSeedphraseVerified()

    pageClassName: "BackupSeedphraseVerify"

    QtObject {
        id: d
        readonly property var seedSuggestions: BIP39_en {} // [{seedWord:string}, ...]
    }

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(440, root.availableWidth)
            spacing: Theme.xlPadding

            StatusBaseText {
                Layout.fillWidth: true
                text: qsTr("Backup your recovery phrase")
                font.pixelSize: 22
                font.bold: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            StepIndicator {
                Layout.fillWidth: true
                spacing: Theme.halfPadding
                currentStep: 2
                totalSteps: 3
                caption: qsTr("Confirm the following words from your recovery phrase...")
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.halfPadding
                Repeater {
                    readonly property bool allValid: {
                        for (let i = 0; i < count; i++) {
                            if (!!itemAt(i) && !itemAt(i).valid)
                                return false
                        }
                        return true
                    }

                    id: seedRepeater
                    model: root.seedWordsToVerify
                    delegate: RowLayout {
                        id: seedWordDelegate

                        required property var modelData
                        required property int index

                        readonly property bool valid: seedInput.valid
                        readonly property alias input: seedInput

                        Layout.fillWidth: true
                        Layout.topMargin: Theme.halfPadding
                        Layout.bottomMargin: Theme.halfPadding
                        spacing: 12
                        StatusBaseText {
                            Layout.preferredWidth: 20
                            text: modelData.seedWordNumber
                        }
                        SeedphraseVerifyInput {
                            Layout.fillWidth: true
                            id: seedInput
                            valid: text === modelData.seedWord
                            seedSuggestions: d.seedSuggestions
                            Component.onCompleted: if (index === 0) forceActiveFocus()
                            onAccepted: {
                                if (seedRepeater.allValid) { // move to next page
                                    root.backupSeedphraseVerified()
                                } else { // move to next field
                                    const nextItem = seedRepeater.itemAt(index + 1) ?? seedRepeater.itemAt(0)
                                    if (!!nextItem) {
                                        nextItem.input.forceActiveFocus()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            StatusButton {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Continue")
                enabled: seedRepeater.allValid
                onClicked: root.backupSeedphraseVerified()
            }
        }
    }
}
