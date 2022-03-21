pragma Singleton

import QtQml 2.14
import QtTest 1.0

QtObject {

    //> Simulate key and wait for side effects
    function pressKeyAndWait(test, item, key) {
        test.keyClick(key)

        test.waitForRendering(item)
    }
}
