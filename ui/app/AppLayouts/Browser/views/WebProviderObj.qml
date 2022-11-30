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
    property int chainId: (Web3ProviderStore && Web3ProviderStore.chainId) || 1

    signal web3Response(string data);

    function signValue(input){
        if(Utils.isHex(input) && Utils.startsWith0x(input)){
            return input
        }
        return RootStore.getAscii2Hex(input)
    }

    property Connections conn: Connections {
        target: Web3ProviderStore.web3ProviderInst

        onPostMessageResult: {
            web3Response(result)
            const isSign = ["eth_sign", "personal_sign", "eth_signTypedData", "eth_signTypedData_v3"].indexOf(payloadMethod) > -1
            const isTx = payloadMethod === "eth_sendTransaction"
            try {
                let responseObj = JSON.parse(result)
                if (responseObj.error) {
                   throw new Error(responseObj.error)
                }

                if (isTx) {
                    showToastMessage(responseObj.result.result)
                }
                
            } catch (e) {
                if (isTx) {
                    showSendingError(e.message)
                } else if (isSign) {
                    showSigningError(e.message.message)
                }
            }
        }
    }


    function postMessage(requestType, data) {
        var request;
        try {
            request = JSON.parse(data)
        } catch (e) {
            console.error("Error parsing the message data", e)
            return;
        }
        request.address = WalletStore.dappBrowserAccount.address
        if (!request.payload) {
            request.payload = {}
        }
        request.payload.chainId = provider.chainId

        var ensAddr = Web3ProviderStore.urlENSDictionary[request.hostname];
        if (ensAddr) {
            request.hostname = ensAddr;
        }

        if (requestType === Constants.web3DisconnectAccount) {
            RootStore.currentTabConnected = false
            web3Response(JSON.stringify({type: Constants.web3DisconnectAccount}));
        } else if (requestType === Constants.api_request) {
            if (!Web3ProviderStore.hasPermission(request.hostname, request.address, request.permission)) {
                RootStore.currentTabConnected = false
                var dialog = createAccessDialogComponent()
                dialog.request = request;
                dialog.open();
            } else {
                RootStore.currentTabConnected = true
                Web3ProviderStore.web3ProviderInst.postMessage("", requestType, JSON.stringify(request));
            }
        } else if (requestType === Constants.web3SendAsyncReadOnly &&
                   request.payload.method === "eth_sendTransaction") {
            var acc = WalletStore.dappBrowserAccount
            const value = RootStore.getWei2Eth(request.payload.params[0].value, 18);
            const sendDialog = createSendTransactionModalComponent(request, requestType)

            sendDialog.sendTransaction = function () {
                if(sendDialog.bestRoutes.length === 1) {
                    let path = sendDialog.bestRoutes[0]
                    let eip1559Enabled = path.gasFees.eip1559Enabled
                    let maxFeePerGas = path.gasFees.maxFeePerGasM
                    let trx = request.payload.params[0]
                    // TODO: use bignumber instead of floats
                    trx.value = RootStore.getEth2Hex(parseFloat(value))
                    trx.gas = "0x" + parseInt(path.gasAmount, 10).toString(16)
                    trx.maxPriorityFeePerGas = RootStore.getGwei2Hex(parseFloat(eip1559Enabled ? path.gasFees.maxPriorityFeePerGas : "0"))
                    trx.maxFeePerGas = RootStore.getGwei2Hex(parseFloat(eip1559Enabled ? maxFeePerGas : path.gasFees.gasPrice))

                    request.payload.params[0] = trx

                    Web3ProviderStore.web3ProviderInst.authenticateToPostMessage(request.payload.method, requestType, JSON.stringify(request))
                    sendDialog.close()
                }
            }

            sendDialog.open();
        } else if (requestType === Constants.web3SendAsyncReadOnly && ["eth_sign", "personal_sign", "eth_signTypedData", "eth_signTypedData_v3"].indexOf(request.payload.method) > -1) {
            const signDialog = createSignMessageModalComponent(request)
            signDialog.web3Response = web3Response
            signDialog.signMessage = function (enteredPassword) {
                signDialog.interactedWith = true;
                request.payload.password = enteredPassword;
                request.payload.from = WalletStore.dappBrowserAccount.address;
                switch(request.payload.method){
                    case Constants.personal_sign:
                        request.payload.params[0] = signValue(request.payload.params[0]);
                    case Constants.eth_sign:
                        request.payload.params[1] = signValue(request.payload.params[1]);
                }
                Web3ProviderStore.web3ProviderInst.postMessage(request.payload.method, requestType, JSON.stringify(request));
                signDialog.close()
                signDialog.destroy()
            }


            signDialog.open();
        } else if (request.type === Constants.web3DisconnectAccount) {
            web3Response(data);
        } else {
            Web3ProviderStore.web3ProviderInst.postMessage(request.payload.method, requestType, JSON.stringify(request));
        }
    }

    WebChannel.id: "backend"
}
