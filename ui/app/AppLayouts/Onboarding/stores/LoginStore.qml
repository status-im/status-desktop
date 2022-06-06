pragma Singleton

import QtQuick 2.13

QtObject {
    property var loginModuleInst: loginModule
    property var currentAccount: loginModuleInst.selectedAccount

    property KeycardStore keycardStore: KeycardStore {
        keycardModule: loginModuleInst.keycardModule
    }

    function login(password) {
        loginModuleInst.login(password)
    }

    function setCurrentAccount(index) {
        loginModuleInst.setSelectedAccountByIndex(index)
    }

    function rowCount() {
        return loginModuleInst.accountsModel.rowCount()
    }
}
