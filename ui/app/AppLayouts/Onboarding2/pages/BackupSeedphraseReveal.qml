import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Onboarding2.components 1.0

OnboardingPage {
    id: root

    required property var seedWords

    signal backupSeedphraseConfirmed()

    pageClassName: "BackupSeedphraseReveal"

    QtObject {
        id: d
        property bool seedphraseRevealed
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
                        model: root.seedWords
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
                    onClicked: d.seedphraseRevealed = true
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
