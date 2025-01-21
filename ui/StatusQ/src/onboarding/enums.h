#include <QDebug>
#include <QJsonArray>
#include <QJsonObject>
#include <QMetaEnum>
#include <QObject>

class OnboardingEnums: public QObject
{
    Q_OBJECT
    Q_CLASSINFO("RegisterEnumClassesUnscoped", "false")

public:
    Q_INVOKABLE QJsonArray getModelFromEnum(const QString &name) const {
        if (name.isEmpty())
            return {};

        QMetaEnum e = staticMetaObject.enumerator(staticMetaObject.indexOfEnumerator(name.toLatin1().constData()));
        if (!e.isValid())
            return {};

        QJsonArray result;
        for (int i = 0; i < e.keyCount(); ++i) {
            result.append(
                {{{QStringLiteral("name"), e.key(i)}, {QStringLiteral("value"), e.value(i)}}});
        }

        return result;
    }

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
        BlockedPIN, // PIN remaining attempts == 0
        BlockedPUK, // PUK remaining attempts == 0
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
