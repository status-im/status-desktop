#include "DOtherSide/Status/Keychain.h"

#import <Foundation/Foundation.h>
#import <Security/Security.h>

using namespace Status;

struct ErrorDescription
{
    Keychain::Error code;
    QString message;

    ErrorDescription(Keychain::Error code, const QString &message)
        : code(code)
        , message(message) 
    {}

    static ErrorDescription fromStatus(OSStatus status)
    {
        switch(status) {
        case errSecSuccess:
            return ErrorDescription(Keychain::NoError, 
            "No error");
        case errSecItemNotFound:
            return ErrorDescription(Keychain::EntryNotFound, 
            "The specified item could not be found in the keychain");
        case errSecUserCanceled:
            return ErrorDescription(Keychain::AccessDeniedByUser, 
            "User canceled the operation");
        case errSecInteractionNotAllowed:
            return ErrorDescription(Keychain::AccessDenied, 
            "User interaction is not allowed");
        case errSecNotAvailable:
            return ErrorDescription(Keychain::AccessDenied, 
            "No keychain is available. You may need to restart your computer");
        case errSecAuthFailed:
            return ErrorDescription(Keychain::AccessDenied, 
            "The user name or passphrase you entered is not correct");
        case errSecVerifyFailed:
            return ErrorDescription(Keychain::AccessDenied, 
            "A cryptographic verification failure has occurred");
        case errSecUnimplemented:
            return ErrorDescription(Keychain::NotImplemented, 
            "Function or operation not implemented");
        case errSecIO:
            return ErrorDescription(Keychain::OtherError, 
            "I/O error");
        case errSecOpWr:
            return ErrorDescription(Keychain::OtherError, 
            "Already open with with write permission");
        case errSecParam:
            return ErrorDescription(Keychain::OtherError, 
            "Invalid parameters passed to a function");
        case errSecAllocate:
            return ErrorDescription(Keychain::OtherError, 
            "Failed to allocate memory");
        case errSecBadReq:
            return ErrorDescription(Keychain::OtherError, 
            "Bad parameter or invalid state for operation");
        case errSecInternalComponent:
            return ErrorDescription(Keychain::OtherError, 
            "An internal component failed");
        case errSecDuplicateItem:
            return ErrorDescription(Keychain::OtherError, 
            "The specified item already exists in the keychain");
        case errSecDecode:
            return ErrorDescription(Keychain::OtherError, 
            "Unable to decode the provided data");
        }

        return ErrorDescription(Keychain::OtherError, "Unknown error");
    }
};

Keychain::Keychain(const QString& service, QObject *parent)
    : QObject(parent)
    , m_service(service)
{}

void Keychain::readItem(const QString& key)
{
    NSDictionary *const query = @{
        (__bridge id) kSecClass: (__bridge id) kSecClassGenericPassword,
            (__bridge id) kSecAttrService: (__bridge NSString *) m_service.toCFString(),
            (__bridge id) kSecAttrAccount: (__bridge NSString *) key.toCFString(),
            (__bridge id) kSecReturnData: @YES,
    };

    CFTypeRef dataRef = nil;
    const OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) query, &dataRef);

    if (status == errSecSuccess) {
        QByteArray data;
        if (dataRef)
            data = QByteArray::fromCFData((CFDataRef) dataRef);

        emit success(QString::fromUtf8(data));
    } else {
        const ErrorDescription ed = ErrorDescription::fromStatus(status);
        emit error(ed.code, 
        QString("Could not retrieve private key from keystore: %1").arg(ed.message));
    }

    if (dataRef)
        [dataRef release];
}

void Keychain::writeItem(const QString& key, const QString& data)
{
    NSDictionary *const query = @{
            (__bridge id) kSecClass: (__bridge id) kSecClassGenericPassword,
            (__bridge id) kSecAttrService: (__bridge NSString *) m_service.toCFString(),
            (__bridge id) kSecAttrAccount: (__bridge NSString *) key.toCFString(),
    };

    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) query, nil);

    QByteArray baData = data.toUtf8();
    if (status == errSecSuccess) {
        NSDictionary *const update = @{
                (__bridge id) kSecValueData: (__bridge NSData *) baData.toCFData(),
        };

        status = SecItemUpdate((__bridge CFDictionaryRef) query, (__bridge CFDictionaryRef) update);
    } else {
        NSDictionary *const insert = @{
                (__bridge id) kSecClass: (__bridge id) kSecClassGenericPassword,
                (__bridge id) kSecAttrService: (__bridge NSString *) m_service.toCFString(),
                (__bridge id) kSecAttrAccount: (__bridge NSString *) key.toCFString(),
                (__bridge id) kSecValueData: (__bridge NSData *) baData.toCFData(),
        };

        status = SecItemAdd((__bridge CFDictionaryRef) insert, nil);
    }

    if (status == errSecSuccess) {
        emit success(QString());
    } else {
        const ErrorDescription ed = ErrorDescription::fromStatus(status);
        emit error(ed.code, 
        QString("Could not store data in settings: %1").arg(ed.message));
    }
}

void Keychain::deleteItem(const QString& key)
{
    const NSDictionary *const query = @{
            (__bridge id) kSecClass: (__bridge id) kSecClassGenericPassword,
            (__bridge id) kSecAttrService: (__bridge NSString *) m_service.toCFString(),
            (__bridge id) kSecAttrAccount: (__bridge NSString *) key.toCFString(),
    };

    const OSStatus status = SecItemDelete((__bridge CFDictionaryRef) query);

    if (status == errSecSuccess) {
        emit success(QString());
    } else {
        const ErrorDescription ed = ErrorDescription::fromStatus(status);
        emit error(ed.code, 
        QString("Could not remove private key from keystore: %1").arg(ed.message));
    }
}