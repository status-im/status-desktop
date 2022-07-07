pragma Singleton

import QtQuick 2.13

import StatusQ.Controls.Validators 0.1

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
        readonly property int communitiesPortal: 6
    }

    readonly property QtObject appViewStackIndex: QtObject {
        readonly property int chat: 0
        readonly property int community: 7 // any stack layout children with the index 7 or higher is community
        readonly property int communitiesPortal: 1
        readonly property int wallet: 2
        readonly property int browser: 3
        readonly property int profile: 4
        readonly property int node: 5
    }

    readonly property QtObject settingsSubsection: QtObject {
        property int profile: 0
        property int contacts: 1
        property int ensUsernames: 2
        property int messaging: 3
        property int wallet: 4
        property int appearance: 5
        property int language: 6
        property int notifications: 7
        property int devicesSettings: 8
        property int browserSettings: 9
        property int advanced: 10
        property int about: 11
        property int communitiesSettings: 12
        property int signout: 13
        property int backUpSeed: 14
    }

    readonly property QtObject currentUserStatus: QtObject{
        readonly property int unknown: 0
        readonly property int automatic: 1
        readonly property int doNotDisturb: 2
        readonly property int alwaysOnline: 3
        readonly property int inactive: 4
    }

    readonly property QtObject onlineStatus: QtObject{
        readonly property int inactive: 0
        readonly property int online: 1
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

    readonly property QtObject profilePicturesVisibility: QtObject {
        readonly property int contactsOnly: 1
        readonly property int everyone: 2
        readonly property int noOne: 3
    }

    readonly property QtObject profilePicturesShowTo: QtObject {
        readonly property int contactsOnly: 1
        readonly property int everyone: 2
        readonly property int noOne: 3
    }

    readonly property QtObject trustStatus: QtObject {
        readonly property int unknown: 0
        readonly property int trusted: 1
        readonly property int untrustworthy: 2
    }

    readonly property QtObject verificationStatus: QtObject {
        readonly property int unverified: 0
        readonly property int verifying: 1
        readonly property int verified: 2
        readonly property int declined: 3
        readonly property int canceled: 4
        readonly property int trusted: 5
    }

    readonly property QtObject contactsPanelUsage: QtObject {
        readonly property int unknownPosition: -1
        readonly property int mutualContacts: 0
        readonly property int verifiedMutualContacts: 1
        readonly property int sentContactRequest: 2
        readonly property int receivedContactRequest: 3
        readonly property int rejectedSentContactRequest: 4
        readonly property int rejectedReceivedContactRequest: 5
        readonly property int blockedContacts: 6
    }

    readonly property QtObject validators: QtObject {
        readonly property list<StatusValidator> displayName: [
            StatusMinLengthValidator {
                minLength: 5
                errorMessage: qsTr("Username must be at least 5 characters")
            },
            StatusRegularExpressionValidator {
                regularExpression: /^[a-zA-Z0-9\-_]+$/
                errorMessage: qsTr("Only letters, numbers, underscores and hyphens allowed")
            },
            // TODO: Create `StatusMaxLengthValidator` in StatusQ
            StatusValidator {
                name: "maxLengthValidator"
                validate: function (t) { return t.length <= 24 }
                errorMessage: qsTr("24 character username limit")
            },
            StatusValidator {
                name: "endsWith-ethValidator"
                validate: function (t) { return !t.endsWith("-eth") }
                errorMessage: qsTr("Usernames ending with '-eth' are not allowed")
            },
            StatusValidator {
                name: "endsWith_ethValidator"
                validate: function (t) { return !t.endsWith("_eth") }
                errorMessage: qsTr("Usernames ending with '_eth' are not allowed")
            },
            StatusValidator {
                name: "endsWith.ethValidator"
                validate: function (t) { return !t.endsWith(".eth") }
                errorMessage: qsTr("Usernames ending with '.eth' are not allowed")
            },
            StatusValidator {
                name: "isAliasValidator"
                validate: function (t) { return !globalUtils.isAlias(t) }
                errorMessage: qsTr("Sorry, the name you have chosen is not allowed, try picking another username")
            }
        ]
    }

    readonly property QtObject settingsSection: QtObject {
        readonly property int itemSpacing: 10
        readonly property int radius: 8
        readonly property int mainHeaderFontSize: 28
        readonly property int subHeaderFontSize: 15
        readonly property int infoFontSize: 15
        readonly property int infoLineHeight: 22
        readonly property int infoSpacing: 5
        readonly property int itemHeight: 64
        readonly property int leftMargin: 64
        readonly property int rightMargin: 64
        readonly property int topMargin: 64
        readonly property int bottomMargin: 64

        readonly property QtObject notificationsBubble: QtObject {
            readonly property int previewAnonymous: 0
            readonly property int previewNameOnly: 1
            readonly property int previewNameAndMessage: 2
        }

        readonly property QtObject notifications: QtObject {
            readonly property string sendAlertsValue: "SendAlerts"
            readonly property string deliverQuietlyValue: "DeliverQuietly"
            readonly property string turnOffValue: "TurnOff"
        }

        readonly property QtObject exemptions: QtObject {
            readonly property int community: 0
            readonly property int oneToOneChat: 1
            readonly property int groupChat: 2
        }
    }

    readonly property QtObject ephemeralNotificationType: QtObject {
        readonly property int normal: 0
        readonly property int success: 1
    }

    readonly property QtObject transactionEstimatedTime: QtObject {
        readonly property int unknown: 0
        readonly property int lessThanOneMin: 1
        readonly property int lessThanThreeMins: 2
        readonly property int lessThanFiveMins: 3
        readonly property int moreThanFiveMins: 4
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

    readonly property string networkMainnet: "Mainnet"
    readonly property string networkRopsten: "Ropsten"

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
    readonly property string status_prod: "status.prod"

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

    readonly property string mentionSpanTag: `<span style="background-color: ${Style.current.mentionBgColor};"><a style="color:${Style.current.mentionColor};text-decoration:none" href='http://'>`

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

    readonly property string editLabel: ` <span class="isEdited">` + qsTr("(edited)") + `</span>`

    readonly property string newBookmark: " "

    readonly property var ensState: {
        "taken": qsTr("Username already taken :("),
        "taken-custom": qsTr("Username doesn’t belong to you :("),
        "owned": qsTr("Continuing will connect this username with your chat key."),
        "available": qsTr("✓ Username available!"),
        "already-connected": qsTr("Username is already connected with your chat key and can be used inside Status."),
        "connected": qsTr("This user name is owned by you and connected with your chat key. Continue to set `Show my ENS username in chats`."),
        "connected-different-key": qsTr("Continuing will require a transaction to connect the username with your current chat key."),
    }

    readonly property bool isCppApp: typeof cppApp !== "undefined" ? cppApp : false

    readonly property string existingAccountError: "account already exists"
}
