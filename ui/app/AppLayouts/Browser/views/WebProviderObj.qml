import QtQuick 2.13
import QtWebChannel 1.13
import QtQuick.Dialogs 1.2

import utils 1.0
import shared.controls 1.0

import "../stores"

QtObject {
    id: provider

    property var createAccessDialogComponent: function(){}
    property var createSendTransactionModalComponent: function(){}
    property var createSignMessageModalComponent: function(){}
    property var showSendingError: function(){}
    property var showSigningError: function(){}
    property var showToastMessage: function(){}
    property int networkId: (Web3ProviderStore && Web3ProviderStore.networkId) || -1

    signal web3Response(string data);

    function signValue(input){
        if(Utils.isHex(input) && Utils.startsWith0x(input)){
            return input
        }
        return RootStore.getAscii2Hex(input)
    }

    function postMessage(requestType, data) {
        var request;
        try {
            request = JSON.parse(data)
        } catch (e) {
            console.error("Error parsing the message data", e)
            return;
        }

        var ensAddr = Web3ProviderStore.urlENSDictionary[request.hostname];
        if (ensAddr) {
            request.hostname = ensAddr;
        }

        if (requestType === Constants.web3DisconnectAccount) {
            RootStore.currentTabConnected = true
            web3Response(JSON.stringify({type: Constants.web3DisconnectAccount}));
        } else if (requestType === Constants.api_request) {
            if (!Web3ProviderStore.web3ProviderInst.hasPermission(request.hostname, request.permission)) {
                RootStore.currentTabConnected = false
                var dialog = createAccessDialogComponent()
                dialog.request = request;
                dialog.open();
            } else {
                RootStore.currentTabConnected = true
                web3Response(Web3ProviderStore.web3ProviderInst.postMessage(requestType, JSON.stringify(request)));
            }
        } else if (requestType === Constants.web3SendAsyncReadOnly &&
                   request.payload.method === "eth_sendTransaction") {
            var acc = WalletStore.dappBrowserAccount
            const value = RootStore.getWei2Eth(request.payload.params[0].value, 18);
            const sendDialog = createSendTransactionModalComponent(request)

            sendDialog.sendTransaction = function (selectedGasLimit, selectedGasPrice, selectedTipLimit, selectedOverallLimit, enteredPassword) {
                let trx = request.payload.params[0]
                // TODO: use bignumber instead of floats
                trx.value = RootStore.getEth2Hex(parseFloat(value))
                trx.gas = "0x" + parseInt(selectedGasLimit, 10).toString(16)
                if (walletModel.transactionsView.isEIP1559Enabled) {
                    trx.maxPriorityFeePerGas = RootStore.getGwei2Hex(parseFloat(selectedTipLimit))
                    trx.maxFeePerGas = RootStore.getGwei2Hex(parseFloat(selectedOverallLimit))
                } else {
                    trx.gasPrice = RootStore.getGwei2Hex(parseFloat(selectedGasPrice))
                }

                request.payload.password = enteredPassword
                request.payload.params[0] = trx

                const response = Web3ProviderStore.web3ProviderInst.postMessage(requestType, JSON.stringify(request))
                provider.web3Response(response)

                let responseObj
                try {
                    responseObj = JSON.parse(response)

                    if (responseObj.error) {
                        throw new Error(responseObj.error)
                    }

                    showToastMessage(responseObj.result.result)
                } catch (e) {
                    if (Utils.isInvalidPasswordMessage(e.message)){
                        //% "Wrong password"
                        sendDialog.transactionSigner.validationError = qsTrId("wrong-password")
                        return
                    }
                    return showSendingError(e.message)
                }

                sendDialog.close()
                sendDialog.destroy()
            }

            sendDialog.open();
            WalletStore.getGasPrice()
        } else if (requestType === Constants.web3SendAsyncReadOnly && ["eth_sign", "personal_sign", "eth_signTypedData", "eth_signTypedData_v3"].indexOf(request.payload.method) > -1) {
            const signDialog = createSignMessageModalComponent(request)
            signDialog.web3Response = web3Response
            signDialog.signMessage = function (enteredPassword) {
                signDialog.interactedWith = true;
                request.payload.password = enteredPassword;
                switch(request.payload.method){
                    case Constants.personal_sign:
                        request.payload.params[0] = signValue(request.payload.params[0]);
                    case Constants.eth_sign:
                        request.payload.params[1] = signValue(request.payload.params[1]);
                }
                const response = Web3ProviderStore.web3ProviderInst.postMessage(requestType, JSON.stringify(request));
                provider.web3Response(response);
                try {
                    let responseObj = JSON.parse(response)
                    if (responseObj.error) {
                        throw new Error(responseObj.error.message)
                    }
                } catch (e) {
                    if (Utils.isInvalidPasswordMessage(e.message)){
                        //% "Wrong password"
                        signDialog.transactionSigner.validationError = qsTrId("wrong-password")
                        return
                    }
                    return showSigningError(e.message)
                }
                signDialog.close()
                signDialog.destroy()
            }


            signDialog.open();
        } else if (request.type === Constants.web3DisconnectAccount) {
            web3Response(data);
        } else {
            web3Response(Web3ProviderStore.web3ProviderInst.postMessage(requestType, data));
        }
    }

    WebChannel.id: "backend"
}
