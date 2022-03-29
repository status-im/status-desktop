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
    property bool accountImported: false

    property bool showBeforeGetStartedPopup: true

    function importMnemonic(mnemonic) {
        onboardingModuleInst.importMnemonic(mnemonic)
    }

    function setCurrentAccountAndDisplayName(selectedAccountIdx, displayName) {
        onboardingModuleInst.setDisplayName(displayName)
        onboardingModuleInst.setSelectedAccountByIndex(selectedAccountIdx)
    }

    function importAccountAndDisplayName(displayName) {
        onboardingModuleInst.setDisplayName(displayName)
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

    function uploadImage(source, aX, aY, bX, bY) {
        root.profImgUrl = source;
        root.profImgAX = aX;
        root.profImgAY = aY;
        root.profImgBX = bX;
        root.profImgBY = bY;
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
        root.privacyModule.changePassword(password, newPassword)
    }

    property ListModel accountsSampleData: ListModel {
        ListElement {
            username: "Ferocious Herringbone Sinewave2"
            identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAg0lEQVR4nOzXwQmAMBAFURV7sQybsgybsgyr0QYUlE1g+Mw7ioQMe9lMQwhDaAyhMYTGEJqYkPnrj/t5XE/ft2UdW1yken7MRAyhMYTGEBpDaAyhKe9JbzvSX9WdLWYihtAYQuMLkcYQGkPUScxEDKExhMYQGkNoDKExhMYQmjsAAP//ZfIUZgXTZXQAAAAASUVORK5CYII="
            address: "0x123456789009876543211234567890"
        }
        ListElement {
            username: "Another Account"
            identicon: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAg0lEQVR4nOzXwQmAMBAFURV7sQybsgybsgyr0QYUlE1g+Mw7ioQMe9lMQwhDaAyhMYTGEJqYkPnrj/t5XE/ft2UdW1yken7MRAyhMYTGEBpDaAyhKe9JbzvSX9WdLWYihtAYQuMLkcYQGkPUScxEDKExhMYQGkNoDKExhMYQmjsAAP//ZfIUZgXTZXQAAAAASUVORK5CYII="
            address: "0x123456789009876543211234567890"
        }
    }
}
