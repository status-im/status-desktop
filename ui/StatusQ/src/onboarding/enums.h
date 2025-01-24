#include <QObject>

class OnboardingEnums
{
    Q_GADGET
    Q_CLASSINFO("RegisterEnumClassesUnscoped", "false")
public:
    enum class PrimaryFlow {
        Unknown,
        CreateProfile,
        Login
    };

    enum class SecondaryFlow {
        Unknown,

        CreateProfileWithPassword,
        CreateProfileWithSeedphrase,
        CreateProfileWithKeycard,
        CreateProfileWithKeycardNewSeedphrase,
        CreateProfileWithKeycardExistingSeedphrase,

        LoginWithSeedphrase,
        LoginWithSyncing,
        LoginWithKeycard,

        LoginWithLostKeycardSeedphrase,
        LoginWithRestoredKeycard
    };

    enum class LoginMethod {
        Password,
        Keycard,
    };

    enum class KeycardState {
        NoPCSCService,
        PluginReader,
        InsertKeycard,
        ReadingKeycard,
        // error states
        WrongKeycard,
        NotKeycard,
        MaxPairingSlotsReached,
        Locked,
        // exit states
        NotEmpty,
        Empty
    };

    enum class AddKeyPairState {
        InProgress,
        Success,
        Failed
    };

    enum class SyncState {
        Idle,
        InProgress,
        Failed,
        Success
    };

private:
    Q_ENUM(PrimaryFlow)
    Q_ENUM(SecondaryFlow)
    Q_ENUM(LoginMethod)
    Q_ENUM(KeycardState)
    Q_ENUM(AddKeyPairState)
    Q_ENUM(SyncState)
};
