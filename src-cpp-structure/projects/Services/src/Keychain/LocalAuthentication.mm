#include "LocalAuthentication.h"

#include <AvailabilityMacros.h>
#import <LocalAuthentication/LocalAuthentication.h>

using namespace Status::Keychain;

struct ErrorDescription
{
    LocalAuthentication::Error code;
    QString message;

    ErrorDescription(LocalAuthentication::Error code, const QString &message)
        : code(code) 
        , message(message) 
    {}

    static ErrorDescription fromLAError(NSInteger err)
    {
        NSProcessInfo *pInfo = [NSProcessInfo processInfo];
        NSOperatingSystemVersion info = [pInfo operatingSystemVersion];

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
#if defined MAC_OS_VERSION_11_2 \
    && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_VERSION_11_2
        switch(err) {
        case LAErrorBiometryDisconnected: /* MacOs 11.2+ */
            return ErrorDescription(LocalAuthentication::OtherError, 
            "The device supports biometry only using a removable accessory, but the paired accessory isn’t connected");
        case LAErrorBiometryNotPaired: /* MacOs 11.2+ */
            return ErrorDescription(LocalAuthentication::OtherError, 
            "The device supports biometry only using a removable accessory, but no accessory is paired");
        }
#endif

#if defined MAC_OS_X_VERSION_10_15 \
    && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_15
        switch(err) {
        case LAErrorWatchNotAvailable: /* MacOs 10.15+ */
            return ErrorDescription(LocalAuthentication::OtherError, 
            "An attempt to authenticate with Apple Watch failed");
        }
#endif
        
#if defined MAC_OS_X_VERSION_10_13 \
    && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_13
        switch(err) {
        case LAErrorBiometryLockout: /* MacOs 10.13+ */
            return ErrorDescription(LocalAuthentication::OtherError, 
            "Biometry is locked because there were too many failed attempts");
        case LAErrorBiometryNotAvailable: /* MacOs 10.13+ */
            return ErrorDescription(LocalAuthentication::TouchIdNotAvailable, 
            "Biometry is not available on the device");
        case LAErrorBiometryNotEnrolled: /* MacOs 10.13+ */
            return ErrorDescription(LocalAuthentication::TouchIdNotConfigured, 
            "The user has no enrolled biometric identities");
        }
#endif
        
#if defined MAC_OS_X_VERSION_10_11 \
    && defined MAC_OS_X_VERSION_10_13 \
    && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_11 \
    && MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_13
        switch(err) {
        case LAErrorTouchIDLockout: /* MacOs 10.11 - 10.13 */
            return ErrorDescription(LocalAuthentication::OtherError, 
            "Touch ID is locked because there were too many failed attempts");
        }
#endif

#if defined MAC_OS_X_VERSION_10_10 \
    && defined MAC_OS_X_VERSION_10_13 \
    && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_10 \
    && MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_13
        switch(err) {
        case LAErrorTouchIDNotAvailable: /* MacOs 10.10 - 10.13 */
            return ErrorDescription(LocalAuthentication::TouchIdNotAvailable, 
            "Touch ID is not available on the device");
        case LAErrorTouchIDNotEnrolled: /* MacOs 10.10 - 10.13 */
            return ErrorDescription(LocalAuthentication::TouchIdNotConfigured, 
            "The user has no enrolled Touch ID fingers");
        }
#endif
        
#if defined MAC_OS_X_VERSION_10_11 \
    && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_11
        switch(err) {
            case LAErrorInvalidContext: /* MacOs 10.11+ */
            return ErrorDescription(LocalAuthentication::OtherError, 
            "The context was previously invalidated");
        }
#endif
        
#if defined MAC_OS_X_VERSION_10_10 \
    && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_10
        switch(err) {
        case LAErrorSystemCancel: /* MacOs 10.10+ */
            return ErrorDescription(LocalAuthentication::SystemCanceled, 
            "The system canceled authentication");
        case LAErrorUserCancel: /* MacOs 10.10+ */
            return ErrorDescription(LocalAuthentication::UserCanceled, 
            "The user tapped the cancel button in the authentication dialog");
        case LAErrorAuthenticationFailed: /* MacOs 10.10+ */
            return ErrorDescription(LocalAuthentication::WrongCredentials, 
            "The user failed to provide valid credentials");
        case LAErrorNotInteractive: /* MacOs 10.10+ */
            return ErrorDescription(LocalAuthentication::OtherError, 
            "Displaying the required authentication user interface is forbidden");
        case LAErrorPasscodeNotSet: /* MacOs 10.10+ */
            return ErrorDescription(LocalAuthentication::OtherError, 
            "A passcode isn’t set on the device");
        case LAErrorUserFallback: /* MacOs 10.10+ */
            return ErrorDescription(LocalAuthentication::OtherError, 
            "The user tapped the fallback button in the authentication dialog, but no fallback is available for the authentication policy");
        }
#endif

#endif

        return ErrorDescription(LocalAuthentication::OtherError, "Unknown error");
    }
};

void LocalAuthentication::runAuthentication(const QString& authenticationReason)
{
    LAContext *laContext = [[LAContext alloc] init];
    NSError *authError = nil;
    NSString *localizedReasonString = authenticationReason.toNSString();

    if ([laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&authError]) 
    {
        [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication
                    localizedReason:localizedReasonString
                    reply:^(BOOL authenticated, NSError *err) 
                    {
                if (authenticated) 
                {
                    emit success();
                } 
                else 
                {
                    const ErrorDescription ed = ErrorDescription::fromLAError([err code]);
                    emit error(ed.code, QString("User did not authenticate successfully: %1").arg(ed.message));
                }
            }];
    } 
    else 
    {
        const ErrorDescription ed = ErrorDescription::fromLAError([authError code]);
        emit error(ed.code, QString("Could not evaluate policy: %1").arg(ed.message));
    }
}
