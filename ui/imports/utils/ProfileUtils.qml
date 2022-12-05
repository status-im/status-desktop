pragma Singleton

import QtQml 2.14

QtObject {
    function displayName(nickName, ensName, displayName, aliasName)
    {
        return nickName || ensName || displayName || aliasName
    }
}
