.import StatusQ.Core.Utils 0.1 as SQUtils

function chainIdFromEip155(chain) {
    return parseInt(chain.split(':').pop().trim(), 10)
}

function isHex(str) {
    return str.startsWith('0x') && str.length % 2 === 0 && /^[0-9a-fA-F]*$/.test(str.slice(2))
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

function extractMethodsFromProposal(proposal) {
    const optionalMethods = (((((proposal || {}).params) || {}).optionalNamespaces || {}).eip155 || {}).methods || []
    const requiredMethods = (((((proposal || {}).params) || {}).requiredNamespaces || {}).eip155 || {}).methods || []
    let methods = [...optionalMethods, ...requiredMethods]
    return methods
}

function extractChainsFromProposal(proposal) {
    const optionalChains = (((((proposal || {}).params) || {}).optionalNamespaces || {}).eip155 || {}).chains || []
    const requiredChains = (((((proposal || {}).params) || {}).requiredNamespaces || {}).eip155 || {}).chains || []
    let chains = [...optionalChains, ...requiredChains].map(chainIdFromEip155)
    return chains
}

function extractChainsFromAuthenticationProposal(proposal) {
    return ((((proposal || {}).params || {}).authPayload || {}).chains || []).map(chainIdFromEip155)
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
    let eipChainIds = []
    let eipAddresses = []
    for (let i = 0; i < chainIds.length; i++) {
        let chainId = chainIds[i]
        eipChainIds.push(`"eip155:${chainId}"`)
        for (let i = 0; i < addresses.length; i++) {
            eipAddresses.push(`"eip155:${chainId}:${addresses[i]}"`)
        }
    }
    let methodsStr = methods.map(method => `"${method}"`).join(',')
    return `{
        "eip155":{
            "chains": [${eipChainIds.join(',')}],
            "methods": [${methodsStr}],
            "events": ["chainChanged","accountsChanged","message","disconnect","connect"],
            "accounts": [${eipAddresses.join(',')}]
        }
    }`
}

function validURI(uri) {
    const regex = /^wc:[0-9a-fA-F-]*@([1-9][0-9]*)(\?([a-zA-Z-]+=[^&]+)(&[a-zA-Z-]+=[^&]+)*)?$/
    return regex.test(uri)
}

function extractInfoFromPairUri(uri) {
    let topic = ""
    let expiry = NaN
    // Extract topic and expiry from wc:99fdcac5cc081ac8c1181b4c38c5dc49fb5eb212706d5c94c445be549765e7f0@2?expiryTimestamp=1720090818&relay-protocol=irn&symKey=c6b67d94174bd42d16ff288220ce9b8966e5b56a2d3570a30d5b0a760f1953f0
    const regex = /wc:([0-9a-fA-F]*)/
    const match = uri.match(regex)
    if (match) {
        topic = match[1]
    }

    let parts = uri.split('?')
    if (parts.length > 1) {
        const params = parts[1].split('&')
        for (let i = 0; i < params.length; i++) {
            const keyVal = params[i].split('=')
            if (keyVal[0] === 'expiryTimestamp') {
                expiry = parseInt(keyVal[1])
            }
        }
    }
    return { topic, expiry }
}

function filterActiveSessionsForKnownAccounts(sessions, accountsModel) {
    let knownSessions = ({})
    Object.keys(sessions).forEach((topic) => {
        const session = sessions[topic]
        const eip155Addresses = session.namespaces.eip155.accounts
        const accountSet = new Set(
            eip155Addresses.map(eip155Address => eip155Address.split(':').pop().trim())
        );
        const uniqueAddresses = Array.from(accountSet);
        const firstAccount = SQUtils.ModelUtils.getFirstModelEntryIf(accountsModel, (account) => {
            return uniqueAddresses.includes(account.address)
        })
        if (!firstAccount) {
            return
        }
        knownSessions[topic] = session
    })
    return knownSessions
}

function getAccountsInSession(session) {
    const eip155Addresses = session.namespaces.eip155.accounts
    const accountSet = new Set(
        eip155Addresses.map(eip155Address => eip155Address.split(':').pop().trim())
    );
    const uniqueAddresses = Array.from(accountSet);
    return uniqueAddresses
}
