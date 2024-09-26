import QtQuick 2.15
import QtTest 1.15

import StatusQ.Core.Utils 0.1

Item {
    id: root

    width: 600
    height: 400

    Component {
        id: empty

        LazyStackLayout {}
    }

    Component {
        id: nonEmpty

        LazyStackLayout {
            property int counter: 0

            anchors.fill: parent

            Component {
                Rectangle {
                    color: "green"

                    Component.onCompleted: counter++
                }
            }

            Component {
                Rectangle {
                    color: "red"

                    Component.onCompleted: counter++
                }
            }

            Component {
                Rectangle {
                    color: "yellow"

                    Component.onCompleted: counter++
                }
            }
        }
    }

    TestCase {
        name: "LazyStackLayout"
        when: windowShown

        function test_emptyLayout() {
            const layout = createTemporaryObject(empty, root)

            compare(layout.count, 0)
            compare(layout.currentItem, null)
        }

        function test_itemsInitialization() {
            const layout = createTemporaryObject(nonEmpty, root)

            compare(layout.count, 3)
            compare(layout.currentIndex, 0)
            compare(layout.counter, 1)
            verify(layout.currentItem !== null)
            verify(layout.currentItem instanceof Rectangle)
            compare(layout.currentItem.color, "#008000")

            layout.currentIndex = 1

            compare(layout.count, 3)
            compare(layout.currentIndex, 1)
            compare(layout.counter, 2)
            verify(layout.currentItem !== null)
            verify(layout.currentItem instanceof Rectangle)
            compare(layout.currentItem.color, "#ff0000")

            layout.currentIndex = 0

            compare(layout.count, 3)
            compare(layout.currentIndex, 0)
            compare(layout.counter, 2)
            verify(layout.currentItem !== null)
            verify(layout.currentItem instanceof Rectangle)
            compare(layout.currentItem.color, "#008000")

            layout.currentIndex = 2

            compare(layout.count, 3)
            compare(layout.currentIndex, 2)
            compare(layout.counter, 3)
            verify(layout.currentItem !== null)
            verify(layout.currentItem instanceof Rectangle)
            compare(layout.currentItem.color, "#ffff00")
        }
    }
}
