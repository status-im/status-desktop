#include "StatusQ/keychain.h"

#include <QDebug>
#include <QEventLoop>
#include <QFuture>
#include <QGuiApplication>
#include <QtConcurrent/QtConcurrent>

#include <Foundation/Foundation.h>
#include <LocalAuthentication/LocalAuthentication.h>
#include <Security/Security.h>

const static auto authPolicy =
#if defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 150000
    LAPolicyDeviceOwnerAuthenticationWithBiometricsOrCompanion;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 101202
    LAPolicyDeviceOwnerAuthenticationWithBiometrics;
#else
    LAPolicyDeviceOwnerAuthentication;
#endif

static Keychain::Status convertStatus(OSStatus status)
{
    switch (status) {
    case errSecSuccess:
        return Keychain::StatusSuccess;
    case errSecItemNotFound:
        return Keychain::StatusNotFound;
    case errSecCSCancelled:
        return Keychain::StatusCancelled;
    default:
        return Keychain::StatusGenericError;
    }
}

Keychain::Status convertError(NSError *error)
{
    switch (error.code) {
    case errSecSuccess:
        return Keychain::StatusSuccess;
    case LAErrorSystemCancel:
    case LAErrorUserCancel:
    case LAErrorAppCancel:
        return Keychain::StatusCancelled;
    case LAErrorUserFallback:
        return Keychain::StatusFallbackSelected;
    default:
        return Keychain::StatusGenericError;
    }
}

Keychain::Keychain(QObject *parent)
    : QObject(parent)
{
    reevaluateAvailability();

    connect(qApp,
            &QGuiApplication::applicationStateChanged,
            this,
            [this](Qt::ApplicationState state) {
                if (state == Qt::ApplicationActive) {
                    reevaluateAvailability();
                }
            });
}

Keychain::~Keychain()
{
    cancelActiveRequest();
    m_future.waitForFinished();
}

bool Keychain::available() const
{
    return m_available;
}

Keychain::Status authenticate(const QString &reason, LAContext **context)
{
    if (context == nullptr)
        return Keychain::StatusGenericError;

    if (*context != nullptr) {
        qWarning() << "another local authentication request in progress";
        return Keychain::StatusGenericError;
    }

    *context = [[LAContext alloc] init];
    (*context).localizedFallbackTitle = QObject::tr("Use Status profile password").toNSString();

    QEventLoop loop;
    auto loopPtr = &loop;
    __block NSError *callbackError = nil;
    __block BOOL success = NO;

    // Prompt for biometrics authentication
    [*context evaluatePolicy:authPolicy
             localizedReason:reason.toNSString()
                       reply:^(BOOL authSuccess, NSError *error) {
                           success = authSuccess;
                           callbackError = error ? [error copy] : nil;
                           loopPtr->quit();
                       }];

    // Wait for biometrics authentication finished
    loop.exec();

    if (!success && callbackError) {
        qWarning() << "authentication failed:"
                   << QString::fromNSString(callbackError.localizedDescription);
        return convertError(callbackError);
    }

    return Keychain::StatusSuccess;
}

void Keychain::requestGetCredential(const QString &reason, const QString &account)
{
    if (m_future.isRunning()) {
        return;
    }

    m_future = QtConcurrent::run([this, reason, account]() {
        setLoading(true);
        QString credential;
        const auto status = getCredential(reason, account, &credential);
        emit getCredentialRequestCompleted(status, credential);
        setLoading(false);
    });
}

void Keychain::cancelActiveRequest()
{
    if (m_activeAuthContext != nullptr)
        [m_activeAuthContext invalidate];
}

