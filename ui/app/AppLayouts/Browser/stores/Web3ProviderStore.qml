pragma Singleton

import QtQuick 2.13

QtObject {
    id: root

    property var web3ProviderInst: providerModule
    property var urlENSDictionary: ({})

    property int networkId: providerModule.networkId

    function disconnectAddress(dappName, address){
        dappPermissionsModule.disconnectAddress(address)
    }

    function addPermission(hostname, address, permission){
        dappPermissionsModule.addPermission(hostname, address, permission)
    }

    function hasPermission(hostname, address, permission){
        return dappPermissionsModule.hasPermission(hostname, address, permission)
    }

    function determineRealURL(text){
        var url = RootStore.getUrlFromUserInput(text);
        var host = providerModule.getHost(url);
        if(host.endsWith(".eth")){
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
        return ensAddr ? providerModule.replaceHostByENS( url, ensAddr) : url;
    }
}
