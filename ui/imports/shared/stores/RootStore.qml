import QtQuick 2.15
import utils 1.0

QtObject {
    id: root

    readonly property GifStore gifStore: GifStore {}

    property var profileSectionModuleInst: profileSectionModule
    property var privacyModule: profileSectionModuleInst.privacyModule
    property var appSettingsInst: Global.appIsReady && !!appSettings? appSettings : null
    property var accountSensitiveSettings: Global.appIsReady && !!localAccountSensitiveSettings? localAccountSensitiveSettings : null
    property real volume: !!appSettingsInst ? appSettingsInst.volume * 0.01 : 0.5

    property bool notificationSoundsEnabled: !!appSettingsInst ? appSettingsInst.notificationSoundsEnabled : true
    property bool neverAskAboutUnfurlingAgain: !!accountSensitiveSettings ? accountSensitiveSettings.neverAskAboutUnfurlingAgain : false
    property bool gifUnfurlingEnabled: !!accountSensitiveSettings ? accountSensitiveSettings.gifUnfurlingEnabled : false

    required property CurrenciesStore currencyStore

    function setNeverAskAboutUnfurlingAgain(value) {
        localAccountSensitiveSettings.neverAskAboutUnfurlingAgain = value;
    }

    function getPasswordStrengthScore(password) {
        return root.privacyModule.getPasswordStrengthScore(password, "");
    }
}
