import QtQuick 2.15

QtObject {
    property QtObject privacyModule: QtObject {
        signal passwordChanged(success: bool, errorMsg: string)
        signal storeToKeychainError(errorDescription: string)
        signal storeToKeychainSuccess()
    }

    function tryStoreToKeyChain(errorDescription) {
        if (generateMacKeyChainStoreError.checked) {
            privacyModule.storeToKeychainError(errorDescription)
        } else {
            passwordView.localAccountSettings.storeToKeychainValue = Constants.keychain.storedValue.store
            privacyModule.storeToKeychainSuccess()
            privacyModule.passwordChanged(true, "")
        }
    }

    function tryRemoveFromKeyChain() {
        if (generateMacKeyChainStoreError.checked) {
            privacyModule.storeToKeychainError("Error removing from keychain")
        } else {
            passwordView.localAccountSettings.storeToKeychainValue = Constants.keychain.storedValue.notNow
            privacyModule.storeToKeychainSuccess()
        }
    }
}
