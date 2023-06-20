pragma Singleton

import QtQuick 2.13

import StatusQ.Controls.Validators 0.1
import StatusQ.Core.Theme 0.1

QtObject {

    readonly property QtObject appState: QtObject {
        readonly property int startup: 0
        readonly property int appLoading: 1
        readonly property int main: 2
        readonly property int appEncryptionProcess: 3
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
    }

    readonly property QtObject keycardSharedState: QtObject {
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
        property int syncingSettings: 8
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
        readonly property int manageUsers: 2
        readonly property int moderateContent: 3
        readonly property int admin: 4
    }

    readonly property QtObject permissionType: QtObject{
        readonly property int none: 0
        readonly property int admin: 1
        readonly property int member: 2
        readonly property int read: 3
        readonly property int viewAndPost: 4
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

    readonly property QtObject validators: QtObject {
        readonly property list<StatusValidator> displayName: [
            StatusValidator {
                name: "startsWithSpaceValidator"
                validate: function (t) { return !t.startsWith(" ") }
                errorMessage: qsTr("Usernames starting with whitespace are not allowed")
            },
            StatusRegularExpressionValidator {
                regularExpression: /^[a-zA-Z0-9\-_ ]+$/
                errorMessage: qsTr("Only letters, numbers, underscores, whitespaces and hyphens allowed")
            },
            StatusMinLengthValidator {
                minLength: 5
                errorMessage: qsTr("Username must be at least 5 characters")
            },
            StatusValidator {
                name: "endsWithSpaceValidator"
                validate: function (t) { return !t.endsWith(" ") }
                errorMessage: qsTr("Usernames ending with whitespace are not allowed")
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

        property string dotSepString: '<font size="3">  &#x2022; </font>'
    }

    readonly property QtObject ephemeralNotificationType: QtObject {
        readonly property int normal: 0
        readonly property int success: 1
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
            readonly property int popupHeight: 500
            readonly property int popupBiggerHeight: 626
            readonly property int titleHeight: 44
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
            readonly property int watchOnly: 3
        }

        readonly property QtObject shared: QtObject {
            readonly property int imageWidth: 240
            readonly property int imageHeight: 240
        }
    }

    readonly property QtObject regularExpressions: QtObject {
        readonly property var alphanumerical: /^$|^[a-zA-Z0-9]+$/
        readonly property var alphanumericalExpanded: /^$|^[a-zA-Z0-9\-_ ]+$/
        readonly property var alphanumericalWithSpace: /^$|^[a-zA-Z0-9\s]+$/
        readonly property var asciiPrintable:         /^$|^[!-~]+$/
        readonly property var ascii:                  /^$|^[\x00-\x7F]+$/
        readonly property var capitalOnly: /^$|^[A-Z]+$/
        readonly property var numerical: /^$|^[0-9]+$/
    }

    readonly property QtObject errorMessages: QtObject {
        readonly property string alphanumericalRegExp: qsTr("Only letters and numbers allowed")
        readonly property string alphanumericalWithSpaceRegExp: qsTr("Special characters are not allowed")
        readonly property string alphanumericalExpandedRegExp: qsTr("Only letters, numbers, underscores, whitespaces and hyphens allowed")
        readonly property string asciiRegExp: qsTr("Only letters, numbers and ASCII characters allowed")
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

    readonly property int maxNumOfSocialLinks: 20
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

    readonly property QtObject localPairingAction: QtObject {
        readonly property int actionUnknown: 0
        readonly property int actionConnect: 1
        readonly property int actionPairingAccount: 2
        readonly property int actionSyncDevice: 3
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

    readonly property QtObject networkShortChainNames: QtObject {
        readonly property string mainnet: "eth"
        readonly property string arbiscan: "arb"
        readonly property string optimism: "opt"
        readonly property string goerliMainnet: "goEth"
        readonly property string goerliArbiscan: "goArb"
        readonly property string goerliOptimism: "goOpt"
    }

    readonly property QtObject networkExplorerLinks: QtObject {
        readonly property string etherscan: "https://etherscan.io"
        readonly property string arbiscan: "https://arbiscan.io"
        readonly property string optimistic: "https://optimistic.etherscan.io"
        readonly property string goerliEtherscan: "https://goerli.etherscan.io"
        readonly property string goerliArbiscan: "https://goerli.arbiscan.io"
        readonly property string goerliOptimistic: "https://goerli-optimism.etherscan.io"
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

    readonly property string eth_prod: "eth.prod"
    readonly property string eth_staging: "eth.staging"
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

    readonly property string deepLinkPrefix: 'status-app://'
    readonly property string externalStatusLink: 'status.app'
    readonly property string externalStatusLinkWithHttps: 'https://' + externalStatusLink
    readonly property string communityLinkPrefix: externalStatusLinkWithHttps + '/c/'
    readonly property string userLinkPrefix: externalStatusLinkWithHttps + '/u/'
    readonly property string statusLinkPrefix: 'https://status.im/'
    readonly property string statusHelpLinkPrefix: `https://help.status.im/`

    readonly property int maxUploadFiles: 5
    readonly property double maxUploadFilesizeMB: 10

    readonly property int maxNumberOfPins: 3

    readonly property string dataImagePrefix: "data:image"
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

    enum SendType {
        Transfer,
        ENSRegister,
        ENSRelease,
        ENSSetPubKey,
        StickersBuy,
        Bridge
    }

    enum ErrorType {
        SendAmountExceedsBalance,
        NoRoute,
        NoError
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
        Other
    }

    enum ShowcaseVisibility {
        NoOne = 0,
        IdVerifiedContacts = 1,
        Contacts = 2,
        Everyone = 4
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


    enum TokenType {
        Unknown = 0,
        ERC20 = 1, // Asset
        ERC721 = 2 // Collectible
    }

    // Mirrors src/backend/activity.nim ActivityStatus
    enum TransactionStatus {
        Failed,
        Pending,
        Complete,
        Finished
    }

    // Mirrors src/backend/activity.nim ActivityType
    enum TransactionType {
        Send,
        Receive,
        Buy,
        Swap,
        Bridge,
        Sell, // TODO update value when added to backend
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

    readonly property QtObject walletSection: QtObject {
        readonly property string cancelledMessage: "cancelled"
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
        "GRID", "LISK", "MOD", "PAX", "RAE", "SAI", "ST", "TNT", "WABI"
    ]

    function tokenIcon(symbol) {
        if (!!symbol && knownTokenPNGs.indexOf(symbol) !== -1)
            return Style.png("tokens/" + symbol)

        return Style.png("tokens/DEFAULT-TOKEN")
    }

    // Message outgoing status
    readonly property string sending: "sending"
    readonly property string sent: "sent"
    readonly property string delivered: "delivered"
    readonly property string expired: "expired"
    readonly property string failedResending: "failedResending"

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
}
