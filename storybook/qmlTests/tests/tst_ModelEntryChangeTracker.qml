import QtQuick
import QtTest

import StatusQ.Core.Utils

Item {
    id: root

    width: 600
    height: 400

    Component {
        id: componentUnderTest

        ModelEntryChangeTracker {
            id: tracker

            model: ListModel {
                ListElement { key: "a"; name: "AA" }
                ListElement { key: "b"; name: "BB" }
                ListElement { key: "c"; name: "CC" }
            }

            role: "key"
            key: "b"

            readonly property SignalSpy itemChangedSpy: SignalSpy {
                target: tracker
                signalName: "itemChanged"
            }
        }
    }

    TestCase {
        name: "ModelEntryChangeTracker"

        function test_change() {
            const tracker = createTemporaryObject(componentUnderTest, this)
            compare(tracker.itemChangedSpy.count, 0)

            tracker.model.setProperty(0, "name", "AAA")
            compare(tracker.itemChangedSpy.count, 0)
            compare(tracker.revision, 0)

            tracker.model.setProperty(1, "name", "BBB")
            compare(tracker.itemChangedSpy.count, 1)
            compare(tracker.revision, 1)
        }

        function test_insertion() {
            const tracker = createTemporaryObject(componentUnderTest, this,
                                                  { key: "d" })
            compare(tracker.itemChangedSpy.count, 0)

            tracker.model.setProperty(0, "name", "AAA")
            tracker.model.setProperty(1, "name", "BBB")
            compare(tracker.itemChangedSpy.count, 0)
            compare(tracker.revision, 0)

            tracker.model.insert(1, { "key": "d", name: "DD" })
            compare(tracker.itemChangedSpy.count, 0)
            compare(tracker.revision, 0)

            tracker.model.setProperty(1, "name", "DDD")
            compare(tracker.itemChangedSpy.count, 1)
            compare(tracker.revision, 1)
        }

        function test_reinitOnRemoval() {
            const tracker = createTemporaryObject(componentUnderTest, this)
            compare(tracker.itemChangedSpy.count, 0)

            tracker.model.append({ "key": "b", name: "BB2" })
            compare(tracker.itemChangedSpy.count, 0)
            compare(tracker.revision, 0)

            tracker.model.setProperty(3, "name", "BBB2")
            compare(tracker.itemChangedSpy.count, 0)
            compare(tracker.revision, 0)

            tracker.model.remove(1)
            compare(tracker.itemChangedSpy.count, 0)
            compare(tracker.revision, 0)

            tracker.model.setProperty(2, "name", "BBBB2")
            compare(tracker.itemChangedSpy.count, 1)
            compare(tracker.revision, 1)
        }

        function test_modelChanged() {
            const tracker = createTemporaryObject(componentUnderTest, this)

            const model = tracker.model
            tracker.model = null

            model.setProperty(1, "name", "BBB")
            compare(tracker.itemChangedSpy.count, 0)
        }
    }
}
