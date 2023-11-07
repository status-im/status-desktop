import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1 as StatusQControls
import StatusQ.Components 0.1

import utils 1.0
import shared.status 1.0
import shared.popups 1.0
import shared.popups.send 1.0

Item {
    id: root
    property var ensUsernamesStore
    property var contactsStore
    property string username: ""
    property string chainId: ""
    property string walletAddress: "-"
    property string key: "-"

    signal backBtnClicked();
    signal usernameReleased()

    QtObject {
        id: d

        property double expirationTimestamp: 0
    }

    StatusBaseText {
        id: sectionTitle
        text: username
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
        color: Theme.palette.directColor1
    }

    Component {
        id: loadingImageComponent
        StatusLoadingIndicator {}
    }

    Loader {
        id: loadingImg
        active: false
        sourceComponent: loadingImageComponent
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.top: parent.top
        anchors.topMargin: Style.currentPadding
    }

    Connections {
        target: root.ensUsernamesStore.ensUsernamesModule
        function onDetailsObtained(ensName: string, address: string, pubkey: string, isStatus: bool, expirationTime: int) {
            if(username != (isStatus ? ensName + ".stateofus.eth" : ensName))
                return;
            walletAddressLbl.subTitle = address;
            keyLbl.subTitle = pubkey.substring(0, 20) + "..." + pubkey.substring(pubkey.length - 20);
            walletAddressLbl.visible = true;
            keyLbl.visible = true;
            releaseBtn.visible = isStatus
            removeButton.visible = true
            releaseBtn.enabled = expirationTime > 0
                                 && (Date.now() / 1000) > expirationTime
                                 && root.ensUsernamesStore.preferredUsername !== username
            d.expirationTimestamp = expirationTime * 1000
        }
        function onLoading(isLoading: bool) {
            loadingImg.active = isLoading
            if (!isLoading)
                return;
            walletAddressLbl.visible = false;
            keyLbl.visible = false;
            releaseBtn.visible = false;
            removeButton.visible = false;
            d.expirationTimestamp = 0;
        }
    }

    StatusDescriptionListItem {
        id: walletAddressLbl
        title: qsTr("Wallet address")
        visible: false
        anchors.top: sectionTitle.bottom
        anchors.topMargin: 24
        asset.name: "copy"
        tooltip.text: qsTr("Copied to clipboard!")
        iconButton.onClicked: {
            root.ensUsernamesStore.copyToClipboard(subTitle)
            tooltip.visible = !tooltip.visible
        }
    }
    StatusDescriptionListItem {
        id: keyLbl
        title: qsTr("Key")
        visible: false
        anchors.top: walletAddressLbl.bottom
        anchors.topMargin: 24
        asset.name: "copy"
        tooltip.text: qsTr("Copied to clipboard!")
        iconButton.onClicked: {
            root.ensUsernamesStore.copyToClipboard(subTitle)
            tooltip.visible = !tooltip.visible
        }
    }

    Component {
        id: transactionDialogComponent
        SendModal {
            id: releaseEnsModal
            modalHeader: qsTr("Release your username")
            interactive: false
            preSelectedSendType: Constants.SendType.ENSRelease
            preSelectedRecipient: root.ensUsernamesStore.getEnsRegisteredAddress()
            preDefinedAmountToSend: LocaleUtils.numberToLocaleString(0)
            preSelectedHoldingID: Constants.ethToken
            preSelectedHoldingType: Constants.TokenType.ERC20
            sendTransaction: function() {
                if(bestRoutes.count === 1) {
                    let path = bestRoutes.firstItem()
                    let eip1559Enabled = path.gasFees.eip1559Enabled
                    let maxFeePerGas = path.gasFees.maxFeePerGasM
                    root.ensUsernamesStore.authenticateAndReleaseEns(
                                root.chainId,
                                root.username,
                                store.selectedSenderAccount.address,
                                path.gasAmount,
                                eip1559Enabled ? "" : path.gasFees.gasPrice,
                                eip1559Enabled ? path.gasFees.maxPriorityFeePerGas : "",
                                eip1559Enabled ? maxFeePerGas: path.gasFees.gasPrice,
                                eip1559Enabled,
                                )
                }
            }
            Connections {
                target: root.ensUsernamesStore.ensUsernamesModule
                function onTransactionWasSent(chainId: int, txHash: string, error: string) {
                    if (!!error) {
                        if (error.includes(Constants.walletSection.cancelledMessage)) {
                            return
                        }
                        releaseEnsModal.sendingError.text = error
                        return releaseEnsModal.sendingError.open()
                    }
                    usernameReleased()
                    let url =  "%1/%2".arg(releaseEnsModal.store.getEtherscanLink(chainId)).arg(txHash)
                    Global.displayToastMessage(qsTr("Transaction pending..."),
                                               qsTr("View on etherscan"),
                                               "",
                                               true,
                                               Constants.ephemeralNotificationType.normal,
                                               url)
                    releaseEnsModal.close()
                }
            }
        }
    }

    RowLayout {
        id: actionsLayout

        anchors.top: keyLbl.bottom
        anchors.topMargin: 24
        anchors.left: parent.left
        anchors.leftMargin: 24

        StatusQControls.StatusButton {
            id: removeButton
            visible: false
            type: StatusQControls.StatusBaseButton.Type.Danger
            text: qsTr("Remove username")
            onClicked: {
                root.ensUsernamesStore.removeEnsUsername(root.chainId, root.username)
                root.backBtnClicked()
            }
        }

        StatusQControls.StatusButton {
            id: releaseBtn
            visible: false
            enabled: false
            text: qsTr("Release username")
            onClicked: {
                Global.openPopup(transactionDialogComponent)
            }
        }
    }

    Text {
        visible: releaseBtn.visible && !releaseBtn.enabled
        anchors.top: actionsLayout.bottom
        anchors.topMargin: 2
        anchors.left: parent.left
        anchors.leftMargin: 24
        text: {
            const formattedDate = LocaleUtils.formatDate(d.expirationTimestamp, Locale.ShortFormat)
            return qsTr("Username locked. You won't be able to release it until %1").arg(formattedDate)
        }
        color: Style.current.darkGrey
    }

    StatusQControls.StatusButton {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Back")
        onClicked: backBtnClicked()
    }
}
