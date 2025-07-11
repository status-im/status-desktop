import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core.Theme

OnboardingPage {
    id: root

    signal backupSeedphraseContinue()

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
            Frame {
                Layout.fillWidth: true
                padding: 12
                background: Rectangle {
                    color: Theme.palette.dangerColor3
                    radius: Theme.radius
                }
                contentItem: StatusBaseText {
                    text: qsTr("Store your recovery phrase in a secure location so you never lose access to your funds.")
                    color: Theme.palette.dangerColor1
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Qt.AlignHCenter
                    lineHeightMode: Text.FixedHeight
                    lineHeight: 22
                }
            }
            StatusBaseText {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.weight: Font.DemiBold
                text: qsTr("Backup checklist:")
            }
            Frame {
                Layout.fillWidth: true
                Layout.topMargin: -20
                padding: 20
                background: Rectangle {
                    color: "transparent"
                    radius: 12
                    border.width: 1
                    border.color: Theme.palette.baseColor2
                }
                contentItem: ColumnLayout {
                    StatusCheckBox {
                        objectName: "ack1"
                        Layout.fillWidth: true
                        id: ack1
                        text: qsTr("I have a pen and paper")
                    }
                    StatusCheckBox {
                        objectName: "ack2"
                        Layout.fillWidth: true
                        id: ack2
                        text: qsTr("I am ready to write down my recovery phrase")
                    }
                    StatusCheckBox {
                        objectName: "ack3"
                        Layout.fillWidth: true
                        id: ack3
                        text: qsTr("I know where I’ll store it")
                    }
                    StatusCheckBox {
                        objectName: "ack4"
                        Layout.fillWidth: true
                        id: ack4
                        text: qsTr("I know I can only reveal it once")
                    }
                }
            }
            StatusButton {
                objectName: "btnContinue"
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Continue")
                enabled: ack1.checked && ack2.checked && ack3.checked && ack4.checked
                onClicked: root.backupSeedphraseContinue()
            }
        }
    }
}
