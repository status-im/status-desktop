.import StatusQ.Core.Utils 0.1 as SQUtils

function extractChainsAndAccountsFromApprovedNamespaces(approvedNamespaces) {
    const eip155Data = approvedNamespaces.eip155;
    const chains = eip155Data.chains.map(chain => parseInt(chain.split(':').pop().trim(), 10));
    const accountSet = new Set(
        eip155Data.accounts.map(account => account.split(':').pop().trim())
    );
    const uniqueAccounts = Array.from(accountSet);
    return { chains, accounts: uniqueAccounts };
}

function buildSupportedNamespacesFromModels(chainsModel, accountsModel) {
    var chainIds = []
    var addresses = []
    for (let i = 0; i < chainsModel.count; i++) {
        let entry = SQUtils.ModelUtils.get(chainsModel, i)
        chainIds.push(parseInt(entry.chainId))
    }
    for (let i = 0; i < accountsModel.count; i++) {
        let entry = SQUtils.ModelUtils.get(accountsModel, i)
        addresses.push(entry.address)
    }
    return buildSupportedNamespaces(chainIds, addresses)
}

function buildSupportedNamespaces(chainIds, addresses) {
    var eipChainIds = []
    var eipAddresses = []
    for (let i = 0; i < chainIds.length; i++) {
        let chainId = chainIds[i]
        eipChainIds.push(`"eip155:${chainId}"`)
        for (let i = 0; i < addresses.length; i++) {
            eipAddresses.push(`"eip155:${chainId}:${addresses[i]}"`)
        }
    }
    return `{
        "eip155":{"chains": [${eipChainIds.join(',')}],"methods": ["eth_sendTransaction", "personal_sign"],"events": ["accountsChanged", "chainChanged"],"accounts": [${eipAddresses.join(',')}]}}`
}