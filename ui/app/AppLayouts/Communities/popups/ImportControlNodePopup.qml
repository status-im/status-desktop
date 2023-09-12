import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15
import QtQml.Models 2.14

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusDialog {
    id: root

    required property var community

    signal importControlNode(var community)

    width: 640

    header: StatusDialogHeader {
        headline.title: qsTr("Make this device the control node for %1").arg(root.community.name)
        actions.closeButton.onClicked: root.close()
        leftComponent: StatusSmartIdenticon {
            asset.name: root.community.image
            asset.isImage: !!asset.name
        }
    }

    closePolicy: Popup.NoAutoClose

    component Paragraph: StatusBaseText {
        Layout.fillWidth: true
        font.pixelSize: Style.current.primaryTextFontSize
        lineHeightMode: Text.FixedHeight
        lineHeight: 22
        wrapMode: Text.Wrap
        verticalAlignment: Text.AlignVCenter
    }

    contentItem: ColumnLayout {
        spacing: Style.current.padding
        Paragraph {
            text: qsTr("Are you sure you want to make this device the control node for %1? This device should be one that you are able to keep online and running Status at all times to enable the Community to function correctly.").arg(root.community.name)
        }
        StatusDialogDivider {
            Layout.fillWidth: true
        }
        Paragraph {
            text: qsTr("I acknowledge that...")
        }
        StatusCheckBox {
            id: agreementCheckBox
            Layout.fillWidth: true
            font.pixelSize: Style.current.primaryTextFontSize
            text: qsTr("I must keep this device online and running Status")
        }
        StatusCheckBox {
            id: agreementCheckBox2
            Layout.fillWidth: true
            font.pixelSize: Style.current.primaryTextFontSize
            text: qsTr("My other synced device will cease to be the control node for this Community")
        }
    }

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusFlatButton {
                text: qsTr("Cancel")
                onClicked: root.close()
            }
            StatusButton {
                text: qsTr("Make this device the control node for %1").arg(root.community.name)
                enabled: agreementCheckBox.checked && agreementCheckBox2.checked
                onClicked: {
                    root.importControlNode(root.community)
                    root.close()
                }
            }
        }
    }
}
