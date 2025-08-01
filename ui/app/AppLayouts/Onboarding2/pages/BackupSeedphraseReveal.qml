import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import StatusQ.Core
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core.Theme

import AppLayouts.Onboarding2.components

import utils

OnboardingPage {
    id: root

    required property string mnemonic

    signal backupSeedphraseConfirmed()

    QtObject {
        id: d
        property bool seedphraseRevealed
        readonly property var mnemonicWords: Utils.splitWords(root.mnemonic)
    }

    contentItem: Item {
        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(440, root.availableWidth)
            spacing: Theme.xlPadding

            StatusBaseText {
                Layout.fillWidth: true
                text: qsTr("Backup your recovery phrase")
                font.pixelSize: Theme.fontSize22
                font.bold: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            StepIndicator {
                Layout.fillWidth: true
                spacing: Theme.halfPadding
                currentStep: 1
                totalSteps: 3
                caption: qsTr("Write down your 12-word recovery phrase to keep offline")
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: seedGrid.height

                GridLayout {
                    objectName: "seedGrid"
                    id: seedGrid
                    width: parent.width
                    columns: 2
                    columnSpacing: Theme.halfPadding
                    rowSpacing: columnSpacing

                    Repeater {
                        model: d.mnemonicWords
                        delegate: Frame {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            padding: Theme.smallPadding
                            background: Rectangle {
                                radius: Theme.radius
                                color: "transparent"
                                border.width: 1
                                border.color: Theme.palette.baseColor2
                            }
                            contentItem: RowLayout {
                                spacing: Theme.halfPadding
                                StatusBaseText {
                                    Layout.preferredWidth: idxMetrics.advanceWidth
                                    horizontalAlignment: Qt.AlignHCenter
                                    text: index + 1
                                    color: Theme.palette.baseColor1
                                    font: idxMetrics.font
                                }
                                StatusBaseText {
                                    Layout.fillWidth: true
                                    text: modelData
                                }
                            }
                        }
                    }
                    layer.enabled: !d.seedphraseRevealed
                    layer.effect: GaussianBlur {
                        radius: 16
                        samples: 33
                        transparentBorder: true
                    }
                }

                StatusButton {
                    objectName: "btnReveal"
                    anchors.centerIn: parent
                    text: qsTr("Reveal recovery phrase")
                    icon.name: "show"
                    type: StatusBaseButton.Type.Primary
                    visible: !d.seedphraseRevealed
                    onClicked: {
                        d.seedphraseRevealed = true
                    }
                }
            }

            StatusBaseText {
                Layout.fillWidth: true
                text: qsTr("Anyone who sees this will have access to your funds.")
                color: Theme.palette.dangerColor1
                wrapMode: Text.WordWrap
                horizontalAlignment: Qt.AlignHCenter
            }

            StatusButton {
                objectName: "btnConfirm"
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Confirm recovery phrase")
                enabled: d.seedphraseRevealed
                onClicked: {
                    root.backupSeedphraseConfirmed()
                    d.seedphraseRevealed = false
                }
            }
        }
    }

    TextMetrics {
        id: idxMetrics
        font.family: Theme.monoFont.name
        font.pixelSize: Theme.primaryTextFontSize
        text: "99"
    }
}
