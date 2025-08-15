import QtQuick

import StatusQ

import utils

QtObject {
    id: root

    required property string dappBrowserAccountAddress

    property var web3ProviderInst: providerModule
    property var urlENSDictionary: ({})

    property int chainId: providerModule.chainId
    property string chainName: providerModule.chainName

    function disconnectAddress(dappName, address){
        dappPermissionsModule.disconnectAddress(dappName, address)
    }

    function disconnect(hostname) {
        dappPermissionsModule.disconnect(hostname)
    }

    function addPermission(hostname, address, permission){
        dappPermissionsModule.addPermission(hostname, address, permission)
    }

    function hasPermission(hostname, address, permission){
        return dappPermissionsModule.hasPermission(hostname, address, permission)
    }

    function hasWalletConnected(hostname) {
        return hasPermission(hostname, root.dappBrowserAccountAddress, "web3")
    }

    function determineRealURL(text) {
        const url = UrlUtils.urlFromUserInput(text)
        const host = providerModule.getHost(url);
        if (host.endsWith(".eth")){
            var ensResource = providerModule.ensResourceURL(host, url);

            if(/^https\:\/\/swarm\-gateways\.net\/bzz:\/([0-9a-fA-F]{64}|.+\.eth)(\/?)/.test(ensResource)){
                // TODO: populate urlENSDictionary for prettier url instead of swarm-gateway big URL
                return ensResource;
            } else {
                urlENSDictionary[providerModule.getHost(ensResource)] = host;
            }
            url = ensResource;
        }
        return url;
    }

    function obtainAddress(url) {
        var ensAddr = urlENSDictionary[providerModule.getHost(url)];
        return ensAddr ? providerModule.replaceHostByENS(url, ensAddr) : url;
    }
}
