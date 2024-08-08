pragma Singleton

import QtQuick 2.13

import StatusQ.Components 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Core.Theme 0.1

QtObject {

    readonly property QtObject appState: QtObject {
        readonly property int startup: 0
        readonly property int appLoading: 1
        readonly property int main: 2
        readonly property int appEncryptionProcess: 3
    }

    readonly property QtObject chains: QtObject {
        readonly property int mainnetChainId: 1
        readonly property int sepoliaChainId: 11155111
        readonly property int optimismChainId: 10
        readonly property int optimismSepoliaChainId: 11155420
        readonly property int arbitrumChainId: 42161
        readonly property int arbitrumSepoliaChainId: 421614
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
        readonly property string lostKeycardReplacement: "LostKeycardReplacement"
        readonly property string lostKeycardConvertToRegularAccount: "LostKeycardConvertToRegularAccount"
    }

    readonly property QtObject startupState: QtObject {
        readonly property string noState: "NoState"
        readonly property string allowNotifications: "AllowNotifications"
        readonly property string welcome: "Welcome"
        readonly property string welcomeNewStatusUser: "WelcomeNewStatusUser"
        readonly property string welcomeOldStatusUser: "WelcomeOldStatusUser"
        readonly property string recoverOldUser: "RecoverOldUser"
        readonly property string userProfileCreate: "UserProfileCreate"
        readonly property string userProfileChatKey: "UserProfileChatKey"
        readonly property string userProfileCreateSameChatKey: "UserProfileCreateSameChatKey"
        readonly property string userProfileCreatePassword: "UserProfileCreatePassword"
        readonly property string userProfileConfirmPassword: "UserProfileConfirmPassword"
        readonly property string userProfileImportSeedPhrase: "UserProfileImportSeedPhrase"
        readonly property string userProfileEnterSeedPhrase: "UserProfileEnterSeedPhrase"
        readonly property string userProfileWrongSeedPhrase: "UserProfileWrongSeedPhrase"
        readonly property string biometrics: "Biometrics"
        readonly property string keycardNoPCSCService: "KeycardNoPCSCService"
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
        readonly property string loginNoPCSCService: "LoginNoPCSCService"
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
        readonly property string loginKeycardConvertedToRegularAccount: "LoginKeycardConvertedToRegularAccount"
        readonly property string profileFetching: "ProfileFetching"
        readonly property string profileFetchingSuccess: "ProfileFetchingSuccess"
        readonly property string profileFetchingTimeout: "ProfileFetchingTimeout"
        readonly property string profileFetchingAnnouncement: "ProfileFetchingAnnouncement"
        readonly property string lostKeycardOptions: "LostKeycardOptions"
        readonly property string syncDeviceWithSyncCode: "SyncDeviceWithSyncCode"
        readonly property string syncDeviceResult: "SyncDeviceResult"
    }

    readonly property QtObject predefinedKeycardData: QtObject {
        readonly property int wronglyInsertedCard: 1
        readonly property int hideKeyPair: 2
        readonly property int wrongSeedPhrase: 4
        readonly property int wrongPassword: 8
        readonly property int offerPukForUnlock: 16
        readonly property int disableSeedPhraseForUnlock: 32
        readonly property int useGeneralMessageForLockedState: 64
        readonly property int maxPUKReached: 128
        readonly property int copyFromAKeycardPartDone: 256
        readonly property int maxPairingSlotsReached: 512
    }

    readonly property QtObject keycardSharedFlow: QtObject {
        readonly property string general: "General"
        readonly property string factoryReset: "FactoryReset"
        readonly property string setupNewKeycard: "SetupNewKeycard"
        readonly property string setupNewKeycardNewSeedPhrase: "SetupNewKeycardNewSeedPhrase"
        readonly property string setupNewKeycardOldSeedPhrase: "SetupNewKeycardOldSeedPhrase"
        readonly property string importFromKeycard: "ImportFromKeycard"
        readonly property string authentication: "Authentication"
        readonly property string unlockKeycard: "UnlockKeycard"
        readonly property string displayKeycardContent: "DisplayKeycardContent"
        readonly property string renameKeycard: "RenameKeycard"
        readonly property string changeKeycardPin: "ChangeKeycardPin"
        readonly property string changeKeycardPuk: "ChangeKeycardPuk"
        readonly property string changePairingCode: "ChangePairingCode"
        readonly property string createCopyOfAKeycard: "CreateCopyOfAKeycard"
        readonly property string migrateFromKeycardToApp: "MigrateFromKeycardToApp"
        readonly property string migrateFromAppToKeycard: "MigrateFromAppToKeycard"
        readonly property string sign: "Sign"
    }

    readonly property QtObject keycardSharedState: QtObject {
        readonly property string keycardFlowStarted: "KeycardFlowStarted"
        readonly property string biometrics: "Biometrics"
        readonly property string noPCSCService: "NoPCSCService"
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
        readonly property string unlockingKeycard: "UnlockingKeycard"
        readonly property string unlockKeycardFailure: "UnlockKeycardFailure"
        readonly property string unlockKeycardSuccess: "UnlockKeycardSuccess"
        readonly property string wrongKeycard: "WrongKeycard"
        readonly property string recognizedKeycard: "RecognizedKeycard"
        readonly property string selectExistingKeyPair: "SelectExistingKeyPair"
        readonly property string enterSeedPhrase: "EnterSeedPhrase"
        readonly property string wrongSeedPhrase: "WrongSeedPhrase"
        readonly property string seedPhraseAlreadyInUse: "SeedPhraseAlreadyInUse"
        readonly property string seedPhraseDisplay: "SeedPhraseDisplay"
        readonly property string seedPhraseEnterWords: "SeedPhraseEnterWords"
        readonly property string keyPairMigrateSuccess: "KeyPairMigrateSuccess"
        readonly property string keyPairMigrateFailure: "KeyPairMigrateFailure"
        readonly property string migrateKeypairToApp: "MigrateKeypairToApp"
        readonly property string migrateKeypairToKeycard: "MigrateKeypairToKeycard"
        readonly property string migratingKeypairToApp: "MigratingKeypairToApp"
        readonly property string migratingKeypairToKeycard: "MigratingKeypairToKeycard"
        readonly property string enterPassword: "EnterPassword"
        readonly property string wrongPassword: "WrongPassword"
        readonly property string createPassword: "CreatePassword"
        readonly property string confirmPassword: "ConfirmPassword"
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
        readonly property string removeKeycard: "RemoveKeycard"
        readonly property string sameKeycard: "SameKeycard"
        readonly property string copyToKeycard: "CopyToKeycard"
        readonly property string copyingKeycard: "CopyingKeycard"
        readonly property string copyingKeycardFailure: "CopyingKeycardFailure"
        readonly property string copyingKeycardSuccess: "CopyingKeycardSuccess"
        readonly property string manageKeycardAccounts: "ManageKeycardAccounts"
        readonly property string creatingAccountNewSeedPhrase: "CreatingAccountNewSeedPhrase"
        readonly property string creatingAccountNewSeedPhraseSuccess: "CreatingAccountNewSeedPhraseSuccess"
        readonly property string creatingAccountNewSeedPhraseFailure: "CreatingAccountNewSeedPhraseFailure"
        readonly property string creatingAccountOldSeedPhrase: "CreatingAccountOldSeedPhrase"
        readonly property string creatingAccountOldSeedPhraseSuccess: "CreatingAccountOldSeedPhraseSuccess"
        readonly property string creatingAccountOldSeedPhraseFailure: "CreatingAccountOldSeedPhraseFailure"
        readonly property string importingFromKeycard: "ImportingFromKeycard"
        readonly property string importingFromKeycardSuccess: "ImportingFromKeycardSuccess"
        readonly property string importingFromKeycardFailure: "ImportingFromKeycardFailure"
    }

    readonly property QtObject keycardAnimations: QtObject {

        readonly property QtObject cardInsert: QtObject {
            readonly property string pattern: "keycard/card_insert/img-%1"
            readonly property int startImgIndexForTheFirstLoop: 0
            readonly property int startImgIndexForOtherLoops: 0
            readonly property int endImgIndex: 15
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

        readonly property QtObject cardRemoved: QtObject {
            readonly property string pattern: "keycard/card_removed/img-%1"
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

        readonly property QtObject processing: QtObject {
            readonly property string pattern: "keycard/warning/img-%1"
            readonly property int startImgIndexForTheFirstLoop: 0
            readonly property int startImgIndexForOtherLoops: 18
            readonly property int endImgIndex: 47
            readonly property int duration: 1500
            readonly property int loops: -1
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

    readonly property int chatSectionLeftColumnWidth: 304

    readonly property QtObject appSection: QtObject {
        readonly property int chat: 0
        readonly property int community: 1
        readonly property int wallet: 2
        readonly property int profile: 3
        readonly property int node: 4
        readonly property int communitiesPortal: 5
    }

    readonly property QtObject appViewStackIndex: QtObject {
        readonly property int chat: 0
        readonly property int community: 7 // any stack layout children with the index 7 or higher is community
        readonly property int communitiesPortal: 1
        readonly property int wallet: 2
        readonly property int profile: 3
        readonly property int node: 4
    }

    readonly property QtObject settingsSubsection: QtObject {
        readonly property int profile: 0
        readonly property int password: 1
        readonly property int contacts: 2
        readonly property int ensUsernames: 3
        readonly property int messaging: 4
        readonly property int wallet:5
        readonly property int appearance: 6
        readonly property int language: 7
        readonly property int notifications: 8
        readonly property int syncingSettings: 9
        readonly property int advanced: 10
        readonly property int about: 11
        readonly property int communitiesSettings: 12
        readonly property int keycard: 13
        readonly property int about_terms: 14 // a subpage under "About"
        readonly property int about_privacy: 15 // a subpage under "About"
        readonly property int privacyAndSecurity: 16

        // special treatment; these do not participate in the main settings' StackLayout
        readonly property int signout: 17
        readonly property int backUpSeed: 18
    }

    readonly property QtObject walletSettingsSubsection: QtObject {
        readonly property int manageNetworks: 0
        readonly property int manageAccounts: 1
        readonly property int manageAssets: 2
        readonly property int manageCollectibles: 3
        readonly property int manageHidden: 4
        readonly property int manageAdvanced: 5
    }

    readonly property QtObject currentUserStatus: QtObject{
        readonly property int unknown: 0
        readonly property int automatic: 1
        readonly property int doNotDisturb: 2
        readonly property int alwaysOnline: 3
        readonly property int inactive: 4
    }

    readonly property QtObject onboarding: QtObject {
        readonly property int loginHeight: 370
        readonly property int logoImageWidth: 128
        readonly property int logoImageHeight: 128
        readonly property int biometricsImageWidth: 188
        readonly property int biometricsImageHeight: 185
        readonly property int userImageWidth: 40
        readonly property int userImageHeight: 40
        readonly property int titleFontSize: 17
        readonly property int fontSize1: 22
        readonly property int fontSize2: 17
        readonly property int fontSize3: 15
        readonly property int fontSize4: 12
        readonly property int loginInfoHeight1: 24
        readonly property int loginInfoHeight2: 44
        readonly property int loginInfoHeight3: 66
        readonly property int radius: 8
        readonly property QtObject profileFetching: QtObject {
            readonly property int    timeout: 120 * 1000 //2 mins in milliseconds
            readonly property int    titleFontSize: 22
            readonly property int    entityFontSize: 15
            readonly property int    entityProgressFontSize: 12
            readonly property string imgInProgress: "onboarding/profile_fetching_in_progress"

            readonly property QtObject entity: QtObject {
                readonly property string profile: "profile"
                readonly property string contacts: "contacts"
                readonly property string communities: "communities"
                readonly property string settings: "settings"
                readonly property string keypairs: "keypairs"
                readonly property string watchOnlyAccounts: "watchOnlyAccounts"
            }
        }
    }

    readonly property QtObject onlineStatus: QtObject{
        readonly property int unknown: -1
        readonly property int inactive: 0
        readonly property int online: 1
    }

    readonly property QtObject chatType: QtObject{
        readonly property int category: -1
        readonly property int unknown: 0
        readonly property int oneToOne: 1
        readonly property int publicChat: 2
        readonly property int privateGroupChat: 3
        readonly property int profile: 4
        readonly property int communityChat: 6
    }

    readonly property QtObject memberRole: QtObject{
        readonly property int none: 0
        readonly property int owner: 1
        readonly property int admin: 4
        readonly property int tokenMaster: 5
    }

    readonly property QtObject permissionType: QtObject{
        readonly property int none: 0
        readonly property int admin: 1
        readonly property int member: 2
        readonly property int read: 3
        readonly property int viewAndPost: 4
        readonly property int becomeTokenMaster: 5
        readonly property int becomeTokenOwner: 6
    }

    readonly property QtObject messageContentType: QtObject {
        readonly property int newMessagesMarker: -3
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
        readonly property int contactRequestType: 11
        readonly property int discordMessageType: 12
        readonly property int systemMessagePinnedMessage: 14
        readonly property int systemMessageMutualEventSent: 15
        readonly property int systemMessageMutualEventAccepted: 16
        readonly property int systemMessageMutualEventRemoved: 17
        readonly property int bridgeMessageType: 18
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
        readonly property int untrustworthy: 6
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

    readonly property QtObject keypair: QtObject {
        readonly property int nameLengthMax: 24
        readonly property int nameLengthMin: 5

        readonly property QtObject type: QtObject {
            readonly property int unknown: -1
            readonly property int profile: 0
            readonly property int seedImport: 1
            readonly property int privateKeyImport: 2
            readonly property int watchOnly: 3 // added just because of UI, impossible to have watch only keypair
        }

        readonly property QtObject operability: QtObject {
            readonly property string nonOperable: "no"        // an account is non operable it is not a keycard account and there is no keystore file for it and no keystore file for the address it is derived from
            readonly property string partiallyOperable: "partially" // an account is partially operable if it is not a keycard account and there is created keystore file for the address it is derived from
            readonly property string fullyOperable: "fully" // an account is fully operable if it is not a keycard account and there is a keystore file for it
        }

        readonly property QtObject syncedFrom: QtObject {
            readonly property string backup: "backup" // means an account is coming from backed up data
        }
    }

    readonly property QtObject validators: QtObject {
        readonly property list<StatusValidator> keypairName: [
            StatusValidator {
                name: "startsWithSpaceValidator"
                validate: function (t) { return !t.startsWith(" ") }
                errorMessage: qsTr("Key pair starting with whitespace are not allowed")
            },
            StatusRegularExpressionValidator {
                regularExpression: /^[a-zA-Z0-9\-_ ]+$/
                errorMessage: errorMessages.alphanumericalExpandedRegExp
            },
            StatusMinLengthValidator {
                minLength: keypair.nameLengthMin
                errorMessage: qsTr("Key pair must be at least %n character(s)", "", keypair.nameLengthMin)
            }
        ]

        readonly property list<StatusValidator> displayName: [
            StatusValidator {
                name: "startsWithSpaceValidator"
                validate: function (t) { return !(t.startsWith(" ") || t.endsWith(" "))}
                errorMessage: qsTr("Display Names can’t start or end with a space")
            },
            StatusRegularExpressionValidator {
                regularExpression: /^$|^[a-zA-Z0-9\-_\u0020]+$/
                errorMessage: qsTr("Invalid characters (use A-Z and 0-9, hyphens and underscores only)")
            },
            StatusMinLengthValidator {
                minLength: keypair.nameLengthMin
                errorMessage: qsTr("Display Names must be at least %n character(s) long", "", keypair.nameLengthMin)
            },
            // TODO: Create `StatusMaxLengthValidator` in StatusQ
            StatusValidator {
                name: "maxLengthValidator"
                validate: function (t) { return t.length <= keypair.nameLengthMax }
                errorMessage: qsTr("Display Names can’t be longer than %n character(s)", "", keypair.nameLengthMax)
            },
            StatusValidator {
                name: "endsWith-ethValidator"
                validate: function (t) { return !(t.endsWith("-eth") || t.endsWith("_eth") || t.endsWith(".eth")) }
                errorMessage: qsTr("Display Names can’t end in “.eth”, “_eth” or “-eth”")
            },
            StatusValidator {
                name: "isAliasValidator"
                validate: function (t) { return !Utils.isAlias(t) }
                errorMessage: qsTr("Adjective-animal Display Name formats are not allowed")
            },
            StatusValidator {
                name: "isDuplicateInComunitiesValidator"
                validate: function(t) { return !Utils.isDisplayNameDupeOfCommunityMember(t) }
                errorMessage: qsTr("This Display Name is already in use in one of your joined communities")
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

        property string dotSepString: '<font size="3">  &#x2022; </font>'
    }

    readonly property QtObject ephemeralNotificationType: QtObject {
        readonly property int normal: 0
        readonly property int success: 1
        readonly property int danger: 2
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
            readonly property int imageWidth: 240
            readonly property int imageHeight: 240
            readonly property int seedPhraseWidth: 816
            readonly property int seedPhraseHeight: 228
            readonly property int enterSeedPhraseWordsWidth: 868
            readonly property int enterSeedPhraseWordsHeight: 60
            readonly property int keycardPinLength: 6
            readonly property int keycardPukLength: 12
            readonly property int keycardNameLength: keypair.nameLengthMax
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
            readonly property int popupHeight: 500
            readonly property int popupBiggerHeight: 626
            readonly property int titleHeight: 60
            readonly property int messageHeight: 48
            readonly property int footerButtonsHeight: 44
            readonly property int loginInfoHeight1: 24
            readonly property int loginInfoHeight2: 44
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

    readonly property QtObject regularExpressions: QtObject {
        readonly property var alphanumerical: /^$|^[a-zA-Z0-9]+$/
        readonly property var alphanumericalExpanded: /^$|^[a-zA-Z0-9\-_\.\u0020]+$/
        readonly property var alphanumericalExpanded1: /^[a-zA-Z0-9\-_]+(?: [a-zA-Z0-9\-_]+)*$/
        readonly property var alphanumericalWithSpace: /^$|^[a-zA-Z0-9\s]+$/
        readonly property var asciiPrintable:         /^$|^[!-~]+$/
        readonly property var ascii:                  /^$|^[\x00-\x7F]+$/
        readonly property var capitalOnly: /^$|^[A-Z]+$/
        readonly property var numerical: /^$|^[0-9]+$/
        readonly property var emoji: /\ud83c\udff4(\udb40[\udc61-\udc7a])+\udb40\udc7f|(\ud83c[\udde6-\uddff]){2}|([\#\*0-9]\ufe0f?\u20e3)|(\u00a9|\u00ae|[\u203c\u2049\u20e3\u2122\u2139\u2194-\u2199\u21a9\u21aa\u231a\u231b\u2328\u23cf\u23e9-\u23fa\u24c2\u25aa\u25ab\u25b6\u25c0\u25fb-\u25fe\u2600-\u2604\u260e\u2611\u2614\u2615\u2618\u261d\u2620\u2622\u2623\u2626\u262a\u262e\u262f\u2638-\u263a\u2640\u2642\u2648-\u2653\u265f\u2660\u2663\u2665\u2666\u2668\u267b\u267e\u267f\u2692-\u2697\u2699\u269b\u269c\u26a0\u26a1\u26a7\u26aa\u26ab\u26b0\u26b1\u26bd\u26be\u26c4\u26c5\u26c8\u26ce\u26cf\u26d1\u26d3\u26d4\u26e9\u26ea\u26f0-\u26f5\u26f7-\u26fa\u26fd\u2702\u2705\u2708-\u270d\u270f\u2712\u2714\u2716\u271d\u2721\u2728\u2733\u2734\u2744\u2747\u274c\u274e\u2753-\u2755\u2757\u2763\u2764\u2795-\u2797\u27a1\u27b0\u27bf\u2934\u2935\u2b05-\u2b07\u2b1b\u2b1c\u2b50\u2b55\u3030\u303d\u3297\u3299]|\ud83c[\udc04\udccf\udd70\udd71\udd7e\udd7f\udd8e\udd91-\udd9a\udde6-\uddff\ude01\ude02\ude1a\ude2f\ude32-\ude3a\ude50\ude51\udf00-\udf21\udf24-\udf93\udf96\udf97\udf99-\udf9b\udf9e-\udff0\udff3-\udff5\udff7-\udfff]|\ud83d[\udc00-\udcfd\udcff-\udd3d\udd49-\udd4e\udd50-\udd67\udd6f\udd70\udd73-\udd7a\udd87\udd8a-\udd8d\udd90\udd95\udd96\udda4\udda5\udda8\uddb1\uddb2\uddbc\uddc2-\uddc4\uddd1-\uddd3\udddc-\uddde\udde1\udde3\udde8\uddef\uddf3\uddfa-\ude4f\ude80-\udec5\udecb-\uded2\uded5-\uded7\udedc-\udee5\udee9\udeeb\udeec\udef0\udef3-\udefc\udfe0-\udfeb\udff0]|\ud83e[\udd0c-\udd3a\udd3c-\udd45\udd47-\ude7c\ude80-\ude88\ude90-\udebd\udebf-\udec5\udece-\udedb\udee0-\udee8\udef0-\udef8])((\ud83c[\udffb-\udfff])?(\ud83e[\uddb0-\uddb3])?(\ufe0f?\u200d([\u2000-\u3300]|[\ud83c-\ud83e][\ud000-\udfff])\ufe0f?)?)*/g;
        readonly property var asciiWithEmoji: /^[\u00a9\u00ae\u2000-\u3300\ud83c\ud000-\udfff\ud83d\ud000-\udfff\ud83e\ud000-\udfff\u0000-\u007F]+$/
    }

    readonly property QtObject errorMessages: QtObject {
        readonly property string alphanumericalRegExp: qsTr("Only letters and numbers allowed")
        readonly property string alphanumericalExpandedRegExp: qsTr("Only letters, numbers, underscores, periods, whitespaces and hyphens allowed")
        readonly property string alphanumericalExpanded1RegExp: qsTr("Invalid characters (A-Z and 0-9, single whitespace, hyphens and underscores only)")
        readonly property string alphanumericalWithSpaceRegExp: qsTr("Special characters are not allowed")
        readonly property string asciiRegExp: qsTr("Only letters, numbers and ASCII characters allowed")
        readonly property string emojRegExp: qsTr("Name is too cool (use A-Z and 0-9, single whitespace, hyphens and underscores only)")
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

    readonly property int maxSocialLinkTextLength: 24

    readonly property QtObject localPairingEventType: QtObject {
        readonly property int eventUnknown: -1
        readonly property int eventConnectionError: 0
        readonly property int eventConnectionSuccess: 1
        readonly property int eventTransferError: 2
        readonly property int eventTransferSuccess: 3
        readonly property int eventReceivedAccount: 4
        readonly property int eventProcessSuccess: 5
        readonly property int eventProcessError: 6
    }

    readonly property QtObject addAccountPopup: QtObject {
        readonly property int popupWidth: 480
        readonly property int contentHeight1: 554
        readonly property int contentHeight2: 642
        readonly property int itemHeight: 64
        readonly property int importPrivateKeyWarningHeight: 86
        readonly property int labelFontSize1: 15
        readonly property int labelFontSize2: 13
        readonly property int footerButtonsHeight: 44
        readonly property int keyPairNameMaxLength: 20
        readonly property int keyPairAccountNameMinLength: 5
        readonly property int stepperWidth: 242
        readonly property int stepperHeight: 30

        readonly property QtObject keyPairType: QtObject {
            readonly property int unknown: -1
            readonly property int profile: 0
            readonly property int seedImport: 1
            readonly property int privateKeyImport: 2
        }

        readonly property QtObject predefinedPaths: QtObject {
            readonly property string custom: "m/44'"
            readonly property string ethereum: "m/44'/60'/0'/0"
            readonly property string ethereumRopsten: "m/44'/1'/0'/0"
            readonly property string ethereumLedger: "m/44'/60'/0'"
            readonly property string ethereumLedgerLive: "m/44'/60'"
        }

        readonly property QtObject state: QtObject {
            readonly property string noState: "NoState"
            readonly property string main: "Main"
            readonly property string selectMasterKey: "SelectMasterKey"
            readonly property string enterSeedPhrase: "EnterSeedPhrase"
            readonly property string enterSeedPhraseWord1: "EnterSeedPhraseWord1"
            readonly property string enterSeedPhraseWord2: "EnterSeedPhraseWord2"
            readonly property string enterPrivateKey: "EnterPrivateKey"
            readonly property string enterKeypairName: "EnterKeypairName"
            readonly property string displaySeedPhrase: "DisplaySeedPhrase"
            readonly property string confirmAddingNewMasterKey: "ConfirmAddingNewMasterKey"
            readonly property string confirmSeedPhraseBackup: "ConfirmSeedPhraseBackup"
        }
    }

    readonly property QtObject keypairImportPopup: QtObject {
        readonly property int popupWidth: 480
        readonly property int contentHeight: 626
        readonly property int footerButtonsHeight: 44
        readonly property int labelFontSize1: 15
        readonly property string instructionsLabelForQr: qsTr("How to display the QR code on your other device")
        readonly property string instructionsLabelForEncryptedKey: qsTr("How to copy the encrypted key from your other device")

        readonly property QtObject mode: QtObject {
            readonly property int selectKeypair: 1
            readonly property int selectImportMethod: 2
            readonly property int importViaSeedPhrase: 3
            readonly property int importViaPrivateKey: 4
            readonly property int importViaQr: 5
            readonly property int exportKeypairQr: 6
        }

        readonly property QtObject state: QtObject {
            readonly property string noState: "NoState"
            readonly property string selectKeypair: "SelectKeypair"
            readonly property string selectImportMethod: "SelectImportMethod"
            readonly property string exportKeypair: "ExportKeypair"
            readonly property string importQr: "ImportQr"
            readonly property string importSeedPhrase: "ImportSeedPhrase"
            readonly property string importPrivateKey: "ImportPrivateKey"
            readonly property string displayInstructions: "DisplayInstructions"
        }
    }

    readonly property QtObject localPairingAction: QtObject {
        readonly property int actionUnknown: 0
        readonly property int actionConnect: 1
        readonly property int actionPairingAccount: 2
        readonly property int actionSyncDevice: 3
    }

    readonly property QtObject supportedTokenSources: QtObject {
        readonly property string uniswap: "Uniswap Labs Default Token List"
        readonly property string status: "Status Token List"
        readonly property string custom: "custom"
    }

    enum LocalPairingState {
        Idle = 0,
        Transferring = 1,
        Error = 2,
        Finished = 3
    }

    readonly property var socialLinkPrefixesByType: [ // NB order must match the "socialLinkType" enum above
        "",
        "https://twitter.com/",
        "",
        "https://github.com/",
        "https://www.youtube.com/",
        "https://discordapp.com/users/",
        "https://t.me/"
    ]

    enum DiscordImportErrorCode {
        Unknown = 1,
        Warning = 2,
        Error = 3
    }

    readonly property int communityImported: 0
    readonly property int communityImportingInProgress: 1
    readonly property int communityImportingError: 2
    readonly property int communityImportingCanceled: 3

    readonly property int communityChatPublicAccess: 1
    readonly property int communityChatInvitationOnlyAccess: 2
    readonly property int communityChatOnRequestAccess: 3

    readonly property int maxNbDaysToFetch: 30
    readonly property int fetchRangeLast24Hours: 86400
    readonly property int fetchRangeLast2Days: 172800
    readonly property int fetchRangeLast3Days: 259200
    readonly property int fetchRangeLast7Days: 604800

    readonly property int limitLongChatText: 500
    readonly property int limitLongChatTextCompactMode: 1000

    readonly property int notificationPopupTTL: 5000

    readonly property string lightThemeName: "light"
    readonly property string darkThemeName: "dark"

    readonly property int notifyAllMessages: 0
    readonly property int notifyJustMentions: 1
    readonly property int notifyNone: 2


    readonly property string watchWalletType: "watch"
    readonly property string keyWalletType: "key"
    readonly property string seedWalletType: "seed"
    readonly property string generatedWalletType: "generated"


    readonly property QtObject walletConnections: QtObject {
        readonly property string collectibles: "collectibles"
        readonly property string blockchains: "blockchains"
        readonly property string market: "market"
    }

    readonly property QtObject walletConstants: QtObject {
        readonly property string maxNumberOfAccountsTitle: qsTr("Limit of 20 accounts reached")
        readonly property string maxNumberOfAccountsContent: qsTr("Remove any account to add a new one.")

        readonly property string maxNumberOfKeypairsTitle: qsTr("Limit of 5 key pairs reached")
        readonly property string maxNumberOfKeypairsContent: qsTr("Remove key pair to add a new one.")

        readonly property string maxNumberOfWatchOnlyAccountsTitle: qsTr("Limit of 3 watched addresses reached")
        readonly property string maxNumberOfWatchOnlyAccountsContent: qsTr("Remove a watched address to add a new one.")

        readonly property string maxNumberOfSavedAddressesTitle: qsTr("Limit of 20 saved addresses reached")
        readonly property string maxNumberOfSavedAddressesContent: qsTr("Remove a saved address to add a new one.")
    }

    enum ConnectionStatus {
        Success = 0,
        Failure = 1,
        Retrying = 2
    }

    readonly property string dummyText: "Dummy"

    readonly property string windows: "windows"
    readonly property string linux: "linux"
    readonly property string mac: "osx"

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

    readonly property string ethToken: "ETH"

    readonly property QtObject networkShortChainNames: QtObject {
        readonly property string mainnet: "eth"
        readonly property string arbitrum: "arb1"
        readonly property string optimism: "oeth"

        readonly property string optimism_goerli: "goOpt"
        readonly property string arbitrum_goerli: "goArb"
    }

    readonly property QtObject networkExplorerLinks: QtObject {
        readonly property string etherscan: "https://etherscan.io"
        readonly property string arbiscan: "https://arbiscan.io"
        readonly property string optimism: "https://optimistic.etherscan.io"

        readonly property string goerliEtherscan: "https://goerli.etherscan.io"
        readonly property string goerliArbiscan: "https://goerli.arbiscan.io"
        readonly property string goerliOptimism: "https://goerli-optimism.etherscan.io"

        readonly property string sepoliaEtherscan: "https://sepolia.etherscan.io/"
        readonly property string sepoliaArbiscan: "https://sepolia.arbiscan.io/"
        readonly property string sepoliaOptimism: "https://sepolia-optimism.etherscan.io/"

        readonly property string addressPath: "address"
        readonly property string txPath: "tx"
    }

    readonly property QtObject openseaExplorerLinks: QtObject {
        readonly property string mainnetLink: "https://opensea.io"
        readonly property string testnetLink: "https://testnets.opensea.io"

        readonly property string ethereum: "ethereum"
        readonly property string arbitrum: "arbitrum"
        readonly property string optimism: "optimism"

        readonly property string goerliEthereum: "goerli"
        readonly property string goerliArbitrum: "arbitrum-goerli"
        readonly property string goerliOptimism: "optimism-goerli"

        readonly property string sepoliaEthereum: "sepolia"
        readonly property string sepoliaArbitrum: "arbitrum-sepolia"
        readonly property string sepoliaOptimism: "optimism-sepolia"
    }

    readonly property string api_request: "api-request"
    readonly property string web3SendAsyncReadOnly: "web3-send-async-read-only"
    readonly property string web3DisconnectAccount: "web3-disconnect-account"

    readonly property string permission_web3: "web3"
    readonly property string permission_contactCode: "contact-code"

    readonly property string personal_sign: "personal_sign"
    readonly property string eth_sign: "eth_sign"
    readonly property string eth_signTypedData: "eth_signTypedData"
    readonly property string eth_signTypedData_v3: "eth_signTypedData_v3"

    readonly property string waku_sandbox: "waku.sandbox"
    readonly property string waku_test: "waku.test"
    readonly property string status_prod: "status.prod"
    readonly property string status_staging: "status.staging"

    readonly property int repeatHeaderInterval: 2

    readonly property string deepLinkPrefix: 'status-app://'
    readonly property string externalStatusLink: 'status.app'
    readonly property string externalStatusLinkWithHttps: 'https://' + externalStatusLink
    readonly property string communityLinkPrefix: externalStatusLinkWithHttps + '/c/'
    readonly property string userLinkPrefix: externalStatusLinkWithHttps + '/u/'
    readonly property string statusLinkPrefix: 'https://status.im/'
    readonly property string statusHelpLinkPrefix: `https://status.app/help/`
    readonly property string downloadLink: "https://status.im/get"

    readonly property int maxUploadFiles: 5
    readonly property double maxUploadFilesizeMB: 10

    readonly property int maxNumberOfPins: 3

    readonly property string dataImagePrefix: "data:image"
    readonly property var acceptedDragNDropImageExtensions: [".png", ".jpg", ".jpeg"]

    readonly property string mentionSpanTag: `<span style="background-color: ${Style.current.mentionBgColor};"><a style="color:${Style.current.mentionColor};text-decoration:none" href='http://'>`

    readonly property string ens_taken: "taken"
    readonly property string ens_taken_custom: "taken-custom"
    readonly property string ens_owned: "owned"
    readonly property string ens_available: "available"
    readonly property string ens_already_connected: "already-connected"
    readonly property string ens_connected: "connected"
    readonly property string ens_connected_dkey: "connected-different-key"

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

    readonly property QtObject startupErrorType: QtObject {
        readonly property int unknownType: 0
        readonly property int importAccError: 1
        readonly property int setupAccError: 2
        readonly property int convertToRegularAccError: 3
    }

    readonly property string existingAccountError: "account already exists"
    readonly property string wrongDerivationPathError: "error parsing derivation path"

    readonly property int minPasswordLength: 10

    readonly property QtObject suggestedRoutesExtraParamsProperties: QtObject {
        readonly property string packId: "packID"
        readonly property string username: "username"
        readonly property string publicKey: "publicKey"
    }

    enum SendType {
        Transfer,
        ENSRegister,
        ENSRelease,
        ENSSetPubKey,
        StickersBuy,
        Bridge,
        ERC721Transfer,
        ERC1155Transfer,
        Swap,
        Approve,
        Unknown
    }

    enum ErrorType {
        SendAmountExceedsBalance,
        NoRoute,
        NoError
    }

    readonly property QtObject routerErrorCodes: QtObject {
        readonly property QtObject processor: QtObject {
            readonly property string errFailedToParseBaseFee           : "WPP-001"
            readonly property string errFailedToParsePercentageFee     : "WPP-002"
            readonly property string errContractNotFound               : "WPP-003"
            readonly property string errNetworkNotFound                : "WPP-004"
            readonly property string errTokenNotFound                  : "WPP-005"
            readonly property string errNoEstimationFound              : "WPP-006"
            readonly property string errNotAvailableForContractType    : "WPP-007"
            readonly property string errNoBonderFeeFound               : "WPP-008"
            readonly property string errContractTypeNotSupported       : "WPP-009"
            readonly property string errFromChainNotSupported          : "WPP-010"
            readonly property string errToChainNotSupported            : "WPP-011"
            readonly property string errTxForChainNotSupported         : "WPP-012"
            readonly property string errENSResolverNotFound            : "WPP-013"
            readonly property string errENSRegistrarNotFound           : "WPP-014"
            readonly property string errToAndFromTokensMustBeSet       : "WPP-015"
            readonly property string errCannotResolveTokens            : "WPP-016"
            readonly property string errPriceRouteNotFound             : "WPP-017"
            readonly property string errConvertingAmountToBigInt       : "WPP-018"
            readonly property string errNoChainSet                     : "WPP-019"
            readonly property string errNoTokenSet                     : "WPP-020"
            readonly property string errToTokenShouldNotBeSet          : "WPP-021"
            readonly property string errFromAndToChainsMustBeDifferent : "WPP-022"
            readonly property string errFromAndToChainsMustBeSame      : "WPP-023"
            readonly property string errFromAndToTokensMustBeDifferent : "WPP-024"
            readonly property string errTransferCustomError            : "WPP-025"
            readonly property string errERC721TransferCustomError      : "WPP-026"
            readonly property string errERC1155TransferCustomError     : "WPP-027"
            readonly property string errBridgeHopCustomError           : "WPP-028"
            readonly property string errBridgeCellerCustomError        : "WPP-029"
            readonly property string errSwapParaswapCustomError        : "WPP-030"
            readonly property string errENSRegisterCustomError         : "WPP-031"
            readonly property string errENSReleaseCustomError          : "WPP-032"
            readonly property string errENSPublicKeyCustomError        : "WPP-033"
            readonly property string errStickersBuyCustomError         : "WPP-034"
            readonly property string errContextCancelled               : "WPP-035"
            readonly property string errContextDeadlineExceeded        : "WPP-036"
            readonly property string errPriceTimeout                   : "WPP-037"
            readonly property string errNotEnoughLiquidity             : "WPP-038"
            readonly property string errPriceImpactTooHigh             : "WPP-039"
        }

        readonly property QtObject router: QtObject {
            readonly property string errENSRegisterRequiresUsernameAndPubKey      : "WR-001"
            readonly property string errENSRegisterTestnetSTTOnly                 : "WR-002"
            readonly property string errENSRegisterMainnetSNTOnly                 : "WR-003"
            readonly property string errENSReleaseRequiresUsername                : "WR-004"
            readonly property string errENSSetPubKeyRequiresUsernameAndPubKey     : "WR-005"
            readonly property string errStickersBuyRequiresPackID                 : "WR-006"
            readonly property string errSwapRequiresToTokenID                     : "WR-007"
            readonly property string errSwapTokenIDMustBeDifferent                : "WR-008"
            readonly property string errSwapAmountInAmountOutMustBeExclusive      : "WR-009"
            readonly property string errSwapAmountInMustBePositive                : "WR-010"
            readonly property string errSwapAmountOutMustBePositive               : "WR-011"
            readonly property string errLockedAmountNotSupportedForNetwork        : "WR-012"
            readonly property string errLockedAmountNotNegative                   : "WR-013"
            readonly property string errLockedAmountExceedsTotalSendAmount        : "WR-014"
            readonly property string errLockedAmountLessThanSendAmountAllNetworks : "WR-015"
            readonly property string errNotEnoughTokenBalance                     : "WR-016"
            readonly property string errNotEnoughNativeBalance                    : "WR-017"
            readonly property string errNativeTokenNotFound                       : "WR-018"
            readonly property string errDisabledChainFoundAmongLockedNetworks     : "WR-019"
            readonly property string errENSSetPubKeyInvalidUsername               : "WR-020"
            readonly property string errLockedAmountExcludesAllSupported          : "WR-021"
            readonly property string errTokenNotFound                             : "WR-022"
            readonly property string errNoBestRouteFound                          : "WR-023"
            readonly property string errCannotCheckReceiverBalance                : "WR-024"
            readonly property string errCannotCheckLockedAmounts                  : "WR-025"
            readonly property string errLowAmountInForHopBridge                   : "WR-026"
        }
    }

    enum LoginType {
        Password,
        Biometrics,
        Keycard
    }
    // Needs to match the enum above
    readonly property var authenticationIconByType: [
        "password",
        "touch-id",
        "keycard",
    ]

    enum ComputeFeeErrorCode {
        Success,
        Infura,
        Balance,
        Revert,
        Other
    }

    enum ShowcaseVisibility {
        NoOne = 0,
        IdVerifiedContacts = 1,
        Contacts = 2,
        Everyone = 3
    }

    enum ShowcaseEntryType {
        Community = 0,
        Account = 1,
        Collectible = 2,
        Asset = 3
    }

    // refers to ContractTransactionStatus and DeployState in Nim
    enum ContractTransactionStatus {
        Failed,
        InProgress,
        Completed,
        None
    }

    enum ContactRequestState {
        None = 0,
        Mutual = 1,
        Sent = 2,
        Received = 3,
        Dismissed = 4
    }

    // these are in sync with app_service/common/types.nim
    enum TokenType {
        Native = 0,
        ERC20 = 1, // Asset
        ERC721 = 2, // Collectible
        ERC1155 = 3,
        Unknown = 4,
        ENS = 5
    }

    enum TokenPrivilegesLevel {
        Owner = 0,
        TMaster = 1,
        Community = 2
    }

    // Mirrors src/backend/activity.nim ActivityStatus
    enum TransactionStatus {
        Failed,
        Pending,
        Complete,
        Finalised
    }

    // Mirrors src/backend/activity.nim ActivityType
    enum TransactionType {
        Send,
        Receive,
        Buy,
        Swap,
        Bridge,
        ContractDeployment,
        Mint,
        Approve,
        Sell,
        Destroy // TODO update value when added to backend
    }

    // To-do sync with backend
    enum TransactionTimePeriod {
        All,
        Today,
        Yesterday,
        ThisWeek,
        LastWeek,
        ThisMonth,
        LastMonth,
        Custom
    }

    readonly property QtObject time: QtObject {
        readonly property int hoursIn7Days: 168
        readonly property int hoursInDay: 24
        readonly property int secondsIn7Days: 604800
        readonly property int secondsInHour: 3600
    }

    readonly property QtObject walletSection: QtObject {
        readonly property string authenticationCanceled: "authenticationCanceled"
    }

    // list of symbols for which pngs are stored to avoid
    // accessing not existing resources and providing
    // default icon
    readonly property var knownTokenPNGs: [
        "aKNC", "AST", "BLT", "CND", "DNT", "EQUAD", "HEZ", "LOOM", "MTH",
        "PAY", "RCN", "SALT", "STRK", "TRST", "WBTC", "AKRO", "aSUSD", "BLZ",
        "COB", "DPY", "ETH2x-FLI", "HST", "LPT", "MTL", "PBTC", "RDN", "SAN",
        "STT", "TRX", "WETH", "0-native", "aLEND", "ATMChain", "BNB", "COMP",
        "DRT", "ETHOS", "HT", "LRC", "MYB", "PLR", "renBCH", "SNGLS", "STX",
        "TUSD", "WINGS", "0XBTC", "aLINK", "aTUSD", "BNT", "CUSTOM-TOKEN",
        "DTA", "ETH", "ICN", "MANA", "NEXO", "POE", "renBTC", "SNM", "SUB",
        "UBT", "WTC", "1ST", "aMANA", "aUSDC", "BQX", "CVC", "EDG", "EVX",
        "ICOS", "MCO", "NEXXO", "POLY", "REN", "SNT", "SUPR", "UKG", "XAUR",
        "aBAT", "AMB", "aUSDT", "BRLN", "DAI", "EDO", "FUEL", "IOST", "MDA",
        "NMR", "POWR", "renZEC", "SNX", "SUSD", "UNI", "XPA", "ABT", "aMKR",
        "aWBTC", "BTM", "DATA", "EKG", "FUN", "KDO", "MET", "NPXS", "PPP",
        "REP", "SOCKS", "TAAS", "UPP", "XRL", "aBUSD", "AMPL", "aYFI", "BTU",
        "DAT", "EKO", "FXC", "KIN", "MFG", "OGN", "PPT", "REQ", "SPANK",
        "TAUD", "USDC", "XUC", "ABYSS", "ANT", "aZRX", "CDAI", "DCN", "ELF",
        "GDC", "KNC", "MGO", "OMG", "PT", "RHOC", "SPIKE", "TCAD", "USDS",
        "ZRX", "aDAI", "APPC", "BAL", "CDT", "DEFAULT-TOKEN", "EMONA", "GEN",
        "Kudos", "MKR", "OST", "QKC", "RLC", "SPN", "TGBP", "USDT", "ZSC",
        "aENJ", "aREN", "BAM", "Centra", "DGD", "ENG", "GNO", "LEND", "MLN",
        "OTN", "QRL", "ROL", "STORJ", "TKN", "VERI", "AE", "aREP", "BAND",
        "CFI", "DGX", "ENJ", "GNT", "LINK", "MOC", "PAXG", "QSP", "R",
        "STORM", "TKX", "VIB", "aETH", "aSNX", "BAT", "CK", "DLT", "EOS",
        "GRID", "LISK", "MOD", "PAX", "RAE", "SAI", "ST", "TNT", "WABI",
        "EUROC"
    ]

    function tokenIcon(symbol, useDefault=true) {
        if (!!symbol && knownTokenPNGs.indexOf(symbol) !== -1)
            return Style.png("tokens/" + symbol)

        if (useDefault)
            return Style.png("tokens/DEFAULT-TOKEN")
        return ""
    }

    function isDefaultTokenIcon(url) {
        return url.indexOf("DEFAULT-TOKEN") !== -1
    }

    function getSupportedTokenSourceImage(name, useDefault=true) {
        if (name === supportedTokenSources.uniswap)
            return Style.png("tokens/UNI")

        if (name === supportedTokenSources.status)
            return Style.png("tokens/SNT")

        if (useDefault)
            return Style.png("tokens/DEFAULT-TOKEN")
        return ""
    }

    // Message outgoing status
    readonly property QtObject messageOutgoingStatus: QtObject {
        readonly property string sending: "sending"
        readonly property string sent: "sent"
        readonly property string delivered: "delivered"
        readonly property string expired: "expired"
        readonly property string failedResending: "failedResending"
    }

    readonly property QtObject appTranslatableConstants: QtObject {
        readonly property string loginAccountsListAddNewUser: "LOGIN-ACCOUNTS-LIST-ADD-NEW-USER"
        readonly property string loginAccountsListAddExistingUser: "LOGIN-ACCOUNTS-LIST-ADD-EXISTING-USER"
        readonly property string loginAccountsListLostKeycard: "LOGIN-ACCOUNTS-LIST-LOST-KEYCARD"
        readonly property string addAccountLabelNewWatchOnlyAccount: "LABEL-NEW-WATCH-ONLY-ACCOUNT"
        readonly property string addAccountLabelWatchOnlyAccount: "LABEL-WATCH-ONLY-ACCOUNT"
        readonly property string addAccountLabelExisting: "LABEL-EXISTING"
        readonly property string addAccountLabelImportNew: "LABEL-IMPORT-NEW"
        readonly property string addAccountLabelOptionAddNewMasterKey: "LABEL-OPTION-ADD-NEW-MASTER-KEY"
        readonly property string addAccountLabelOptionAddWatchOnlyAcc: "LABEL-OPTION-ADD-WATCH-ONLY-ACC"
        readonly property string keycardAccountNameOfUnknownWalletAccount: "KEYCARD-ACCOUNT-NAME-OF-UNKNOWN-WALLET-ACCOUNT"
    }

    enum CommunitySettingsSections {
        Overview,
        Members,
        Permissions,
        MintTokens,
        Airdrops
    }

    enum CommunityMembershipSubSections {
        Members,
        MembershipRequests,
        RejectedMembers,
        BannedMembers
    }

    enum CommunityMembershipRequestState {
        None = 0,
        Pending,
        Accepted,
        Rejected,
        AcceptedPending,
        RejectedPending,
        Banned,
        Kicked,
        BannedPending,
        UnbannedPending,
        KickedPending,
        AwaitingAddress,
        Unbanned,
        BannedWithAllMessagesDelete
    }

    readonly property QtObject walletAccountColors: QtObject {
        readonly property string primary: "primary"
        readonly property string purple: "purple"
        readonly property string orange: "orange"
        readonly property string army: "army"
        readonly property string turquoise: "turquoise"
        readonly property string sky: "sky"
        readonly property string yellow: "yellow"
        readonly property string pink: "pink"
        readonly property string copper: "copper"
        readonly property string camel: "camel"
        readonly property string magenta: "magenta"
        readonly property string yinYang: "yinYang"
        readonly property string undefinedAccount: "undefined"
    }

    enum MutingVariations {
        For15min = 1,
        For1hr = 2,
        For8hr = 3,
        For1week = 4,
        TillUnmuted = 5,
        For1min = 6,
        Unmuted = 7
    }

    enum LinkPreviewType {
        NoPreview = 0,
        Standard = 1,
        StatusContact = 2,
        StatusCommunity = 3,
        StatusCommunityChannel = 4
    }

    enum StandardLinkPreviewType {
        Link = 0,
        Image = 1
    }

    enum UrlUnfurlingMode {
        UrlUnfurlingModeAlwaysAsk = 1,
        UrlUnfurlingModeEnableAll = 2,
        UrlUnfurlingModeDisableAll = 3
    }

    // these are in sync with src/app/modules/shared_models/collectibles_nested_item.nim ItemType
    enum CollectiblesNestedItemType {
        CommunityCollectible = 0,
        NonCommunityCollectible = 1,
        Collection = 2,
        Community = 3
    }

    enum RequestToJoinState {
        None = 0,
        InProgress = 1,
        Requested = 2
    }

    enum CommunityMemberReevaluationStatus {
        None = 0,
        InProgress = 1,
        Done = 2
    }

    readonly property QtObject swap: QtObject {
        /* We should be very careful here, this is the token key for Status network token currently,
        but in case the logic for keys changes in the backend, it should be updated here as well */
        readonly property string testStatusTokenKey: "STT"
        readonly property string mainnetStatusTokenKey: "SNT"
        /* TODO: https://github.com/status-im/status-desktop/issues/15329
        This is only added temporarily until we have an api from the backend in order to get
        this list dynamically */
        readonly property string paraswapName: "Paraswap"
        readonly property string paraswapIcon: "paraswap"
        readonly property string paraswapHostname: "app.paraswap.io"
        readonly property string paraswapUrl: "https://www.paraswap.io/"
        readonly property string paraswapApproveContractAddress: "0x216B4B4Ba9F3e719726886d34a177484278Bfcae"
        readonly property string paraswapSwapContractAddress: "0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57"
        readonly property string paraswapTermsAndConditionUrl: "https://files.paraswap.io/tos_v4.pdf"

        // TOOD #15874: Unify with WalletUtils router error code handling
        readonly property QtObject errorCodes: QtObject {
            readonly property string errNotEnoughTokenBalance: "WR-016"
            readonly property string errNotEnoughNativeBalance: "WR-017"
            readonly property string errPriceTimeout: "WPP-037"
            readonly property string errNotEnoughLiquidity: "WPP-038"
            readonly property string errPriceImpactTooHigh: "WPP-039"
        }
    }

    // Mirrors src/app_service/service/transaction/service.nim -> EstimatedTime
    enum TransactionEstimatedTime {
        Unknown = 0,
        LessThanOneMin,
        LessThanThreeMins,
        LessThanFiveMins,
        MoreThanFiveMins
    }
}
