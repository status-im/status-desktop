pragma Singleton

import QtQuick 2.13

QtObject {
    id: root

    property var web3ProviderInst: web3Provider
    property var urlENSDictionary: ({})

    function determineRealURL(text){
        var url = RootStore.getUrlFromUserInput(text);
        var host = web3Provider.getHost(url);
        if(host.endsWith(".eth")){
            var ensResource = web3Provider.ensResourceURL(host, url);

            if(/^https\:\/\/swarm\-gateways\.net\/bzz:\/([0-9a-fA-F]{64}|.+\.eth)(\/?)/.test(ensResource)){
                // TODO: populate urlENSDictionary for prettier url instead of swarm-gateway big URL
                return ensResource;
            } else {
                urlENSDictionary[web3Provider.getHost(ensResource)] = host;
            }
            url = ensResource;
        }
        return url;
    }

    function obtainAddress(url) {
        var ensAddr = urlENSDictionary[web3Provider.getHost(url)];
        return ensAddr ? web3Provider.replaceHostByENS( url, ensAddr) : url;
    }
}
