.import StatusQ.Core.Utils 0.1 as SQUtils

function chainIdFromEip155(chain) {
    return parseInt(chain.split(':').pop().trim(), 10)
}

function hexToString(hex) {
    if (hex.startsWith("0x")) {
        hex = hex.substring(2);
    }

    var str = '';
    for (var i = 0; i < hex.length; i += 2) {
        str += String.fromCharCode(parseInt(hex.substr(i, 2), 16));
    }
    return str;
}

function strToHex(str) {
    var hex = '';
    for (var i = 0; i < str.length; i++) {
        var byte = str.charCodeAt(i).toString(16);
        hex += (byte.length < 2 ? '0' : '') + byte;
    }
    return '0x' + hex;
}

function extractChainsAndAccountsFromApprovedNamespaces(approvedNamespaces) {
    const eip155Data = approvedNamespaces.eip155;
    const chains = eip155Data.chains.map(chainIdFromEip155);
    const accountSet = new Set(
        eip155Data.accounts.map(account => account.split(':').pop().trim())
    );
    const uniqueAccounts = Array.from(accountSet);
    return { chains, accounts: uniqueAccounts };
}

function buildSupportedNamespacesFromModels(chainsModel, accountsModel, methods) {
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
    return buildSupportedNamespaces(chainIds, addresses, methods)
}

function buildSupportedNamespaces(chainIds, addresses, methods) {
    var eipChainIds = []
    var eipAddresses = []
    for (let i = 0; i < chainIds.length; i++) {
        let chainId = chainIds[i]
        eipChainIds.push(`"eip155:${chainId}"`)
        for (let i = 0; i < addresses.length; i++) {
            eipAddresses.push(`"eip155:${chainId}:${addresses[i]}"`)
        }
    }
    let methodsStr = methods.map(method => `"${method}"`).join(',')
    return `{
        "eip155":{"chains": [${eipChainIds.join(',')}],"methods": [${methodsStr}],"events": ["accountsChanged", "chainChanged"],"accounts": [${eipAddresses.join(',')}]}}`
}