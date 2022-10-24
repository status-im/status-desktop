pragma Singleton

import QtQuick 2.13

import StatusQ.Controls.Validators 0.1

QtObject {

    readonly property QtObject appState: QtObject {
        readonly property int startup: 0
        readonly property int appLoading: 1
        readonly property int main: 2
    }

    readonly property QtObject startupFlow: QtObject {
        readonly property string general: "General"
        readonly property string firstRunNewUserNewKeys: "FirstRunNewUserNewKeys"
        readonly property string firstRunNewUserNewKeycardKeys: "FirstRunNewUserNewKeycardKeys"
        readonly property string firstRunNewUserImportSeedPhrase: "FirstRunNewUserImportSeedPhrase"
        readonly property string firstRunNewUserImportSeedPhraseIntoKeycard: "FirstRunNewUserImportSeedPhraseIntoKeycard"
        readonly property string firstRunOldUserSyncCode: "FirstRunOldUserSyncCode"
        readonly property string firstRunOldUserKeycardImport: "FirstRunOldUserKeycardImport"
        readonly property string firstRunOldUserImportSeedPhrase: "FirstRunOldUserImportSeedPhrase"
        readonly property string appLogin: "AppLogin"
    }

    readonly property QtObject startupState: QtObject {
        readonly property string noState: "NoState"
        readonly property string allowNotifications: "AllowNotifications"
        readonly property string welcome: "Welcome"
        readonly property string welcomeNewStatusUser: "WelcomeNewStatusUser"
        readonly property string welcomeOldStatusUser: "WelcomeOldStatusUser"
        readonly property string userProfileCreate: "UserProfileCreate"
        readonly property string userProfileChatKey: "UserProfileChatKey"
        readonly property string userProfileCreatePassword: "UserProfileCreatePassword"
        readonly property string userProfileConfirmPassword: "UserProfileConfirmPassword"
        readonly property string userProfileImportSeedPhrase: "UserProfileImportSeedPhrase"
        readonly property string userProfileEnterSeedPhrase: "UserProfileEnterSeedPhrase"
        readonly property string biometrics: "Biometrics"
        readonly property string keycardPluginReader: "KeycardPluginReader"
        readonly property string keycardInsertKeycard: "KeycardInsertKeycard"
        readonly property string keycardInsertedKeycard: "KeycardInsertedKeycard"
        readonly property string keycardReadingKeycard: "KeycardReadingKeycard"
        readonly property string keycardRecognizedKeycard: "KeycardRecognizedKeycard"
        readonly property string keycardWrongKeycard: "KeycardWrongKeycard"
        readonly property string keycardCreatePin: "KeycardCreatePin"
        readonly property string keycardRepeatPin: "KeycardRepeatPin"
        readonly property string keycardPinSet: "KeycardPinSet"
        readonly property string keycardEnterPin: "KeycardEnterPin"
        readonly property string keycardWrongPin: "KeycardWrongPin"
        readonly property string keycardEnterPuk: "KeycardEnterPuk"
        readonly property string keycardWrongPuk: "KeycardWrongPuk"
        readonly property string keycardDisplaySeedPhrase: "KeycardDisplaySeedPhrase"
        readonly property string keycardEnterSeedPhraseWords: "KeycardEnterSeedPhraseWords"
        readonly property string keycardNotEmpty: "KeycardNotEmpty"
        readonly property string keycardNotKeycard: "KeycardNotKeycard"
        readonly property string keycardEmpty: "KeycardEmpty"
        readonly property string keycardLocked: "KeycardLocked"
        readonly property string keycardRecover: "KeycardRecover"
        readonly property string keycardMaxPairingSlotsReached: "KeycardMaxPairingSlotsReached"
        readonly property string keycardMaxPinRetriesReached: "KeycardMaxPinRetriesReached"
        readonly property string keycardMaxPukRetriesReached: "KeycardMaxPukRetriesReached"
        readonly property string login: "Login"
        readonly property string loginPlugin: "LoginPlugin"
        readonly property string loginKeycardInsertKeycard: "LoginKeycardInsertKeycard"
        readonly property string loginKeycardInsertedKeycard: "LoginKeycardInsertedKeycard"
        readonly property string loginKeycardReadingKeycard: "LoginKeycardReadingKeycard"
        readonly property string loginKeycardRecognizedKeycard: "LoginKeycardRecognizedKeycard"
        readonly property string loginKeycardEnterPin: "LoginKeycardEnterPin"
        readonly property string loginKeycardEnterPassword: "LoginKeycardEnterPassword"
        readonly property string loginKeycardPinVerified: "LoginKeycardPinVerified"
        readonly property string loginKeycardWrongKeycard: "LoginKeycardWrongKeycard"
        readonly property string loginKeycardWrongPin: "LoginKeycardWrongPin"
        readonly property string loginKeycardMaxPinRetriesReached: "LoginKeycardMaxPinRetriesReached"
        readonly property string loginKeycardMaxPukRetriesReached: "LoginKeycardMaxPukRetriesReached"
        readonly property string loginKeycardMaxPairingSlotsReached: "LoginKeycardMaxPairingSlotsReached"
        readonly property string loginKeycardEmpty: "LoginKeycardEmpty"
        readonly property string loginNotKeycard: "LoginNotKeycard"
    }

    readonly property QtObject predefinedKeycardData: QtObject {
        readonly property int wronglyInsertedCard: 1
        readonly property int hideKeyPair: 2
        readonly property int wrongSeedPhrase: 4
        readonly property int wrongPassword: 8
        readonly property int offerPukForUnlock: 16
        readonly property int useUnlockLabelForLockedState: 32
        readonly property int useGeneralMessageForLockedState: 64
        readonly property int maxPUKReached: 128
    }

    readonly property QtObject keycardSharedFlow: QtObject {
        readonly property string general: "General"
        readonly property string factoryReset: "FactoryReset"
        readonly property string setupNewKeycard: "SetupNewKeycard"
        readonly property string authentication: "Authentication"
        readonly property string unlockKeycard: "UnlockKeycard"
        readonly property string displayKeycardContent: "DisplayKeycardContent"
        readonly property string renameKeycard: "RenameKeycard"
        readonly property string changeKeycardPin: "ChangeKeycardPin"
        readonly property string changeKeycardPuk: "ChangeKeycardPuk"
        readonly property string changePairingCode: "ChangePairingCode"
    }

    readonly property QtObject keycardSharedState: QtObject {
        readonly property string noState: "NoState"
        readonly property string pluginReader: "PluginReader"
        readonly property string readingKeycard: "ReadingKeycard"
        readonly property string insertKeycard: "InsertKeycard"
        readonly property string keycardInserted: "KeycardInserted"
        readonly property string createPin: "CreatePin"
        readonly property string repeatPin: "RepeatPin"
        readonly property string pinSet: "PinSet"
        readonly property string pinVerified: "PinVerified"
        readonly property string enterPin: "EnterPin"
        readonly property string wrongPin: "WrongPin"
        readonly property string enterPuk: "EnterPuk"
        readonly property string wrongPuk: "WrongPuk"
        readonly property string wrongKeychainPin: "WrongKeychainPin"
        readonly property string maxPinRetriesReached: "MaxPinRetriesReached"
        readonly property string maxPukRetriesReached: "MaxPukRetriesReached"
        readonly property string maxPairingSlotsReached: "MaxPairingSlotsReached"
        readonly property string factoryResetConfirmation: "FactoryResetConfirmation"
        readonly property string factoryResetConfirmationDisplayMetadata: "FactoryResetConfirmationDisplayMetadata"
        readonly property string factoryResetSuccess: "FactoryResetSuccess"
        readonly property string keycardEmptyMetadata: "KeycardEmptyMetadata"
        readonly property string keycardMetadataDisplay: "KeycardMetadataDisplay"
        readonly property string keycardEmpty: "KeycardEmpty"
        readonly property string keycardNotEmpty: "KeycardNotEmpty"
        readonly property string keycardAlreadyUnlocked: "KeycardAlreadyUnlocked"
        readonly property string notKeycard: "NotKeycard"
        readonly property string unlockKeycardOptions: "UnlockKeycardOptions"
        readonly property string unlockKeycardSuccess: "UnlockKeycardSuccess"
        readonly property string wrongKeycard: "WrongKeycard"
        readonly property string recognizedKeycard: "RecognizedKeycard"
        readonly property string selectExistingKeyPair: "SelectExistingKeyPair"
        readonly property string enterSeedPhrase: "EnterSeedPhrase"
        readonly property string wrongSeedPhrase: "WrongSeedPhrase"
        readonly property string seedPhraseDisplay: "SeedPhraseDisplay"
        readonly property string seedPhraseEnterWords: "SeedPhraseEnterWords"
        readonly property string keyPairMigrateSuccess: "KeyPairMigrateSuccess"
        readonly property string keyPairMigrateFailure: "KeyPairMigrateFailure"
        readonly property string migratingKeyPair: "MigratingKeyPair"
        readonly property string enterPassword: "EnterPassword"
        readonly property string wrongPassword: "WrongPassword"
        readonly property string biometricsPasswordFailed: "BiometricsPasswordFailed"
        readonly property string biometricsPinFailed: "BiometricsPinFailed"
        readonly property string biometricsPinInvalid: "BiometricsPinInvalid"
        readonly property string biometricsReadyToSign: "BiometricsReadyToSign"
        readonly property string enterBiometricsPassword: "EnterBiometricsPassword"
        readonly property string wrongBiometricsPassword: "WrongBiometricsPassword"
        readonly property string enterKeycardName: "EnterKeycardName"
        readonly property string renamingKeycard: "RenamingKeycard"
        readonly property string keycardRenameSuccess: "KeycardRenameSuccess"
        readonly property string keycardRenameFailure: "KeycardRenameFailure"
        readonly property string changingKeycardPin: "ChangingKeycardPin"
        readonly property string changingKeycardPinSuccess: "ChangingKeycardPinSuccess"
        readonly property string changingKeycardPinFailure: "ChangingKeycardPinFailure"
        readonly property string createPuk: "CreatePuk"
        readonly property string repeatPuk: "RepeatPuk"
        readonly property string changingKeycardPuk: "ChangingKeycardPuk"
        readonly property string changingKeycardPukSuccess: "ChangingKeycardPukSuccess"
        readonly property string changingKeycardPukFailure: "ChangingKeycardPukFailure"
        readonly property string createPairingCode: "CreatePairingCode"
        readonly property string changingKeycardPairingCode: "ChangingKeycardPairingCode"
        readonly property string changingKeycardPairingCodeSuccess: "ChangingKeycardPairingCodeSuccess"
        readonly property string changingKeycardPairingCodeFailure: "ChangingKeycardPairingCodeFailure"
    }

    readonly property QtObject keycardAnimations: QtObject {

        readonly property QtObject cardInsert: QtObject {
            readonly property string pattern: "keycard/card_insert/img-%1"
            readonly property int startImgIndexForTheFirstLoop: 0
            readonly property int startImgIndexForOtherLoops: 0
            readonly property int endImgIndex: 16
            readonly property int duration: 1000
            readonly property int loops: 1
        }

        readonly property QtObject cardInserted: QtObject {
            readonly property string pattern: "keycard/card_inserted/img-%1"
            readonly property int startImgIndexForTheFirstLoop: 0
            readonly property int startImgIndexForOtherLoops: 0
            readonly property int endImgIndex: 29
            readonly property int duration: 1000
            readonly property int loops: 1
        }

        readonly property QtObject warning: QtObject {
            readonly property string pattern: "keycard/warning/img-%1"
            readonly property int startImgIndexForTheFirstLoop: 0
            readonly property int startImgIndexForOtherLoops: 0
            readonly property int endImgIndex: 55
            readonly property int duration: 3000
            readonly property int loops: 1
        }

        readonly property QtObject strongError: QtObject {
            readonly property string pattern: "keycard/strong_error/img-%1"
            readonly property int startImgIndexForTheFirstLoop: 0
            readonly property int startImgIndexForOtherLoops: 18
            readonly property int endImgIndex: 29
            readonly property int duration: 1300
            readonly property int loops: -1
        }

        readonly property QtObject success: QtObject {
            readonly property string pattern: "keycard/success/img-%1"
            readonly property int startImgIndexForTheFirstLoop: 0
            readonly property int startImgIndexForOtherLoops: 0
            readonly property int endImgIndex: 29
            readonly property int duration: 1300
            readonly property int loops: 1
        }

        readonly property QtObject strongSuccess: QtObject {
            readonly property string pattern: "keycard/strong_success/img-%1"
            readonly property int startImgIndexForTheFirstLoop: 0
            readonly property int startImgIndexForOtherLoops: 0
            readonly property int endImgIndex: 20
            readonly property int duration: 1300
            readonly property int loops: 1
        }
    }

    readonly property QtObject keychain: QtObject {
        readonly property QtObject errorType: QtObject {
            readonly property string authentication: "authentication"
            readonly property string keychain: "keychain"
        }

        readonly property QtObject storedValue: QtObject {
            readonly property string store: "store"
            readonly property string notNow: "notNow"
            readonly property string never: "never"
        }
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
        property int keycard: 13
        property int signout: 14
        property int backUpSeed: 15
    }

    readonly property QtObject currentUserStatus: QtObject{
        readonly property int unknown: 0
        readonly property int automatic: 1
        readonly property int doNotDisturb: 2
        readonly property int alwaysOnline: 3
        readonly property int inactive: 4
    }

    readonly property QtObject onboarding: QtObject {
        readonly property int userImageWidth: 40
        readonly property int userImageHeight: 40
        readonly property int titleFontSize: 17
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
        readonly property int discordMessageType: 12
    }

    readonly property QtObject messageModelRoles: QtObject {
        readonly property int responseToMessageWithId: 262 // ModelRole.ResponseToMessageWithId
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
        readonly property int importantInfoFontSize: 18
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

    readonly property QtObject translationsState: QtObject {
        readonly property int alpha: 0
        readonly property int beta: 1
        readonly property int stable: 2
    }

    readonly property QtObject keycard: QtObject {

        readonly property QtObject general: QtObject {
            readonly property string purchasePage: "https://get.keycard.tech"
            readonly property int onboardingHeight: 460
            readonly property int loginHeight: 460
            readonly property int imageWidth: 240
            readonly property int imageHeight: 240
            readonly property int seedPhraseWidth: 816
            readonly property int seedPhraseHeight: 228
            readonly property int enterSeedPhraseWordsWidth: 868
            readonly property int enterSeedPhraseWordsHeight: 60
            readonly property int keycardPinLength: 6
            readonly property int keycardPukLength: 12
            readonly property int keycardNameLength: 20
            readonly property int keycardNameInputWidth: 448
            readonly property int keycardPairingCodeInputWidth: 512
            readonly property int keycardPukAdditionalSpacingOnEvery4Items: 4
            readonly property int keycardPukAdditionalSpacing: 32
            readonly property int fontSize1: 22
            readonly property int fontSize2: 15
            readonly property int fontSize3: 12
            readonly property int seedPhraseCellWidth: 193
            readonly property int seedPhraseCellHeight: 60
            readonly property int seedPhraseCellNumberWidth: 24
            readonly property int seedPhraseCellFontSize: 12
            readonly property int buttonFontSize: 15
            readonly property int pukCellWidth: 50
            readonly property int pukCellHeight: 60
            readonly property int popupWidth: 640
            readonly property int popupHeight: 640
            readonly property int popupBiggerHeight: 766
            readonly property int titleHeight: 44
            readonly property int messageHeight: 48
            readonly property int footerButtonsHeight: 44
            readonly property int loginInfoHeight1: 24
            readonly property int loginInfoHeight2: 44
            readonly property int loginStatusLogoWidth: 128
            readonly property int loginStatusLogoHeight: 128
        }

        readonly property QtObject keyPairType: QtObject {
            readonly property int unknown: -1
            readonly property int profile: 0
            readonly property int seedImport: 1
            readonly property int privateKeyImport: 2
        }

        readonly property QtObject shared: QtObject {
            readonly property int imageWidth: 240
            readonly property int imageHeight: 240
        }
    }

    readonly property QtObject socialLinkType: QtObject {
        readonly property int custom: 0
        readonly property int twitter: 1
        readonly property int personalSite: 2
        readonly property int github: 3
        readonly property int youtube: 4
        readonly property int discord: 5
        readonly property int telegram: 6
    }

    enum DiscordImportErrorCode {
        Unknown = 0,
        Warning = 1,
        Error = 2
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
    readonly property int activityCenterNotificationTypeContactRequest: 5

    readonly property int contactRequestStateNone: 0
    readonly property int contactRequestStatePending: 1
    readonly property int contactRequestStateAccepted: 2
    readonly property int contactRequestStateDismissed: 3

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

    readonly property string deepLinkPrefix: 'status-im://'
    readonly property string joinStatusLink: 'join.status.im'
    readonly property string communityLinkPrefix: 'https://join.status.im/c/'
    readonly property string userLinkPrefix: 'https://join.status.im/u/'
    readonly property string statusLinkPrefix: 'https://status.im/'

    readonly property int maxUploadFiles: 5
    readonly property double maxUploadFilesizeMB: 10

    readonly property int maxNumberOfPins: 3

    readonly property var acceptedImageExtensions: [".png", ".jpg", ".jpeg", ".svg", ".gif"]
    readonly property var acceptedDragNDropImageExtensions: [".png", ".jpg", ".jpeg", ".heif", ".tif", ".tiff"]

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

    // WARNING: Remove later. Moved to StatusQ.
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

    enum TransactionStatus {
        Failure = 0,
        Success = 1
    }
}
