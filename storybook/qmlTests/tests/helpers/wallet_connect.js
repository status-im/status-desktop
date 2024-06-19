
const requiredEventsJsonString = `["chainChanged", "accountsChanged"]`
const requiredMethodsJsonString = `["eth_sendTransaction","personal_sign"]`
const optionalNamespacesJsonString = `{
    "eip155": {
        "chains": [
            "eip155:1",
            "eip155:10"
        ],
        "events": [
            "chainChanged",
            "accountsChanged",
            "message",
            "disconnect",
            "connect"
        ],
        "methods": [
            "eth_sign",
            "eth_signTransaction",
            "eth_signTypedData",
            "eth_signTypedData_v3",
            "eth_signTypedData_v4",
            "eth_sendTransaction"
        ],
        "rpcMap": {
            "1": "https://cloudflare-eth.com",
            "10": "https://mainnet.optimism.io/"
        }
    }
}`

const requiredNamespacesJsonString = `{
    "eip155": {
        "chains": [
            "eip155:1"
        ],
        "events": ${requiredEventsJsonString},
        "methods": ${requiredMethodsJsonString},
        "rpcMap": {
            "1": "https://mainnet.io/123"
        }
    }
}`

const dappName = 'Test dApp'
const dappUrl = 'https://app.test.org'
const dappFirstIcon = 'https://test.com/icon.png'
const dappMetadataJsonString = `{
    "description": "Test dApp description",
    "icons": [
        "${dappFirstIcon}"
    ],
    "name": "${dappName}",
    "url": "${dappUrl}"
}`

// https://metamask.github.io/test-dapp/ use case that doesn't have icons
const noIconsDappMetadataJsonString = `{
    "description": "This is the E2e Test Dapp",
    "name": "${dappName}",
    "url": "${dappUrl}"
}`

const verifiedContextJsonString = `{
    "verified": {
        "origin": "https://app.test.org",
        "validation": "UNKNOWN",
        "verifyUrl": "https://verify.walletconnect.com"
    }
}`

function formatSessionProposal(custom) {
    var dappMetadataJsonStringOverride = dappMetadataJsonString
    if (custom && custom.dappMetadataJsonString) {
        dappMetadataJsonStringOverride = custom.dappMetadataJsonString
    }

    return `{
    "id": 1715976881734096,
    "params": {
        "expiryTimestamp": 1715977219,
        "id": 1715976881734096,
        "optionalNamespaces": ${optionalNamespacesJsonString},
        "pairingTopic": "50fba141cdb5c015493c2907c46bacf9f7cbd7c8e3d4e97df891f18dddcff69c",
        "proposer": {
            "metadata": ${dappMetadataJsonStringOverride},
            "publicKey": "095d9992ca0eb6081cabed26faf48919162fd70cc66d639f118a60507ae0463d"
        },
        "relays": [
            {
                "protocol": "irn"
            }
        ],
        "requiredNamespaces": ${requiredNamespacesJsonString}
    },
    "verifyContext": ${verifiedContextJsonString}
  }`
}

function formatBuildApprovedNamespacesResult(networksArray, accountsArray) {
    let requiredChainsStr = networksArray.map(chainId => `"eip155:${chainId}"`).join(',')
    let requiredAccountsStr = accountsArray.map(address => networksArray.map(chainId => `"eip155:${chainId}:${address}"`).join(',')).join(',')
    return `{
    "eip155": {
      "chains": [${requiredChainsStr}],
      "accounts": [${requiredAccountsStr}],
      "events": ${requiredEventsJsonString},
      "methods": ${requiredMethodsJsonString}
    }
  }`
}

function formatApproveSessionResponse(networksArray, accountsArray, custom) {
    var dappMetadataJsonStringOverride = dappMetadataJsonString
    if (custom && custom.dappMetadataJsonString) {
        dappMetadataJsonStringOverride = custom.dappMetadataJsonString
    }
    let chainsStr = networksArray.map(chainId => `"eip155:${chainId}"`).join(',')
    let accountsStr = accountsArray.map(address => networksArray.map(chainId => `"eip155:${chainId}:${address}"`).join(',')).join(',')
    return `{
        "acknowledged": true,
        "controller": "da4a87d5f0f54951afe870ebf020cf03f8a3522fbd219398c3fa159a37e16d54",
        "expiry": 1716581732,
        "namespaces": {
            "eip155": {
                "accounts": [${accountsStr}],
                "chains": [${chainsStr}],
                "events": ${requiredEventsJsonString},
                "methods": ${requiredMethodsJsonString}
            }
        },
        "optionalNamespaces": ${optionalNamespacesJsonString},
        "pairingTopic": "50fba141cdb5c015493c2907c46bacf9f7cbd7c8e3d4e97df891f18dddcff69c",
        "peer": {
            "metadata": ${dappMetadataJsonStringOverride},
            "publicKey": "095d9992ca0eb6081cabed26faf48919162fd70cc66d639f118a60507ae0463d"
        },
        "relay": {
            "protocol": "irn"
        },
        "requiredNamespaces": ${requiredNamespacesJsonString},
        "self": {
            "metadata": {
                "description": "Status Wallet",
                "icons": [
                    "https://status.im/img/status-footer-logo.svg"
                ],
                "name": "Status",
                "url": "http://localhost"
            },
            "publicKey": "da4a87d5f0f54951afe870ebf020cf03f8a3522fbd219398c3fa159a37e16d54"
        },
        "topic": "e39e1f435a46b5ee6b31484d1751cfbc35be1275653af2ea340974a7592f1a19"
    }`
}

function formatSessionRequest(chainId, method, params, topic) {
    let paramsStr = params.map(param => `"${param}"`).join(',')
    return `{
    "id": 1717149885151715,
    "params": {
        "chainId": "eip155:${chainId}",
        "request": {
            "expiryTimestamp": 1717150185,
            "method": "${method}",
            "params": [${paramsStr}]
        }
    },
    "topic": "${topic}",
    "verifyContext": ${verifiedContextJsonString}
  }`
}