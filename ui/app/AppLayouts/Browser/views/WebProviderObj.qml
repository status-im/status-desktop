import QtQuick 2.13
import QtWebChannel 1.13

import utils 1.0

import "../stores"

QtObject {
    id: provider
    WebChannel.id: "backend"

    signal web3Response(string data);

    function signValue(input){
        if(Utils.isHex(input) && Utils.startsWith0x(input)){
            return input
        }
        return RootStore.getAscii2Hex(input)
    }

    function postMessage(data) {
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

        if (request.type === Constants.api_request) {
            if (!Web3ProviderStore.web3ProviderInst.hasPermission(request.hostname, request.permission)) {
                browserWindow.currentTabConnected = false
                var dialog = accessDialogComponent.createObject(browserWindow);
                dialog.request = request;
                dialog.open();
            } else {
                browserWindow.currentTabConnected = true
                request.isAllowed = true;
                web3Response(Web3ProviderStore.web3ProviderInst.postMessage(JSON.stringify(request)));
            }
        } else if (request.type === Constants.web3SendAsyncReadOnly &&
                   request.payload.method === "eth_sendTransaction") {
            var acc = WalletStore.dappBrowserAccount
            const value = RootStore.getWei2Eth(request.payload.params[0].value, 18);
            const sendDialog = sendTransactionModalComponent.createObject(browserWindow, {
                trxData: request.payload.params[0].data || "",
                selectedAccount: {
                    name: acc.name,
                    address: request.payload.params[0].from,
                    iconColor: acc.iconColor,
                    assets: acc.assets
                },
                selectedRecipient: {
                    address: request.payload.params[0].to,
                    identicon: RootStore.generateIdenticon(request.payload.params[0].to),
                    name: RootStore.activeChannelName,
                    type: RecipientSelector.Type.Address
                },
                selectedAsset: {
                    name: "ETH",
                    symbol: "ETH",
                    address: Constants.zeroAddress
                },
                selectedFiatAmount: "42", // TODO calculate that
                selectedAmount: value
            });

            // TODO change sendTransaction function to the postMessage one
            sendDialog.sendTransaction = function (selectedGasLimit, selectedGasPrice, selectedTipLimit, selectedOverallLimit, enteredPassword) {
                request.payload.selectedGasLimit = selectedGasLimit
                request.payload.selectedGasPrice = selectedGasPrice
                request.payload.selectedTipLimit = selectedTipLimit
                request.payload.selectedOverallLimit = selectedOverallLimit
                request.payload.password = enteredPassword
                request.payload.params[0].value = value

                const response = Web3ProviderStore.web3ProviderInst.postMessage(JSON.stringify(request))
                provider.web3Response(response)

                let responseObj
                try {
                    responseObj = JSON.parse(response)

                    if (responseObj.error) {
                        throw new Error(responseObj.error)
                    }

                    //% "Transaction pending..."
                    toastMessage.title = qsTrId("ens-transaction-pending")
                    toastMessage.source = Style.svg("loading")
                    toastMessage.iconColor = Style.current.primary
                    toastMessage.iconRotates = true
                    toastMessage.link = `${_WalletStore.etherscanLink}/${responseObj.result.result}`
                    toastMessage.open()
                } catch (e) {
                    if (Utils.isInvalidPasswordMessage(e.message)){
                        //% "Wrong password"
                        sendDialog.transactionSigner.validationError = qsTrId("wrong-password")
                        return
                    }
                    sendingError.text = e.message
                    return sendingError.open()
                }

                sendDialog.close()
                sendDialog.destroy()
            }

            sendDialog.open();
            WalletStore.getGasPrice()
        } else if (request.type === Constants.web3SendAsyncReadOnly && ["eth_sign", "personal_sign", "eth_signTypedData", "eth_signTypedData_v3"].indexOf(request.payload.method) > -1) {
            const signDialog = signMessageModalComponent.createObject(browserWindow, {
                    request,
                    selectedAccount: {
                        name: WalletStore.dappBrowserAccount.name,
                        iconColor: WalletStore.dappBrowserAccount.iconColor
                    }
                });
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
                const response = Web3ProviderStore.web3ProviderInst.postMessage(JSON.stringify(request));
                provider.web3Response(response);
                try {
                    let responseObj = JSON.parse(response)
                    if (responseObj.error) {
                        throw new Error(responseObj.error)
                    }
                } catch (e) {
                    if (Utils.isInvalidPasswordMessage(e.message)){
                        //% "Wrong password"
                        signDialog.transactionSigner.validationError = qsTrId("wrong-password")
                        return
                    }
                    signingError.text = e.message
                    return signingError.open()
                }
                signDialog.close()
                signDialog.destroy()
            }


            signDialog.open();
        } else if (request.type === Constants.web3DisconnectAccount) {
            web3Response(data);
        } else {
            web3Response(Web3ProviderStore.web3ProviderInst.postMessage(data));
        }
    }
}
