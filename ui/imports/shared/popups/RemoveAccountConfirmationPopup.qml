import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

import AppLayouts.Wallet 1.0

import utils 1.0
import shared.controls 1.0

StatusDialog {
    id: root

    required property string accountType
    required property string accountName
    required property string accountAddress
    required property string accountDerivationPath
    required property string preferredSharingNetworkShortNames
    required property string emoji
    required property string color

    signal removeAccount(string address)

    width: 521
    focus: visible
    padding: Style.current.padding

    QtObject {
        id: d
        readonly property int checkboxHeight: 24
        readonly property real lineHeight: 1.2

        function confirm() {
            if (root.accountType !== Constants.watchWalletType && !derivationPathWritten.checked) {
                return
            }
            root.removeAccount(root.accountAddress)
        }
    }

     header: StatusDialogHeader {
        headline.title: qsTr("Remove %1").arg(root.accountName)
        headline.subtitle: WalletUtils.colorizedChainPrefix(root.preferredSharingNetworkShortNames) + StatusQUtils.Utils.elideText(root.accountAddress, 6, 4)
        actions.closeButton.onClicked: root.close()
        leftComponent: StatusSmartIdenticon {
            asset.emoji: root.emoji
            asset.color: root.color
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
            text: {
                switch(root.accountType) {
                    case Constants.generatedWalletType: return qsTr("Are you sure you want to remove %1? The account will be removed from all of your synced devices. Make sure you have a backup of your keys or recovery phrase before proceeding. %2 Copying the derivation path to this account now will enable you to import it again at a later date should you wish to do so:").arg("<b>%1</b>".arg(root.accountName)).arg("<br/><br/>")
                    case Constants.watchWalletType: return  qsTr("Are you sure you want to remove %1? The address will be removed from all of your synced devices.").arg("<b>%1</b>".arg(root.accountName))
                    case Constants.keyWalletType: return qsTr("Are you sure you want to remove %1 and it's associated private key? The account and private key will be removed from all of your synced devices.").arg("<b>%1</b>".arg(root.accountName))
                    case Constants.seedWalletType: return qsTr("Are you sure you want to remove %1? The account will be removed from all of your synced devices. Copying the derivation path to this account now will enable you to import it again at a later date should you with to do so:").arg("<b>%1</b>".arg(root.accountName))
                }
            }
        }

        StatusBaseText {
            Layout.preferredWidth: parent.width
            Layout.topMargin: Style.current.padding
            visible: root.accountType === Constants.generatedWalletType || root.accountType === Constants.seedWalletType
            text: qsTr("Derivation path for %1").arg(root.accountName)
            font.pixelSize: Style.current.primaryTextFontSize
            lineHeight: d.lineHeight
        }

        StatusInput {
            objectName: "RemoveAccountPopup-DerivationPath"
            Layout.preferredWidth: parent.width
            visible: root.accountType === Constants.generatedWalletType || root.accountType === Constants.seedWalletType
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
            visible: root.accountType !== Constants.watchWalletType
            spacing: Style.current.padding
            font.pixelSize: Style.current.primaryTextFontSize
            text: {
                if (root.accountType === Constants.keyWalletType) {
                    return qsTr("I have a copy of the private key")
                }
                return qsTr("I have taken note of the derivation path")
            }
        }
    }

    footer: StatusDialogFooter {
        spacing: Style.current.padding
        rightButtons: ObjectModel {
            StatusFlatButton {
                objectName: "RemoveAccountPopup-CancelButton"
                text: qsTr("Cancel")
                type: StatusBaseButton.Type.Normal
                onClicked: {
                    root.close()
                }
            }
            StatusButton {
                objectName: "RemoveAccountPopup-ConfirmButton"
                text: qsTr("Remove %1").arg(root.accountName)
                type: StatusBaseButton.Type.Danger
                enabled: root.accountType === Constants.watchWalletType || derivationPathWritten.checked
                focus: true
                Keys.onReturnPressed: function(event) {
                    d.confirm()
                }
                onClicked: {
                    d.confirm()
                }
            }
        }
    }
}
