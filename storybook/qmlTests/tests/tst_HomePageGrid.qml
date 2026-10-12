import QtQuick
import QtTest

import AppLayouts.HomePage

import utils

Item {
    id: root

    width: 800
    height: 500

    Component {
        id: modelComponent

        ListModel {}
    }

    Component {
        id: componentUnderTest

        HomePageGrid {
            width: 4 * 176 + 40 // 4 columns
            height: 500
            spacing: 16
        }
    }

    TestCase {
        name: "HomePageGrid"
        when: windowShown

        function entry(i) {
            return {
                key: "key" + i, id: "id" + i, sectionType: Constants.appSection.chat,
                name: "Chat " + i, icon: "", color: "red", banner: "",
                hasNotification: false, notificationsCount: 0, enabled: true,
                chatType: Constants.chatType.oneToOne, onlineStatus: Constants.onlineStatus.inactive,
                lastMessageText: "", sectionName: "", pinned: false, timestamp: 0
            }
        }

        // Returns a description of the first delegate not placed at its cell,
        // or an empty string.
        function misplacedDelegate(gridView) {
            const columns = Math.round(gridView.width / gridView.cellWidth)

            for (let i = 0; i < gridView.count; i++) {
                const item = gridView.itemAtIndex(i)
                const x = (i % columns) * gridView.cellWidth
                const y = Math.floor(i / columns) * gridView.cellHeight

                if (!item) {
                    const inViewport = y + gridView.cellHeight > gridView.contentY
                        && y < gridView.contentY + gridView.height
                    if (inViewport)
                        return `index ${i}: no delegate`
                    continue
                }
                if (item.x !== x || item.y !== y)
                    return `index ${i}: at (${item.x}, ${item.y}) instead of (${x}, ${y})`
            }

            return ""
        }

        // A filter re-enabling a group of entries inserts several ranges at
        // once, growing the grid by multiple rows. All delegates must end up
        // at their cells, otherwise the grid shows holes.
        function test_batchedInsertionsGrowingGrid() {
            const model = createTemporaryObject(modelComponent, root)
            let n = 0
            for (; n < 16; n++)
                model.append(entry(n))

            const grid = createTemporaryObject(componentUnderTest, root, { model })
            const gridView = findChild(grid, "homePageGridView")
            verify(!!gridView)
            tryVerify(() => misplacedDelegate(gridView) === "")

            // the insertion ranges emitted by HomePageAdaptor when the settings
            // entries are shown again (with communities filtered out)
            for (const [first, last] of [[15, 15], [12, 12], [8, 8], [6, 14], [5, 5], [4, 5], [0, 4]]) {
                const rows = []
                for (let i = first; i <= last; i++)
                    rows.push(entry(n++))
                model.insert(first, rows)
            }

            compare(gridView.count, 36)
            gridView.forceLayout()
            tryVerify(() => misplacedDelegate(gridView) === "", 1000,
                      "a delegate is not at its grid cell")
        }
    }
}
