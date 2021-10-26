pragma Singleton

import QtQuick 2.13

QtObject {
    id: root

    property var web3ProviderInst: providerModule
    property var urlENSDictionary: ({})

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
