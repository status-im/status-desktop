import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1

import shared.controls 1.0

ColumnLayout {
    id: root

    readonly property string syncCode: syncCodeInput.text
    readonly property bool syncCodeValid: syncCodeInput.text !== ""

    property bool pairingInProgress: false
    property bool pairingFailed: false
    property int pairingFailsCount: 0

    spacing: 40

    StatusInput {
        id: syncCodeInput
        enabled: !root.pairingInProgress
        Layout.alignment: Qt.AlignHCenter
        label: qsTr("Paste sync code")
        input.placeholderText: qsTr("eg. %1").arg("0x2Ef19")
        input.font: Theme.palette.monoFont.name
        input.placeholderFont: input.font
        input.rightComponent: StatusButton {
            size: StatusBaseButton.Size.Tiny
            enabled: syncCodeInput.input.edit.canPaste
            onClicked: syncCodeInput.input.edit.paste()
            text: qsTr("Paste")
        }
    }

    StatusSyncingInstructions {
        Layout.alignment: Qt.AlignHCenter
    }

    Item {
        Layout.alignment: Qt.AlignHCenter
        Layout.bottomMargin: 40
        implicitWidth: loadingLayout.implicitWidth
        implicitHeight: loadingLayout.implicitHeight

        ColumnLayout {
            id: loadingLayout

            anchors.fill: parent
            visible: root.pairingFailed
            width: parent.width

            Row {
                Layout.alignment: Qt.AlignHCenter
                visible: root.pairingFailsCount < 2
                spacing: 8

                StatusBaseText {
                    text: qsTr("Hmm, that didn't work")
                    font.pixelSize: 17
                    color: Theme.palette.dangerColor1
                }
                StatusEmoji {
                    emojiId: Emoji.iconId("🤔")
                }
            }

            StatusBaseText {
                Layout.alignment: Qt.AlignHCenter
                visible: root.pairingFailsCount >= 2
                text: qsTr("That still didn’t work")
                font.pixelSize: 17
                color: Theme.palette.dangerColor1
            }

            StatusBaseText {
                Layout.alignment: Qt.AlignHCenter
                text: root.pairingFailsCount < 2 ? qsTr("Please try pasting the sync code again.")
                                                  : qsTr("Double check to make sure the code isn’t expired.")
                color: Theme.palette.baseColor1
                font.pixelSize: 15
            }
        }

        StatusLoadingIndicator {
            anchors.centerIn: parent
            visible: root.pairingInProgress
        }
    }
}
