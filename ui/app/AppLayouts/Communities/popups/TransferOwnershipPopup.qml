import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Components 0.1

import shared.popups 1.0

import utils 1.0

StatusDialog {
    id: root

    // Community related props:
    property string communityId
    property string communityName
    property string communityLogo

    // Transaction related props:
    property var token // Expected roles: accountAddress, key, chainId, name, artworkSource
    property var accounts
    property var sendModalPopup

    signal cancelClicked

    width: 640 // by design
    padding: Style.current.padding
    contentItem: ColumnLayout {
        spacing: Style.current.bigPadding

        component CustomText : StatusBaseText {
            Layout.fillWidth: true

            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.pixelSize: Style.current.primaryTextFontSize
            color: Theme.palette.directColor1
        }

        CustomText {
            Layout.topMargin: Style.current.halfPadding

            text: qsTr("Are you sure you want to transfer ownership of %1? All ownership rights you currently hold for %1 will be transferred to the new owner.").arg(root.communityName)
        }

        CustomText {
            text: qsTr("To transfer ownership of %1:").arg(root.communityName)
            font.bold: true
        }

        CustomText {
            text: qsTr("1. Send the %1 Owner token (%2) to the new owner’s address").arg(root.communityName).arg(token.name)
        }

        CustomText {
            text: qsTr("2. Ask the new owner to setup the control node for %1 on their desktop device").arg(root.communityName)
        }

        StatusMenuSeparator {
            Layout.fillWidth: true
        }

        CustomText {
            text: qsTr("I acknowledge that...")
        }

        StatusCheckBox {
            id: ackCheckBox

            Layout.topMargin: -Style.current.halfPadding
            Layout.bottomMargin: Style.current.halfPadding

            font.pixelSize: Style.current.primaryTextFontSize
            text: qsTr("My ownership rights will be removed and transferred to the recipient")
        }
    }

    header: StatusDialogHeader {
        headline.title: qsTr("Transfer ownership of %1").arg(root.communityName)
        actions.closeButton.onClicked: root.close()
        leftComponent: StatusSmartIdenticon {
            asset.name: root.communityLogo
            asset.isImage: !!asset.name
        }
    }

    footer: StatusDialogFooter {
        spacing: Style.current.padding
        rightButtons: ObjectModel {
            StatusFlatButton {
                text: qsTr("Cancel")

                onClicked: {
                    root.cancelClicked()
                    close()
                }
            }

            StatusButton {
                enabled: ackCheckBox.checked
                text: qsTr("Send %1 owner token").arg(root.communityName)
                type: StatusBaseButton.Type.Danger

                onClicked: {
                    // Pre-populated dialog with the relevant Owner token info:
                    root.sendModalPopup.preSelectedSendType = Constants.SendType.ERC721Transfer
                    root.sendModalPopup.preSelectedAccount = ModelUtils.getByKey(root.accounts, "address", token.accountAddress)
                    const uid = token.chainId+"+"+token.tokenAddress.toLowerCase()+"+"+"0" // TODO use getUidForData
                    root.sendModalPopup.preSelectedHoldingID = uid
                    root.sendModalPopup.preSelectedHoldingType = Constants.TokenType.ERC721
                    root.sendModalPopup.open()
                    close()
                }
            }
        }
    }
}
