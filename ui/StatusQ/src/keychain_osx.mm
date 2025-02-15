#include "StatusQ/keychain.h"

#include <QDebug>
#include <QEventLoop>
#include <QFuture>
#include <QtConcurrent/QtConcurrent>

#include <Foundation/Foundation.h>
#include <LocalAuthentication/LocalAuthentication.h>
#include <Security/Security.h>

const static auto authPolicy = LAPolicyDeviceOwnerAuthentication;

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
    default:
        return Keychain::StatusGenericError;
    }
}

Keychain::~Keychain()
{
    cancelActiveRequest();
    m_future.waitForFinished();
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
    NSError *authError = nil;

    // Check if Biometrics Authentication is available
    if (![*context canEvaluatePolicy:authPolicy error:&authError]) {
        qWarning() << "biometric authentication not available:"
                   << QString::fromNSString(authError.localizedDescription);
        return convertError(authError);
    }

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

void Keychain::requestSaveCredential(const QString &account, const QString &password)
{
    if (m_future.isRunning()) {
        return;
    }

    m_future = QtConcurrent::run([this, account, password]() {
        setLoading(true);
        const auto status = saveCredential(account, password);
        emit saveCredentialRequestCompleted(status);
        setLoading(false);
    });
}

void Keychain::requestDeleteCredential(const QString &account)
{
    if (m_future.isRunning()) {
        return;
    }

    m_future = QtConcurrent::run([this, account]() {
        setLoading(true);
        const auto status = deleteCredential(account);
        emit deleteCredentialRequestCompleted(status);
        setLoading(false);
    });
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

void Keychain::requestHasCredential(const QString &account)
{
    if (m_future.isRunning()) {
        return;
    }

    m_future = QtConcurrent::run([this, account]() {
        setLoading(true);
        const auto status = hasCredential(account);
        emit hasCredentialRequestCompleted(status);
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
    if (status != errSecSuccess) {
        qWarning() << "failed to save credential to keychain:" << status;
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
    if (status != errSecSuccess) {
        qWarning() << "failed to delete credential from keychain:" << status;
    }

    return convertStatus(status);
}

Keychain::Status Keychain::getCredential(const QString &reason, const QString &account, QString *out)
{
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

Keychain::Status Keychain::hasCredential(const QString &account)
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
