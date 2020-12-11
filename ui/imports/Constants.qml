pragma Singleton

import QtQuick 2.13

QtObject {
    readonly property int chatTypeOneToOne: 1
    readonly property int chatTypePublic: 2
    readonly property int chatTypePrivateGroupChat: 3
    readonly property int chatTypeStatusUpdate: 4
    readonly property int chatTypeCommunity: 6

    readonly property int communityChatPublicAccess: 1
    readonly property int communityChatInvitationOnlyAccess: 2
    readonly property int communityChatOnRequestAccess: 3

    readonly property int fetchRangeLast24Hours: 86400
    readonly property int fetchRangeLast2Days: 172800
    readonly property int fetchRangeLast3Days: 259200
    readonly property int fetchRangeLast7Days: 604800

    readonly property int limitLongChatText: 500
    readonly property int limitLongChatTextCompactMode: 1000

    readonly property int notificationPopupTTL: 5000

    readonly property string chat: "chat"
    readonly property string wallet: "wallet"
    readonly property string browser: "browser"
    readonly property string profile: "profile"
    readonly property string node: "node"
    readonly property string ui: "ui"

    readonly property int fontSizeXS: 0
    readonly property int fontSizeS: 1
    readonly property int fontSizeM: 2
    readonly property int fontSizeL: 3
    readonly property int fontSizeXL: 4
    readonly property int fontSizeXXL: 5

    readonly property int notifyAllMessages: 0
    readonly property int notifyJustMentions: 1
    readonly property int notifyNone: 2
    readonly property int notificationPreviewAnonymous: 0
    readonly property int notificationPreviewNameOnly: 1
    readonly property int notificationPreviewNameAndMessage: 2
    readonly property int fetchMoreMessagesButton: -2
    readonly property int chatIdentifier: -1
    readonly property int unknownContentType: 0
    readonly property int messageType: 1
    readonly property int stickerType: 2
    readonly property int statusType: 3
    readonly property int emojiType: 4
    readonly property int transactionType: 5
    readonly property int systemMessagePrivateGroupType: 6
    readonly property int imageType: 7
    readonly property int audioType: 8
    readonly property int communityInviteType: 9

    readonly property string watchWalletType: "watch"
    readonly property string keyWalletType: "key"
    readonly property string seedWalletType: "seed"
    readonly property string generatedWalletType: "generated"

    // Transaction states
    readonly property int addressRequested: 1
    readonly property int declined: 2
    readonly property int addressReceived: 3
    readonly property int transactionRequested: 4
    readonly property int transactionDeclined: 5
    readonly property int pending: 6
    readonly property int confirmed: 7

    readonly property int maxTokens: 200

    readonly property string zeroAddress: "0x0000000000000000000000000000000000000000"

    readonly property var accountColors: [
        "#9B832F",
        "#D37EF4",
        "#1D806F",
        "#FA6565",
        "#7CDA00",
        "#887af9",
        "#8B3131"
    ]

    readonly property string networkMainnet: "mainnet_rpc"
    readonly property string networkPOA: "poa_rpc"
    readonly property string networkXDai: "xdai_rpc"
    readonly property string networkGoerli: "goerli_rpc"
    readonly property string networkRinkeby: "rinkeby_rpc"
    readonly property string networkRopsten: "testnet_rpc"

    readonly property string api_request: "api-request"
    readonly property string web3SendAsyncReadOnly: "web3-send-async-read-only"
    readonly property string web3DisconnectAccount: "web3-disconnect-account"

    readonly property string permission_web3: "web3"
    readonly property string permission_contactCode: "contact-code"

    readonly property string personal_sign: "personal_sign"
    readonly property string eth_sign: "eth_sign"
    readonly property string eth_signTypedData: "eth_signTypedData"
    readonly property string eth_signTypedData_v3: "eth_signTypedData_v3"

    readonly property string eth_prod: "eth.prod"
    readonly property string eth_staging: "eth.staging"
    readonly property string eth_test: "eth.test"

    readonly property int browserSearchEngineNone: 0
    readonly property int browserSearchEngineGoogle: 1
    readonly property int browserSearchEngineYahoo: 2
    readonly property int browserSearchEngineDuckDuckGo: 3

    readonly property int browserEthereumExplorerNone: 0
    readonly property int browserEthereumExplorerEtherscan: 1
    readonly property int browserEthereumExplorerEthplorer: 2
    readonly property int browserEthereumExplorerBlockchair: 3
}
