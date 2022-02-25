pragma Singleton

import QtQuick 2.13

QtObject {
    readonly property QtObject appState: QtObject {
        readonly property int onboarding: 0
        readonly property int login: 1
        readonly property int main: 2
    }

    readonly property QtObject appSection: QtObject {
        readonly property int chat: 0
        readonly property int community: 1
        readonly property int wallet: 2
        readonly property int browser: 3
        readonly property int profile: 4
        readonly property int node: 5
    }

    readonly property QtObject appViewStackIndex: QtObject {
        readonly property int chat: 0
        readonly property int community: 7 // any stack layout children with the index 7 or higher is community
        readonly property int wallet: 1
        readonly property int browser: 2
        readonly property int profile: 3
        readonly property int node: 4
    }

    readonly property QtObject settingsSubsection: QtObject {
        property int profile: 0
        property int contacts: 1
        property int ensUsernames: 2
        property int wallet: 3
        property int privacyAndSecurity: 4
        property int appearance: 5
        property int sound: 6
        property int language: 7
        property int notifications: 8
        property int syncSettings: 9
        property int devicesSettings: 10
        property int browserSettings: 11
        property int advanced: 12
        property int needHelp: 13
        property int about: 14
        property int signout: 15
    }

    readonly property QtObject userStatus: QtObject{
        readonly property int offline: 0
        readonly property int online: 1
        readonly property int doNotDisturb: 2
        readonly property int idle: 3
    }

    readonly property QtObject chatType: QtObject{
        readonly property int unknown: 0
        readonly property int oneToOne: 1
        readonly property int publicChat: 2
        readonly property int privateGroupChat: 3
        readonly property int profile: 4
        readonly property int communityChat: 6
    }

    readonly property QtObject messageContentType: QtObject {
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
        readonly property int gapType: 10
        readonly property int editType: 11
    }

    readonly property int communityImported: 0
    readonly property int communityImportingInProgress: 1
    readonly property int communityImportingError: 2

    readonly property int communityChatPublicAccess: 1
    readonly property int communityChatInvitationOnlyAccess: 2
    readonly property int communityChatOnRequestAccess: 3


    readonly property int activityCenterNotificationTypeOneToOne: 1
    readonly property int activityCenterNotificationTypeGroupRequest: 2
    readonly property int activityCenterNotificationTypeMention: 3
    readonly property int activityCenterNotificationTypeReply: 4

    readonly property int maxNbDaysToFetch: 30
    readonly property int fetchRangeLast24Hours: 86400
    readonly property int fetchRangeLast2Days: 172800
    readonly property int fetchRangeLast3Days: 259200
    readonly property int fetchRangeLast7Days: 604800

    readonly property int walletFetchRecentHistoryInterval: 1200000 // 20 mins

    readonly property int limitLongChatText: 500
    readonly property int limitLongChatTextCompactMode: 1000

    readonly property int notificationPopupTTL: 5000

    readonly property string lightThemeName: "light"
    readonly property string darkThemeName: "dark"

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

    readonly property string watchWalletType: "watch"
    readonly property string keyWalletType: "key"
    readonly property string seedWalletType: "seed"
    readonly property string generatedWalletType: "generated"

    readonly property string windows: "windows"
    readonly property string linux: "linux"
    readonly property string mac: "mac"

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
    readonly property string waku_prod: "wakuv2.prod"
    readonly property string waku_test: "wakuv2.test"
    readonly property string status_test: "status.test"

    readonly property int browserSearchEngineNone: 0
    readonly property int browserSearchEngineGoogle: 1
    readonly property int browserSearchEngineYahoo: 2
    readonly property int browserSearchEngineDuckDuckGo: 3

    readonly property int browserEthereumExplorerNone: 0
    readonly property int browserEthereumExplorerEtherscan: 1
    readonly property int browserEthereumExplorerEthplorer: 2
    readonly property int browserEthereumExplorerBlockchair: 3

    readonly property int repeatHeaderInterval: 2

    readonly property string deepLinkPrefix: 'statusim://'
    readonly property string joinStatusLink: 'join.status.im'
    readonly property string communityLinkPrefix: 'https://join.status.im/c/'
    readonly property string userLinkPrefix: 'https://join.status.im/u/'
    readonly property string statusLinkPrefix: 'https://status.im/'

    readonly property int maxUploadFiles: 5
    readonly property double maxUploadFilesizeMB: 10

    readonly property int maxNumberOfPins: 3

    readonly property var acceptedImageExtensions: [".png", ".jpg", ".jpeg", ".svg", ".gif"]
    readonly property var acceptedDragNDropImageExtensions: [".png", ".jpg", ".jpeg", ".heif", "tif", ".tiff"]

    readonly property string mentionSpanTag: `<span style="color:${Style.current.mentionColor}; background-color: ${Style.current.mentionBgColor};"><a style="text-decoration:none" href='http://'>`

    readonly property string ens_taken: "taken"
    readonly property string ens_taken_custom: "taken-custom"
    readonly property string ens_owned: "owned"
    readonly property string ens_available: "available"
    readonly property string ens_already_connected: "already-connected"
    readonly property string ens_connected: "connected"
    readonly property string ens_connected_dkey: "connected-different-key"

    readonly property string storeToKeychainValueStore: "store"
    readonly property string storeToKeychainValueNotNow: "notNow"
    readonly property string storeToKeychainValueNever: "never"

    //% "(edited)"
    readonly property string editLabel: ` <span class="isEdited">` + qsTrId("-edited-") + `</span>`

    readonly property string newBookmark: " "

    readonly property var ensState: {
        //% "Username already taken :("
        "taken": qsTrId("ens-username-taken"),
        //% "Username doesn’t belong to you :("
        "taken-custom": qsTrId("ens-custom-username-taken"),
        //% "Continuing will connect this username with your chat key."
        "owned": qsTrId("ens-username-owned-continue"),
        //% "✓ Username available!"
        "available": qsTrId("ens-username-available"),
        //% "Username is already connected with your chat key and can be used inside Status."
        "already-connected": qsTrId("ens-username-already-added"),
        //% "This user name is owned by you and connected with your chat key. Continue to set `Show my ENS username in chats`."
        "connected": qsTrId("this-user-name-is-owned-by-you-and-connected-with-your-chat-key--continue-to-set--show-my-ens-username-in-chats--"),
        //% "Continuing will require a transaction to connect the username with your current chat key."
        "connected-different-key": qsTrId("ens-username-connected-with-different-key"),
    }

    readonly property bool isCppApp: cppApp ? cppApp : false
}
