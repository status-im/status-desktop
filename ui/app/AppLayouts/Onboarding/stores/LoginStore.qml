pragma Singleton

import QtQuick 2.13

QtObject {
    property var loginModelInst: loginModel
    property var currentAccount: loginModel.currentAccount

    function login(password) {
        loginModel.login(password)
    }

    function tryToObtainPassword() {
        loginModel.tryToObtainPassword()
    }

    function setCurrentAccount(index) {
        loginModel.setCurrentAccount(index)
    }

    function rowCount() {
        return loginModel.rowCount()
    }
}
