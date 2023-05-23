import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.controls 1.0

StatusModal {
    id: root

    required property bool simple
    required property string accountName
    required property string accountAddress
    required property string accountDerivationPath

    signal removeAccount(string address)

    headerSettings.title: qsTr("Remove %1").arg(root.accountName)
    focus: visible
    padding: Style.current.padding

    QtObject {
        id: d
        readonly property int checkboxHeight: 24
        readonly property real lineHeight: 1.2

        function confirm() {
            if (!root.simple && !derivationPathWritten.checked) {
                return
            }
            root.removeAccount(root.accountAddress)
        }
    }

    contentItem: ColumnLayout {
        spacing: Style.current.halfPadding

        StatusBaseText {
            objectName: "RemoveAccountPopup-Notification"
            Layout.preferredWidth: parent.width
            wrapMode: Text.WordWrap
            textFormat: Text.RichText
            font.pixelSize: Style.current.primaryTextFontSize
            lineHeight: d.lineHeight
            text: root.simple?
                      qsTr("Are you sure you want to remove %1?
The account will be removed from all of your synced devices.").arg("<b>%1</b>".arg(root.accountName))
                    : qsTr("Are you sure you want to remove %1?
The account will be removed from all of your synced devices.
Make sure you have a backup of your keys or recovery phrase before proceeding.
%2
Copying the derivation path to this account now will enable you to import it again
at a later date should you wish to do so:").arg("<b>%1</b>".arg(root.accountName)).arg("<br/><br/>")
        }

        StatusBaseText {
            Layout.preferredWidth: parent.width
            Layout.topMargin: Style.current.padding
            visible: !root.simple
            text: qsTr("Derivation path for %1").arg(root.accountName)
            font.pixelSize: Style.current.primaryTextFontSize
            lineHeight: d.lineHeight
        }

        StatusInput {
            objectName: "RemoveAccountPopup-DerivationPath"
            Layout.preferredWidth: parent.width
            visible: !root.simple
            input.edit.enabled: false
            text: root.accountDerivationPath
            input.background.color: "transparent"
            input.background.border.color: Theme.palette.baseColor2
            input.rightComponent: CopyButton {
                textToCopy: root.accountDerivationPath
            }
        }

        StatusCheckBox {
            id: derivationPathWritten
            objectName: "RemoveAccountPopup-HavePenPaper"
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: d.checkboxHeight
            Layout.topMargin: Style.current.padding
            visible: !root.simple
            spacing: Style.current.padding
            font.pixelSize: Style.current.primaryTextFontSize
            text: qsTr("I have a pen and paper")
        }
    }

    rightButtons: [
        StatusFlatButton {
            objectName: "RemoveAccountPopup-CancelButton"
            text: qsTr("Cancel")
            type: StatusBaseButton.Type.Normal
            onClicked: {
                root.close()
            }
        },
        StatusButton {
            objectName: "RemoveAccountPopup-ConfirmButton"
            text: qsTr("Remove")
            type: StatusBaseButton.Type.Danger
            enabled: root.simple || derivationPathWritten.checked
            focus: true
            Keys.onReturnPressed: function(event) {
                d.confirm()
            }
            onClicked: {
                d.confirm()
            }
        }
    ]
}
