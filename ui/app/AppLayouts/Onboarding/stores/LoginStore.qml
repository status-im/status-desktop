pragma Singleton

import QtQuick 2.13

QtObject {
    property var loginModul: loginModule
    property var currentAccount: loginModule.selectedAccount

    function login(password) {
        loginModul.login(password)
    }

//    function tryToObtainPassword() {
//        loginModel.tryToObtainPassword()
//    }

    function setCurrentAccount(index) {
        loginModul.setSelectedAccountByIndex(index)
    }

    function rowCount() {
        return loginModul.accountsModel.rowCount()
    }
}
