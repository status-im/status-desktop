import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.14

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusDialog {
    id: root

    property string communityName: ""
    property string privateKey: ""

    signal deletePrivateKey

    width: 640
    title: qsTr("Move %1 community control node").arg(root.communityName)

    closePolicy: Popup.NoAutoClose

    component Paragraph: StatusBaseText {
        Layout.fillWidth: true
        Layout.minimumHeight: 40
        font.pixelSize: Style.current.primaryTextFontSize
        lineHeightMode: Text.FixedHeight
        lineHeight: 22
        wrapMode: Text.Wrap
        verticalAlignment: Text.AlignVCenter
    }

    component CopyButton: StatusButton {
        id: copyButton
        borderColor: textColor
        disabledTextColor: textColor
        disabledColor: normalColor
        text: qsTr("Copy")
        size: StatusButton.Size.Tiny
        states: [
            State {
                name: "success"
                PropertyChanges {
                    target: copyButton
                    text: ""
                    icon.name: "checkmark"
                    normalColor: Theme.palette.successColor2
                    textColor: Theme.palette.successColor1
                    enabled: false
                }
            }
        ]

        onClicked: {
            width = width // break the biding to prevent the button from shrinking
            copyButton.state = "success"
            Backpressure.debounce(root, 2000, function () {
                copyButton.state = ""
            })()
        }
    }

    StatusScrollView {
        id: scroll
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            id: layout
            width: scroll.availableWidth
            spacing: 20
            Paragraph {
                text: qsTr("For a Status Community to function, it needs to have a single control node running. This installation of Status Desktop is currently the %1 community control node. To move the %1 control node to another device: ").arg(root.communityName)
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                Paragraph {
                    text: qsTr("1. Copy your Community’s private key:")
                }
                StatusBaseInput {
                    id: privateKeyTextArea
                    Layout.fillWidth: true
                    multiline: true
                    edit.readOnly: true
                    text: root.privateKey
                    rightComponent: CopyButton {
                        onClicked: {
                            privateKeyTextArea.edit.selectAll()
                            privateKeyTextArea.edit.copy()
                            privateKeyTextArea.edit.deselect()
                        }
                    }
                }
                Paragraph {
                    text: qsTr("2. Stop using this computer as a control node")
                }
                Paragraph {
                    text: qsTr("3. Import this Community via private key on another installation of Status desktop")
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                StatusDialogDivider { Layout.fillWidth: true }
                Item { Layout.fillHeight: true }
                Paragraph {
                    text: qsTr("I acknowledge that...")
                }

                StatusCheckBox {
                    id: agreeToStopControl
                    Layout.fillWidth: true
                    font.pixelSize: Style.current.primaryTextFontSize
                    text: qsTr("%1 will stop working without a control node").arg(root.communityName)
                }
                StatusCheckBox {
                    id: agreeToSavePrivateKey
                    Layout.fillWidth: true
                    Layout.minimumHeight: 40
                    font.pixelSize: Style.current.primaryTextFontSize
                    text: qsTr("I have saved the %1 private key").arg(root.communityName)
                }
                StatusCheckBox {
                    id: agreeToDeletePrivateKey
                    Layout.fillWidth: true
                    Layout.minimumHeight: 40
                    font.pixelSize: Style.current.primaryTextFontSize
                    text: qsTr("If I lose the private key, %1 will be unrecoverable").arg(root.communityName)
                }
            }
        }
    }   
    footer: StatusDialogFooter {
        rightButtons: ObjectModel { 
            StatusButton {
                text: qsTr("Delete private key and stop control node")
                enabled: agreeToStopControl.checked && agreeToSavePrivateKey.checked && agreeToDeletePrivateKey.checked
                type: StatusBaseButton.Type.Danger
                onClicked: {
                    root.deletePrivateKey()
                    root.close()
                }
            }
        }
    }
}
