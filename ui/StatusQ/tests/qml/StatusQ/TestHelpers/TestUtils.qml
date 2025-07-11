pragma Singleton

import QtQml
import QtTest

QtObject {

    //> Simulate key and wait for side effects
    function pressKeyAndWait(test, item, key) {
        test.keyClick(key)

        ensureRendered(test, item)
    }

    function ensureRendered(test, item) {
        test.verify(test.waitForRendering(item, 1000))
    }

    function expectRendering(test, item) {
        test.verify(test.isPolishScheduled(item))
        test.verify(test.waitForRendering(item, 1000))
    }
}
