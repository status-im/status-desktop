pragma Singleton

import QtQml 2.15
import QtTest 1.15

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
