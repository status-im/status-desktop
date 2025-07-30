import QtQuick
import QtQuick.Layouts

import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components

import utils

import AppLayouts.Wallet

ActivityNotificationBase {
    id: root

    property var community: null

    property var tokenData: root.notification.tokenData

    // Community properties:
    required property string communityId
    required property string communityName
    required property string communityImage

    // Notification type related properties:
    property bool isFirstTokenReceived: root.tokenData.isFirst
    readonly property bool isAssetType: root.tokenType === Constants.TokenType.ERC20

    // Token related properties:
    property string tokenAmount: {
        let amount = root.tokenData.amount
        // Double check if balance is string, then strip ending zeros (e.g. 1.0 -> 1)
        if (typeof amount === 'string' && amount.endsWith('0')) {
            amount = parseFloat(root.tokenData.amount)
            if (isNaN(amount))
                amount = "1"
            // Cast to Number to drop trailing zeros
            amount = Number(amount).toString()
        }
        return amount
    }
    property string tokenName: root.tokenData.name
    property string tokenSymbol: root.tokenData.symbol
    property string tokenImage: root.tokenData.imageUrl
    property int tokenType: root.tokenData.tokenType

    // Wallet related:
    property string txHash: root.tokenData.txHash
    required property string walletAccountName

    QtObject {
        id: d

        readonly property string formattedTokenName: root.isAssetType ? root.tokenSymbol : root.tokenName

        readonly property string ctaText: root.isFirstTokenReceived ? qsTr("Learn more") : qsTr("Transaction details")
        readonly property string title: root.isFirstTokenReceived ? (root.isAssetType ? qsTr("You received your first community asset") : qsTr("You received your first community collectible")) :
                                                                    qsTr("Tokens received")
        readonly property string info: {
            if (root.isFirstTokenReceived) {
                return qsTr("%1 %2 was airdropped to you from the %3 community").arg(root.tokenAmount).arg(d.formattedTokenName).arg(root.communityName)
            } else {
                return qsTr("You were airdropped %1 %2 from %3 to %4").arg(root.tokenAmount).arg(root.tokenName).arg(root.communityName).arg(root.walletAccountName)
            }
        }
    }

    bodyComponent: RowLayout {
        spacing: 8

        StatusRoundedImage {
            Layout.preferredWidth: 44
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: Theme.padding
            Layout.topMargin: 2

            radius: root.isAssetType ? width / 2 : 8
            width: 44
            height: width
            image.source: root.tokenImage
            showLoadingIndicator: false
            image.fillMode: Image.PreserveAspectCrop
        }

        ColumnLayout {
            spacing: 2
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true

            StatusMessageHeader {
                Layout.fillWidth: true
                displayNameLabel.text: d.title
                timestamp: root.notification.timestamp
            }

            RowLayout {
                spacing: Theme.padding

                StatusBaseText {
                    Layout.fillWidth: true
                    text: d.info
                    font.italic: true
                    wrapMode: Text.WordWrap
                    color: Theme.palette.baseColor1
                }
            }
        }
    }

    ctaComponent: StatusFlatButton {
        size: StatusBaseButton.Size.Small
        text: d.ctaText
        onClicked: {
            root.closeActivityCenter()
            if(root.isFirstTokenReceived) {
                Global.openFirstTokenReceivedPopup(root.communityId,
                                                   root.communityName,
                                                   root.communityImage,
                                                   root.tokenSymbol,
                                                   root.tokenName,
                                                   root.tokenAmount,
                                                   root.tokenType,
                                                   root.tokenImage);
            }
            else {
                Global.changeAppSectionBySectionType(Constants.appSection.wallet,
                                                     WalletLayout.LeftPanelSelection.Address,
                                                     WalletLayout.RightPanelSelection.Activity,
                                                     {address: root.tokenData.walletAddress,
                                                     txHash: root.txHash})
            }
        }
    }
}