Keychain::Status Keychain::saveCredential(const QString &account, const QString &password)
{
    CFErrorRef error = NULL;
    auto flags = kSecAccessControlBiometryCurrentSet | kSecAccessControlOr | kSecAccessControlWatch;
    auto accessControl = SecAccessControlCreateWithFlags(NULL,
                                                         kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                         flags,
                                                         &error);

    if (error) {
        qWarning() << "failed to create SecAccessControl:"
                   << QString::fromNSString(
                          (__bridge_transfer NSString *) CFErrorCopyDescription(error));
        CFRelease(error);
        return StatusGenericError;
    }

    NSDictionary *query = @{
        (__bridge id) kSecClass: (__bridge id) kSecClassGenericPassword,
        (__bridge id) kSecAttrService: m_service.toNSString(),
        (__bridge id) kSecAttrAccount: account.toNSString(),
        (__bridge id) kSecValueData: [password.toNSString() dataUsingEncoding:NSUTF8StringEncoding],
        //                            (__bridge id)kSecAttrAccessControl: (__bridge id)accessControl,
    };

    SecItemDelete((__bridge CFDictionaryRef) query);                  // Ensure old item is removed
    auto status = SecItemAdd((__bridge CFDictionaryRef) query, NULL); // Add item

    CFRelease(accessControl);
    if (status == errSecSuccess) {
        emit credentialSaved(account);
    }

    return convertStatus(status);
}

Keychain::Status Keychain::deleteCredential(const QString &account)
{
    NSDictionary *query = @{
        (__bridge id) kSecClass: (__bridge id) kSecClassGenericPassword,
        (__bridge id) kSecAttrService: m_service.toNSString(),
        (__bridge id) kSecAttrAccount: account.toNSString(),
    };
    const auto status = SecItemDelete((__bridge CFDictionaryRef) query);
    if (status == errSecSuccess) {
        emit credentialDeleted(account);
    }

    return convertStatus(status);
}

Keychain::Status Keychain::getCredential(const QString &reason, const QString &account, QString *out)
{
    if (!m_available) {
        return StatusUnavailable;
    }

    QScopedValueRollback<LAContext *> roolback(m_activeAuthContext, nullptr);
    const auto authStatus = authenticate(reason, &m_activeAuthContext);

    if (authStatus != StatusSuccess) {
        return authStatus;
    }

    NSDictionary *query = @{
        (__bridge id) kSecClass: (__bridge id) kSecClassGenericPassword,
        (__bridge id) kSecAttrService: m_service.toNSString(),
        (__bridge id) kSecAttrAccount: account.toNSString(),
        (__bridge id) kSecReturnData: @YES,
        (__bridge id) kSecMatchLimit: (__bridge id) kSecMatchLimitOne,
        (__bridge id) kSecUseAuthenticationContext: m_activeAuthContext,
    };

    CFDataRef data = NULL;

    const auto status = SecItemCopyMatching((__bridge CFDictionaryRef) query, (CFTypeRef *) &data);

    if (out != nullptr) {
        auto dataString = [[NSString alloc] initWithData:(__bridge NSData *) data
                                                encoding:NSUTF8StringEncoding];
        *out = QString::fromNSString(dataString);
    }

    return convertStatus(status);
}

void Keychain::reevaluateAvailability()
{
    auto context = [[LAContext alloc] init];
    NSError *authError = nil;

    const auto available = [context canEvaluatePolicy:authPolicy error:&authError];

    // Later this description can be used if needed:
    // const auto description = QString::fromNSString(authError.localizedDescription);

    if (m_available == available) {
        return;
    }

    m_available = available;
    emit availableChanged();
}

Keychain::Status Keychain::hasCredential(const QString &account) const
{
    NSDictionary *query = @{
        (__bridge id) kSecClass: (__bridge id) kSecClassGenericPassword,
        (__bridge id) kSecAttrService: m_service.toNSString(),
        (__bridge id) kSecAttrAccount: account.toNSString(),
        (__bridge id) kSecReturnData: @NO,
        (__bridge id) kSecReturnAttributes: @YES,
        (__bridge id) kSecMatchLimit: (__bridge id) kSecMatchLimitOne,
    };

    const auto status = SecItemCopyMatching((__bridge CFDictionaryRef) query, nil);
    return convertStatus(status);
}

Keychain::Status Keychain::updateCredential(const QString &account, const QString &password)
{
    const auto status = hasCredential(account);

    if (status == Status::StatusNotFound) {
        return Status::StatusSuccess;
    }

    if (status != Status::StatusSuccess) {
        return status;
    }

    return saveCredential(account, password);
}
