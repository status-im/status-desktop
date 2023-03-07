import QtQuick 2.15


QtObject {
    id: root

    property var mintingModuleInst: mintingModule ?? null

    // Minting tokens:
    function mintCollectible(communityId, address, artworkSource, name, symbol, description, supply,
                             infiniteSupply, transferable, selfDestruct, chainId)
    {
        // TODO: Backend needs to add `artworkSource` param
        mintingModuleInst.mintCollectible(communityId, address, name, symbol, description, supply,
                                          infiniteSupply, transferable, selfDestruct, chainId)
    }

    // Network selection properties:
    property var layer1Networks: networksModule.layer1
    property var layer2Networks: networksModule.layer2
    property var testNetworks: networksModule.test
    property var enabledNetworks: networksModule.enabled
    property var allNetworks: networksModule.all
}
