import QtQuick
import QtTest

import StatusQ.Core.Theme
import StatusQ.Core.Utils as StatusQUtils

/*
 Checks what the PoC page claims: the text runs put the same emoji in the same
 cells as the per-cell grid, a click maps back to a model index by arithmetic,
 the sections start on their own row behind a label, and the runs cost far
 fewer items than one delegate per cell.
*/
Item {
    id: root

    width: 1900
    // tall enough that the control strip leaves the panes a real viewport
    height: 820

    Loader {
        id: pageLoader
        anchors.fill: parent
        source: Qt.resolvedUrl("../../pages/EmojiGridPoCPage.qml")
    }

    TestCase {
        name: "EmojiGridPoC"
        when: windowShown

        readonly property var page: pageLoader.item
        readonly property var classicGrid: findChild(pageLoader.item, "classicGrid")
        readonly property var rowsView: findChild(pageLoader.item, "rowsView")
        readonly property var categoryView: findChild(pageLoader.item, "categoryView")
        readonly property var paragraphView: findChild(pageLoader.item, "paragraphView")
        readonly property var wholeView: findChild(pageLoader.item, "wholeView")
        readonly property var lazyView: findChild(pageLoader.item, "lazyView")

        function initTestCase() {
            verify(!!page, "the PoC page must load")
            verify(!!classicGrid && !!rowsView && !!categoryView
                   && !!paragraphView && !!wholeView && !!lazyView)
            verify(page.filteredModel.count > 100, "expected the full catalogue")
        }

        // ── helpers ──────────────────────────────────────────────────────────

        // the row model interleaves section headers; this returns the Text of
        // the first row that holds emoji, plus the row's index and position
        function firstEmojiRow() {
            for (let i = 0; i < page.rows.length; ++i) {
                if (!!page.rows[i].header)
                    continue
                const item = rowsView.itemAtIndex(i)
                if (!item)
                    continue
                // the delegate is the Text itself when a chooser picks it
                if (item.font !== undefined && item.font.letterSpacing > 0)
                    return { text: item, index: i, y: item.y }
                for (let c = 0; c < item.children.length; ++c)
                    if (item.children[c].font !== undefined && item.children[c].visible)
                        return { text: item.children[c], index: i, y: item.y }
            }
            return null
        }

        // ink bounding box of one cell, in cell-local coordinates
        function inkCentre(image, left, top, size) {
            let minX = size, maxX = -1, minY = size, maxY = -1
            for (let x = 0; x < size; ++x) {
                for (let y = 0; y < size; ++y) {
                    if (image.pixel(left + x, top + y).a <= 0.1)
                        continue
                    minX = Math.min(minX, x); maxX = Math.max(maxX, x)
                    minY = Math.min(minY, y); maxY = Math.max(maxY, y)
                }
            }
            return maxX < 0 ? { found: false, x: 0, y: 0 }
                            : { found: true, x: (minX + maxX) / 2, y: (minY + maxY) / 2 }
        }

        // ── the glyph grid ───────────────────────────────────────────────────

        // Every catalogue entry is one glyph of one em - that is what lets a row
        // be a single Text with letterSpacing for the pitch.
        function test_cellPitchIsExact() {
            const row = firstEmojiRow()
            verify(!!row)
            const pitch = page.cellSize
            compare(row.text.font.pixelSize + row.text.font.letterSpacing, pitch)
            // Text rounds its content width up by a pixel
            fuzzyCompare(row.text.contentWidth, page.columns * pitch, 1)
        }

        // The geometry claim, checked on pixels: a glyph in a text run lands
        // where the per-cell grid puts it.
        function test_glyphsLandWhereTheGridPutsThem_data() {
            return [
                { tag: "first cell", column: 0 },
                { tag: "mid row", column: 3 },
            ]
        }

        function test_glyphsLandWhereTheGridPutsThem(data) {
            const pitch = page.cellSize
            const row = firstEmojiRow()
            verify(!!row)

            const classic = inkCentre(grabImage(classicGrid), data.column * pitch, 0, pitch)
            const rows = inkCentre(grabImage(rowsView), data.column * pitch, row.y, pitch)
            const whole = inkCentre(grabImage(wholeView), data.column * pitch, 0, pitch)
            verify(classic.found && rows.found && whole.found)
            fuzzyCompare(rows.x, classic.x, 2)
            fuzzyCompare(whole.x, classic.x, 2)
        }

        function test_singleTextWrapsOntoTheSameGrid() {
            // the claim is about wrapping: every line must hold exactly `columns`
            // glyphs. The line height is a knob being experimented with on the
            // page, so it is not asserted here.
            const text = findChild(wholeView, "wholeText")
            verify(!!text)
            compare(text.lineCount, Math.ceil(page.filteredModel.count / page.columns))
        }

        // ── sections ─────────────────────────────────────────────────────────

        function test_rowsCarryTheModelInOrderBehindHeaders() {
            const rows = page.rows
            const count = page.filteredModel.count
            let headers = 0
            let covered = 0

            for (let i = 0; i < rows.length; ++i) {
                const row = rows[i]
                if (!!row.header) {
                    headers++
                    // a section starts on its own row, at its first entry
                    verify(i + 1 < rows.length)
                    compare(rows[i + 1].first, row.first)
                    continue
                }
                const end = i + 1 < rows.length ? rows[i + 1].first : count
                verify(end - row.first <= page.columns, "a row cannot hold more than `columns`")
                let expected = ""
                for (let index = row.first; index < end; ++index)
                    expected += StatusQUtils.ModelUtils.get(page.filteredModel, index, "emoji")
                compare(row.text, expected)
                covered += end - row.first
            }
            compare(headers, page.categoryBlocks.length, "one header per section")
            compare(covered, count, "every entry must be in a row")
        }

        function test_categoryBlocksTileTheView() {
            const blocks = page.categoryBlocks
            verify(blocks.length >= 5, `expected several categories, got ${blocks.length}`)

            let expectedTop = 0
            let expectedParaTop = 0
            let counted = 0
            for (let i = 0; i < blocks.length; ++i) {
                compare(blocks[i].top, expectedTop, `block ${i} (${blocks[i].name}) starts wrong`)
                compare(blocks[i].paraTop, expectedParaTop, `block ${i} label-less top is wrong`)
                compare(blocks[i].lines, Math.ceil(blocks[i].count / page.columns))
                compare(blocks[i].first, counted)
                expectedTop += page.headerHeight + blocks[i].lines * page.cellSize
                expectedParaTop += blocks[i].lines * page.cellSize
                counted += blocks[i].count
            }
            compare(counted, page.filteredModel.count, "the blocks must cover the model")

            // the hit test reads `top` while the view stacks delegates by their
            // real heights, so the two must agree for every realised block
            for (let i = 0; i < blocks.length; ++i) {
                const item = categoryView.itemAtIndex(i)
                if (!!item)
                    compare(item.y, blocks[i].top, `block ${i} (${blocks[i].name}) sits wrong`)
            }
        }

        function test_paragraphsBreakWhereTheCategoriesDo() {
            const text = findChild(paragraphView, "paragraphText")
            verify(!!text)
            let lines = 0
            for (const block of page.categoryBlocks)
                lines += block.lines
            compare(text.lineCount, lines)
            compare(paragraphView.contentHeight, lines * page.cellSize)
        }

        // ── hit testing ──────────────────────────────────────────────────────

        function test_rowClickMapsBackToTheModelIndex() {
            const pitch = page.cellSize
            const row = firstEmojiRow()
            verify(!!row)
            const first = page.rows[row.index].first
            for (const column of [0, 3, page.columns - 1])
                compare(rowsView.cellIndexAt(column * pitch + pitch / 2, row.y + pitch / 2),
                        first + column)
        }

        function test_aSectionHeaderIsNotACell() {
            // the header row occupies the top of its section and must not resolve
            const header = rowsView.itemAtIndex(0)
            verify(!!header)
            verify(!!page.rows[0].header, "the first row is expected to be a header")
            compare(rowsView.cellIndexAt(page.cellSize / 2, header.y + 2), -1)
        }

        function test_outsideTheGridResolvesToNothing() {
            const row = firstEmojiRow()
            compare(rowsView.cellIndexAt(-5, row.y + 5), -1)
            compare(rowsView.cellIndexAt(page.columns * page.cellSize + 5, row.y + 5), -1)
            compare(wholeView.cellIndexAt(10, -5), -1)
        }

        function test_categoryClickMapsBackToTheModelIndex() {
            const pitch = page.cellSize
            for (const block of page.categoryBlocks) {
                const firstRowY = block.top + page.headerHeight + pitch / 2
                compare(categoryView.cellIndexAt(pitch / 2, firstRowY), block.first)
                // the label itself is not a cell
                compare(categoryView.cellIndexAt(pitch / 2, block.top + 2), -1)
                if (block.count >= page.columns)
                    compare(categoryView.cellIndexAt((page.columns - 1) * pitch + pitch / 2, firstRowY),
                            block.first + page.columns - 1)
            }
        }

        function test_categoryTailRowHasNoPhantomCells() {
            const pitch = page.cellSize
            const block = page.categoryBlocks[0]
            const lastRow = block.lines - 1
            const used = block.count - lastRow * page.columns
            if (used === page.columns)
                skip("the first category happens to fill its last line")
            const x = used * pitch + pitch / 2 // first empty cell of the tail row
            compare(categoryView.cellIndexAt(
                        x, block.top + page.headerHeight + lastRow * pitch + pitch / 2), -1)
        }

        function test_paragraphClickMapsBackToTheModelIndex() {
            const pitch = page.cellSize
            for (const block of page.categoryBlocks) {
                compare(paragraphView.cellIndexAt(pitch / 2, block.paraTop + pitch / 2), block.first)
                if (block.count >= page.columns)
                    compare(paragraphView.cellIndexAt((page.columns - 1) * pitch + pitch / 2,
                                                      block.paraTop + pitch / 2),
                            block.first + page.columns - 1)
            }
        }

        function test_singleTextClickMapsBackToTheModelIndex() {
            const pitch = page.cellSize
            compare(wholeView.cellIndexAt(pitch / 2, pitch / 2), 0)
            compare(wholeView.cellIndexAt(5 * pitch + 2, 3 * pitch + 2), 3 * page.columns + 5)
            compare(wholeView.cellIndexAt(-1, 0), -1)
        }

        // ── the lazy pane ────────────────────────────────────────────────────

        // Heights come from the chunk table, so the content height - and the
        // scrollbar - are right before anything has been loaded.
        function test_lazyContentHeightIsExactUpFront() {
            let exact = 0
            for (const chunk of page.categoryBlocks)
                exact += (chunk.label ? page.headerHeight : 0) + chunk.lines * page.cellSize
            compare(lazyView.contentHeight, exact)
        }

        function test_lazyLoadsOnlyWhatHasBeenSeen() {
            const total = page.categoryBlocks.length
            // the sections are incubated asynchronously, so give them a frame
            tryVerify(() => page.lazySectionsLoaded > 0, 2000,
                      "the first section must be loaded")
            verify(page.lazySectionsLoaded < total,
                   `expected fewer than ${total} sections loaded, got ${page.lazySectionsLoaded}`)

            const before = page.lazySectionsLoaded
            lazyView.contentY = lazyView.contentHeight - lazyView.height
            tryVerify(() => page.lazySectionsLoaded > before, 2000,
                      "scrolling to the end must bring more sections in")
            verify(page.lazySectionsLoaded <= total)
        }

        // ── the point of the exercise ────────────────────────────────────────

        function test_textRunsUseFarFewerItems() {
            const perCell = page.countItemsIn(classicGrid)
            const rows = page.countItemsIn(rowsView)
            const categories = page.countItemsIn(categoryView)
            const whole = page.countItemsIn(wholeView)
            verify(perCell > 0 && rows > 0 && categories > 0 && whole > 0)
            verify(rows * 4 < perCell,
                   `expected the rows view to use far fewer items, got ${rows} vs ${perCell}`)
            verify(categories * 4 < perCell,
                   `expected the category view to use far fewer items, got ${categories} vs ${perCell}`)
        }
    }
}
