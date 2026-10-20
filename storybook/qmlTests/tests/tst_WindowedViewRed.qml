pragma ComponentBehavior: Bound

import QtQuick
import QtTest

import StatusQ.Core

/*
  Adversarial cases against WindowedView, each on a view of its own.
*/
Item {
    id: root

    width: 500
    height: 400

    // Plain rows: implicitHeight is arithmetic, final the instant it is set.
    Component {
        id: rowDelegate

        Item {
            property int value: 0

            implicitHeight: 20 + (value % 5) * 30
        }
    }

    Component {
        id: modelComponent

        ListModel {
            function fill(from, count) {
                for (let i = 0; i < count; ++i)
                    append({ key: "k" + (from + i), value: from + i })
            }
        }
    }

    // Counts what the view asked for and what it gave back.
    Component {
        id: providerComponent

        QtObject {
            property int acquired: 0
            property int released: 0

            function acquire(parent, row, modelRow, cb) {
                const item = rowDelegate.createObject(parent, { value: modelRow.value })
                item.width = Qt.binding(() => (parent ? parent.width : undefined) ?? 0)
                acquired++
                cb(item)
            }

            function release(item) {
                released++
                item.destroy()
            }
        }
    }

    Component {
        id: viewComponent

        WindowedView {
            id: view

            required property QtObject provider

            width: 500
            height: 400

            acquireDelegate: (parent, row, modelRow, cb) =>
                    view.provider.acquire(parent, row, modelRow, cb)
            releaseDelegate: (item) => view.provider.release(item)
        }
    }

    function hiddenRows(view) {
        let n = 0

        for (let i = 0; i < view.rowCount; ++i) {
            const shell = view.itemAtRow(i)

            if (shell && !shell.visible)
                ++n
        }

        return n
    }

    function settled(view, expectedRows) {
        return !view.busy && view.rowCount === expectedRows
                && hiddenRows(view) === 0 && view.contentHeight > view.height
    }

    // The topmost visible row and its offset below the viewport top, by
    // screen position - which bottom-up runs the other way round from the
    // model's rows.
    function topRow(view) {
        let best = null

        for (let i = 0; i < view.rowCount; ++i) {
            const shell = view.itemAtRow(i)

            if (shell && shell.visible && shell.content
                    && shell.y + shell.height > view.contentY + 0.01
                    && (!best || shell.y < best.y))
                best = shell
        }

        return best ? { value: best.content.value, offset: best.y - view.contentY }
                    : { value: -9999, offset: 0 }
    }

    TestCase {
        id: redTests

        name: "WindowedView.Red"
        when: windowShown

        property var created: []

        function initTestCase() {
            // the one-time font alias warning must not land on a test
            const warm = Qt.createQmlObject(
                        'import QtQuick; Text { textFormat: Text.RichText;'
                        + ' text: "<b>warm</b>"; font.family: "Sans Serif" }', root)
            wait(100)
            warm.destroy()
        }

        function cleanup() {
            // newest first: the view goes before the provider it releases to
            for (let i = created.length - 1; i >= 0; --i)
                if (created[i])
                    created[i].destroy()

            created = []
            wait(0)
        }

        function make(component, props) {
            const obj = component.createObject(root, props ?? {})
            created.push(obj)
            return obj
        }

        // Rendered bottom-up - a chat - a row above the viewport that grows
        // outside a slide (a reaction, an edit, a late image) pushes the rows
        // the reader is looking at down the screen. ListView.BottomToTop holds
        // them still by moving originY; here nothing holds them, because the
        // anchor is armed only for a slide or a width change.
        function test_bottomUpARowAboveTheViewportGrowingKeepsTheReaderStill() {
            const model = make(modelComponent)
            model.fill(0, 60)

            const provider = make(providerComponent)
            const view = make(viewComponent, {
                model, provider,
                verticalLayoutDirection: WindowedView.VerticalLayoutDirection.BottomToTop
            })

            tryVerify(() => settled(view, 60), 5000, "rows laid out")

            view.contentY = Math.round((view.contentHeight - view.height) / 2)
            verify(view.contentY > 200, "there is room above the viewport")

            const before = topRow(view)

            // bottom-up, the model's last row is the topmost on screen
            const above = view.itemAtRow(59)
            verify(above.y + above.height < view.contentY, "entirely above the viewport")

            const contentHeight = view.contentHeight
            above.content.implicitHeight += 100

            // the Column lays out on polish; wait for the growth to land
            tryVerify(() => view.contentHeight === contentHeight + 100, 2000,
                      "the content grew by the row's growth")
            tryVerify(() => !view.busy, 2000)

            const after = topRow(view)
            compare(after.value, before.value, "the same row is at the top")
            fuzzyCompare(after.offset, before.offset, 0.5,
                         "the top row moved by " + (after.offset - before.offset) + "px")
        }
    }
}
