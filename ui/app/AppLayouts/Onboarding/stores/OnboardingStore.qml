pragma Singleton

import QtQuick 2.13
import utils 1.0

QtObject {
    id: root
    property var profileSectionModuleInst: profileSectionModule
    property var profileModule:  profileSectionModuleInst.profileModule
    property var onboardingModuleInst: onboardingModule
    property var mainModuleInst: !!mainModule ? mainModule : undefined
    property var accountSettings: localAccountSettings
    property var privacyModule: profileSectionModuleInst.privacyModule
    property string displayName: userProfile !== undefined ? userProfile.displayName : ""

    property url profImgUrl: ""
    property real profImgAX: 0.0
    property real profImgAY: 0.0
    property real profImgBX: 0.0
    property real profImgBY: 0.0
    property bool accountCreated: false

    property bool showBeforeGetStartedPopup: true

    function generateImage(source, aX, aY, bX, bY) {
        profImgUrl = source
        profImgAX = aX
        profImgAY = aY
        profImgBX = bX
        profImgBY = bY
        return onboardingModuleInst.generateImage(source, aX, aY, bX, bY)
    }

    function importMnemonic(mnemonic) {
        onboardingModuleInst.importMnemonic(mnemonic)
    }

    function setCurrentAccountAndDisplayName(displayName) {
        onboardingModuleInst.setDisplayName(displayName);
        if (!onboardingModuleInst.importedAccountPubKey) {
            onboardingModuleInst.setSelectedAccountByIndex(0);
        }
    }

    function updatedDisplayName(displayName) {
        if (displayName !== root.displayName) {
            print(displayName, root.displayName)
            root.profileModule.setDisplayName(displayName);
        }
    }

    function saveImage() {
        root.profileModule.upload(root.profImgUrl, root.profImgAX, root.profImgAY, root.profImgBX, root.profImgBY);
    }

    function setImageProps(source, aX, aY, bX, bY) {
        root.profImgUrl = source;
        root.profImgAX = aX;
        root.profImgAY = aY;
        root.profImgBX = bX;
        root.profImgBY = bY;
    }

    function clearImageProps() {
        root.profImgUrl = "";
        root.profImgAX = 0.0;
        root.profImgAY = 0.0;
        root.profImgBX = 0.0;
        root.profImgBY = 0.0;
    }

    function removeImage() {
        return root.profileModule.remove();
    }

    function finishCreatingAccount(pass) {
        root.onboardingModuleInst.storeSelectedAccountAndLogin(pass);
    }

    function storeToKeyChain(pass) {
        mainModule.storePassword(pass);
    }

    function changePassword(password, newPassword) {
        root.privacyModule.changePassword(password, newPassword);
    }

    function validateMnemonic(text) {
        return root.onboardingModuleInst.validateMnemonic(text);
    }

    property ListModel accountsSampleData: ListModel {
        ListElement {
            username: "Ferocious Herringbone Sinewave2"
            address: "0x123456789009876543211234567890"
        }
        ListElement {
            username: "Another Account"
            address: "0x123456789009876543211234567890"
        }
    }
}
