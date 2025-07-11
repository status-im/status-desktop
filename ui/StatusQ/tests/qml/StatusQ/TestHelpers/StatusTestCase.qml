import QtTest
import QtQml

/*!
    \qmltype StatusTestCase
    \inherits TestCase
    \inqmlmodule StatusQ.Core
    \since StatusQ.Core 0.1
    \brief Represents a basic Status unit test case with some added goodies.
*/
TestCase {
    when: windowShown

    function keyClickSequence(keys) {
        for (let k of keys) {
            keyClick(k)
        }
    }

    function mouseRightClick(item, delay = 100, modifiers = Qt.NoModifier) {
        mouseClick(item, item.width/2, item.height/2, Qt.RightButton, modifiers, delay)
    }

    function mouseLongPress(item, modifiers = Qt.NoModifier) {
        mousePress(item, item.width/2, item.height/2, Qt.LeftButton, modifiers, Qt.styleHints.mousePressAndHoldInterval)
        mouseRelease(item, item.width/2, item.height/2, Qt.LeftButton, modifiers, Qt.styleHints.mousePressAndHoldInterval*2)
    }

    // can be removed once we fully switch to Qt6
    function compatMouseMove(item) {
        mouseMove(item, item.width/2, item.height/2)
    }
}
