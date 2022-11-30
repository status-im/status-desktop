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

Item {
    id: root
    property var ensUsernamesStore
    property var contactsStore
    property string username: ""
    property string walletAddress: "-"
    property string key: "-"
    property var expiration: 0

    signal backBtnClicked();
    signal usernameReleased(username: string);

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
        onDetailsObtained: {
            if(username != (isStatus ? ensName + ".stateofus.eth" : ensName))
                return;
            walletAddressLbl.subTitle = address;
            keyLbl.subTitle = pubkey.substring(0, 20) + "..." + pubkey.substring(pubkey.length - 20);
            walletAddressLbl.visible = true;
            keyLbl.visible = true;
            releaseBtn.visible = isStatus
            releaseBtn.enabled = (Date.now() / 1000) > expirationTime && expirationTime > 0 &&
                    root.ensUsernamesStore.preferredUsername != username
                    releaseBtn.enabled = true
            expiration = new Date(expirationTime * 1000).getTime()
        }
        onLoading: {
            loadingImg.active = isLoading
            if(!isLoading) return;
            walletAddressLbl.visible = false;
            keyLbl.visible = false;
            releaseBtn.visible = false;
            expiration = 0;
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
            sendType: Constants.SendType.ENSRelease
            preSelectedRecipient: root.ensUsernamesStore.getEnsRegisteredAddress()
            preDefinedAmountToSend: LocaleUtils.numberToLocaleString(0)
            preSelectedAsset: {
                let assetsList = releaseEnsModal.store.currentAccount.assets
                for(var i=0; i< assetsList.count;i++) {
                    if("ETH" === assetsList.rowData(i, "symbol"))
                        return {
                            name: assetsList.rowData(i, "name"),
                            symbol: assetsList.rowData(i, "symbol"),
                            totalBalance: assetsList.rowData(i, "totalBalance"),
                            totalCurrencyBalance: assetsList.rowData(i, "totalCurrencyBalance"),
                            balances: assetsList.rowData(i, "balances"),
                            decimals: assetsList.rowData(i, "decimals")
                        }
                }
                return {}
            }
            sendTransaction: function() {
                if(bestRoutes.length === 1) {
                    let path = bestRoutes[0]
                    let eip1559Enabled = path.gasFees.eip1559Enabled
                    let maxFeePerGas = path.gasFees.maxFeePerGasM
                    root.ensUsernamesStore.authenticateAndReleaseEns(
                                root.username,
                                selectedAccount.address,
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
                onTransactionWasSent: {
                    try {
                        let response = JSON.parse(txResult)
                        if (!response.success) {
                            if (response.result.includes(Constants.walletSection.cancelledMessage)) {
                                return
                            }
                            releaseEnsModal.sendingError.text = response.result
                            return releaseEnsModal.sendingError.open()
                        }
                        usernameReleased(username);
                        let url = `${releaseEnsModal.store.getEtherscanLink()}/${response.result}`;
                        Global.displayToastMessage(qsTr("Transaction pending..."),
                                                   qsTr("View on etherscan"),
                                                   "",
                                                   true,
                                                   Constants.ephemeralNotificationType.normal,
                                                   url)
                    } catch (e) {
                        console.error('Error parsing the response', e)
                    }
                    releaseEnsModal.close()
                }
            }
        }
    }

    StatusQControls.StatusButton {
        id: releaseBtn
        visible: false
        enabled: false
        anchors.top: keyLbl.bottom
        anchors.topMargin: 24
        anchors.left: parent.left
        anchors.leftMargin: 24
        text: qsTr("Release username")
        onClicked: {
            Global.openPopup(transactionDialogComponent)
        }
    }

    Text {
        visible: releaseBtn.visible && !releaseBtn.enabled
        anchors.top: releaseBtn.bottom
        anchors.topMargin: 2
        anchors.left: parent.left
        anchors.leftMargin: 24
        text: qsTr("Username locked. You won't be able to release it until %1").arg(Utils.formatShortDateStr(new Date(expiration).toDateString()))
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
