#include "StatusQ/keychain.h"

#include <QEventLoop>
#include <QDebug>
#include <QtConcurrent/QtConcurrent>
#include <QFuture>

#include <Security/Security.h>
#include <Foundation/Foundation.h>
#include <LocalAuthentication/LocalAuthentication.h>

const static auto authPolicy = LAPolicyDeviceOwnerAuthenticationWithBiometricsOrCompanion;

LAContext *authenticate(QString& reason) {
    auto *context = [[LAContext alloc] init];
    NSError *authError = nil;

    // Check if Biometrics Authentication is available
    if (![context canEvaluatePolicy:authPolicy error:&authError]) {
        qWarning() << "biometric authentication not available:"
                   << QString::fromNSString(authError.localizedDescription);
        return nil;
    }

    QEventLoop loop;
    auto loopPtr = &loop;
    __block NSError *callbackError = nil;
    __block BOOL success = NO;

    // Prompt for biometrics authentication
    [context evaluatePolicy:authPolicy
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
        return nil;
    }

    // Return authentication context
    return context;
}

void Keychain::requestSaveCredential(const QString &account, const QString &password) {
    if (m_future.isRunning()) {
        return;
    }

    m_future = QtConcurrent::run([this, account, password](){
        setLoading(true);
        auto ok = saveCredential(account, password);
        emit saveCredentialRequestCompleted(ok);
        setLoading(false);
    });
}

void Keychain::requestDeleteCredential(const QString &account) {
    if (m_future.isRunning()) {
        return;
    }

    m_future = QtConcurrent::run([this, account](){
        setLoading(true);
        auto ok = deleteCredential(account);
        emit deleteCredentialRequestCompleted(ok);
        setLoading(false);
    });
}

void Keychain::requestGetCredential(const QString &account)
{
    if (m_future.isRunning()) {
        return;
    }

    m_future = QtConcurrent::run([this, account](){
        setLoading(true);
        QString credential;
        auto ok = getCredential(account, &credential);
        emit getCredentialRequestCompleted(ok, credential);
        setLoading(false);
    });
}


bool Keychain::saveCredential(const QString &account, const QString &password) {
    LAContext *context = authenticate(m_reason);
    setLoading(false);

    if (!context) {
        return {};
    }

    CFErrorRef error = NULL;
    auto flags = kSecAccessControlBiometryCurrentSet | kSecAccessControlOr | kSecAccessControlWatch;
    auto accessControl = SecAccessControlCreateWithFlags(NULL,
                                                         kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                         flags,
                                                         &error);

    if (error) {
        qWarning() << "failed to create SecAccessControl:"
                   << QString::fromNSString((__bridge_transfer NSString *)CFErrorCopyDescription(error));
        CFRelease(error);
        return false;
    }

    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService: m_service.toNSString(),
                            (__bridge id)kSecAttrAccount: account.toNSString(),
                            (__bridge id)kSecValueData: [password.toNSString() dataUsingEncoding:NSUTF8StringEncoding],
                            //                            (__bridge id)kSecAttrAccessControl: (__bridge id)accessControl,
                            (__bridge id)kSecUseAuthenticationContext: context,
                            };

    SecItemDelete((__bridge CFDictionaryRef)query); // Ensure old item is removed
    auto status = SecItemAdd((__bridge CFDictionaryRef)query, NULL); // Add item

    CFRelease(accessControl);
    if (status == errSecSuccess) {
        return true;
    }

    qWarning() << "failed to save credential to keychain:" << status;
    return false;
}

bool Keychain::deleteCredential(const QString &account) {
    LAContext *context = authenticate(m_reason);

    if (!context) {
        return {};
    }

    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService: m_service.toNSString(),
                            (__bridge id)kSecAttrAccount: account.toNSString(),
                            (__bridge id)kSecUseAuthenticationContext: context,
                            };
    auto status = SecItemDelete((__bridge CFDictionaryRef)query);
    if (status == errSecSuccess) {
        return true;
    }

    qWarning() << "failed to delete credential from keychain:" << status;
    return false;
}


bool Keychain::getCredential(const QString &account, QString* out) {
    LAContext *context = authenticate(m_reason);

    if (!context) {
        return false;
    }

    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService: m_service.toNSString(),
                            (__bridge id)kSecAttrAccount: account.toNSString(),
                            (__bridge id)kSecReturnData: @YES,
                            (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne,
                            (__bridge id)kSecUseAuthenticationContext: context,
                            };

    CFDataRef data = NULL;
    __block QString result;

    auto status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&data);
    if (status != errSecSuccess)
        return false;


    auto dataString = [[NSString alloc] initWithData:(__bridge NSData *)data encoding:NSUTF8StringEncoding];
    result = QString::fromNSString(dataString);


    if (out != nullptr)
        *out = result;

    return true;
}
