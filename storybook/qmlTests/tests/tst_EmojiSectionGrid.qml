import QtQuick
import QtTest

import StatusQ.Core.Utils as StatusQUtils

import SortFilterProxyModel

/*
 The emoji grid built from StatusEmojiModel.sections(): the sections tile the
 content exactly, they hold what the old filtering proxy would have held, a
 point resolves to a model row by arithmetic, the column count follows the
 width without losing the scroll position, and only the sections that have been
 near the viewport are loaded.
*/
Item {
    id: root

    width: 420
    height: 500

    Loader {
        id: pageLoader
        anchors.fill: parent
        source: Qt.resolvedUrl("../../pages/EmojiSectionGridPage.qml")
    }

    // what the page used to be built on: the reference for the parity check
    SortFilterProxyModel {
        id: reference

        sourceModel: StatusQUtils.Emoji.emojiModel
        filters: [
            AllOf {
                enabled: searchPhrase !== ""
                AnyOf {
                    StatusQUtils.SearchFilter { roleName: "name"; searchPhrase: reference.searchPhrase }
                    StatusQUtils.SearchFilter { roleName: "shortname"; searchPhrase: reference.searchPhrase }
                }
            },
            AnyOf {
                ValueFilter { roleName: "skinColor"; value: "" }
                ValueFilter { roleName: "skinColor"; value: "base" }
            }
        ]
        sorters: RoleSorter { roleName: "emoji_order" }

        property string searchPhrase: ""
    }

    TestCase {
        name: "EmojiSectionGrid"
        when: windowShown

        readonly property var page: pageLoader.item
        readonly property var grid: findChild(pageLoader.item, "emojiGrid")

        function initTestCase() {
            verify(!!page, "the page must load")
            verify(!!grid)
            verify(page.total > 100, "expected the full catalogue")
        }

        function init() {
            if (page.searchString !== "")
                page.searchString = ""
            root.width = 420
            grid.contentY = 0
        }

        // ── the section table ────────────────────────────────────────────────

        function test_sectionsTileTheContent() {
            const sections = page.sections
            verify(sections.length >= 8, `expected several sections, got ${sections.length}`)

            let top = 0
            let counted = 0
            const names = []
            for (let i = 0; i < sections.length; ++i) {
                const section = sections[i]
                compare(section.top, top, `section ${i} (${section.name}) sits wrong`)
                compare(section.lines, Math.ceil(section.count / page.columns))
                compare(section.rows.length, section.count)
                verify(!!section.name)
                verify(names.indexOf(section.name) === -1, `${section.name} appears twice`)
                names.push(section.name)
                top += page.headerHeight + section.lines * page.cellSize
                counted += section.count
            }
            compare(counted, page.total)
        }

        // Heights come from the entry count, so the content height - and the
        // scrollbar - are right before anything has been loaded.
        function test_contentHeightIsExactUpFront() {
            let exact = 0
            for (const section of page.sections)
                exact += page.headerHeight + section.lines * page.cellSize
            // the Column lays out on polish, so a width change lands a frame later
            tryCompare(grid, "contentHeight", exact)
        }

        // ── parity with the proxy the page used to filter with ───────────────

        function test_sectionsHoldWhatTheProxyWouldHave_data() {
            return [
                { tag: "everything", phrase: "" },
                { tag: "a few results", phrase: "smile" },
                { tag: "one category", phrase: "flag:" },
                { tag: "scattered", phrase: "cat" },
            ]
        }

        function test_sectionsHoldWhatTheProxyWouldHave(data) {
            search(data.phrase)
            reference.searchPhrase = data.phrase

            let text = ""
            let count = 0
            for (const section of page.sections) {
                text += section.text
                count += section.count
            }
            compare(count, reference.count, `${data.phrase}: wrong number of entries`)

            let expected = ""
            for (let i = 0; i < reference.count; ++i)
                expected += StatusQUtils.ModelUtils.get(reference, i, "emoji")
            compare(text, expected, `${data.phrase}: different entries, or a different order`)

            reference.searchPhrase = ""
        }

        // ── the glyph grid ───────────────────────────────────────────────────

        function test_cellPitchIsExact() {
            tryVerify(() => !!findChild(grid, "emojiRun"), 2000)
            const run = findChild(grid, "emojiRun")
            compare(run.font.pixelSize + run.font.letterSpacing, page.cellSize)
            compare(run.lineCount, page.sections[0].lines)
        }

        // ── hit testing ──────────────────────────────────────────────────────

        // a cell resolves to the row of the emoji model that is drawn there
        function test_clickMapsBackToTheModelRow() {
            const pitch = page.cellSize
            for (const section of page.sections) {
                const firstRow = section.top + page.headerHeight + pitch / 2
                compare(grid.cellIndexAt(pitch / 2, firstRow), section.rows[0])
                compare(StatusQUtils.ModelUtils.get(page.emojiModel, section.rows[0], "category"),
                        section.name)
                if (section.count >= page.columns)
                    compare(grid.cellIndexAt((page.columns - 1) * pitch + pitch / 2, firstRow),
                            section.rows[page.columns - 1])
            }
        }

        function test_aLabelIsNotACell() {
            for (const section of page.sections)
                compare(grid.cellIndexAt(page.cellSize / 2, section.top + 2), -1,
                        `the ${section.name} label resolved to a cell`)
        }

        function test_outsideTheGridResolvesToNothing() {
            const pitch = page.cellSize
            compare(grid.cellIndexAt(-5, page.headerHeight + pitch / 2), -1)
            compare(grid.cellIndexAt(page.columns * pitch + 5, page.headerHeight + pitch / 2), -1)
            compare(grid.cellIndexAt(pitch / 2, -5), -1)
            compare(grid.cellIndexAt(pitch / 2, grid.contentHeight + pitch), -1)
        }

        function test_aTailRowHasNoPhantomCells() {
            const pitch = page.cellSize
            const section = page.sections[0]
            const lastRow = section.lines - 1
            const used = section.count - lastRow * page.columns
            if (used === page.columns)
                skip("the first section happens to fill its last line")
            const y = section.top + page.headerHeight + lastRow * pitch + pitch / 2
            compare(grid.cellIndexAt(used * pitch + pitch / 2, y), -1)
        }

        // ── hovering ─────────────────────────────────────────────────────────

        // The highlight used to be placed at floor(y / cellSize) * cellSize,
        // a grid that ignores the section headers, so it drifted up by one
        // header height per section above the cell under the cursor.
        function test_theHighlightSitsOnTheHoveredCell_data() {
            return [
                { tag: "first section", section: 0, line: 1, column: 2 },
                { tag: "after one header", section: 1, line: 0, column: 0 },
                { tag: "deep in the list", section: 3, line: 2, column: 5 },
            ]
        }

        function test_theHighlightSitsOnTheHoveredCell(data) {
            const pitch = page.cellSize
            const section = page.sections[data.section]
            verify(section.lines > data.line && section.count > data.column)

            const top = section.top + page.headerHeight + data.line * pitch
            // keep the cell on screen; the handler works in viewport coordinates
            grid.contentY = Math.max(0, top - grid.height / 2)
            mouseMove(grid, data.column * pitch + pitch / 2, top - grid.contentY + pitch / 2)

            const highlight = findChild(grid, "hoverHighlight")
            verify(!!highlight)
            verify(highlight.visible, "the highlight must show on a cell")
            compare(highlight.x, data.column * pitch)
            compare(highlight.y, top)
            compare(highlight.width, pitch)
            compare(highlight.height, pitch)

            // and it covers the cell the point resolves to
            compare(grid.hoveredModelRow,
                    section.rows[data.line * page.columns + data.column])

            // the tooltip is parented to the Flickable, so it works in viewport
            // coordinates while the highlight works in content ones
            const tooltip = findChild(grid, "hoverTooltip")
            verify(!!tooltip)
            // a popup places itself when it opens, so its x and y mean nothing
            // until then
            tryVerify(() => tooltip.visible, 3000, "the tooltip must show")
            compare(tooltip.x, data.column * pitch)
            compare(tooltip.y, top - grid.contentY - tooltip.height)
        }

        // a header, a gap in a tail row, and the area past the last section are
        // not cells, and must not light up
        function test_theHighlightHidesWhereThereIsNoCell() {
            const pitch = page.cellSize
            const section = page.sections[1]
            grid.contentY = Math.max(0, section.top - grid.height / 2)
            mouseMove(grid, pitch / 2, section.top - grid.contentY + 2)

            const highlight = findChild(grid, "hoverHighlight")
            verify(!highlight.visible, "the section label is not a cell")
            compare(grid.hoveredModelRow, -1)
        }

        // ── resizing ─────────────────────────────────────────────────────────

        // The column count follows the width; only the geometry is recomputed,
        // so the position in the list is kept.
        function test_columnsFollowTheWidthAndKeepTheScrollPosition() {
            const wide = page.columns
            grid.contentY = 400
            const before = grid.contentY

            root.width = 300
            compare(page.columns, Math.max(4, Math.floor(grid.width / page.cellSize)))
            verify(page.columns < wide, `expected fewer columns, got ${page.columns}`)
            compare(grid.contentY, before, "the scroll position must survive a resize")

            let exact = 0
            for (const section of page.sections) {
                compare(section.lines, Math.ceil(section.count / page.columns))
                exact += page.headerHeight + section.lines * page.cellSize
            }
            tryCompare(grid, "contentHeight", exact)

            root.width = 420
            compare(page.columns, wide)
        }

        // ── loading ──────────────────────────────────────────────────────────

        function test_onlyTheSectionsNearTheViewportAreLoaded() {
            const total = page.sections.length
            tryVerify(() => page.loadedSections > 0, 2000, "the first section must load")
            verify(page.loadedSections < total,
                   `expected fewer than ${total} sections loaded, got ${page.loadedSections}`)

            const before = page.loadedSections
            grid.contentY = grid.contentHeight - grid.height
            tryVerify(() => page.loadedSections > before, 2000,
                      "scrolling to the end must bring more sections in")
            verify(page.loadedSections <= total)
        }

        // ── rendering ────────────────────────────────────────────────────────

        // A section is one text node, up to 553 glyphs. Nodes of that size were
        // fine in the earlier PoC while ~1,900-glyph ones dropped to the glyph
        // outline for some emoji, so this checks that a cell deep inside the
        // largest sections is still painted in colour.
        function test_everyCellIsPaintedInColour_data() {
            return [
                { tag: "smileys, the largest section", shortname: ":face_with_monocle:" },
                { tag: "the one that used to fail", shortname: ":low_brightness:" },
            ]
        }

        function test_everyCellIsPaintedInColour(data) {
            const pitch = page.cellSize
            let found = null
            for (const section of page.sections) {
                for (let i = 0; i < section.count; ++i) {
                    if (StatusQUtils.ModelUtils.get(page.emojiModel, section.rows[i],
                                                    "shortname") !== data.shortname)
                        continue
                    found = { section, offset: i }
                    break
                }
                if (found)
                    break
            }
            verify(!!found, `${data.shortname} is not in the catalogue`)

            const column = found.offset % page.columns
            const top = found.section.top + page.headerHeight
                      + Math.floor(found.offset / page.columns) * pitch
            grid.contentY = Math.max(0, top - grid.height / 2)
            tryVerify(() => grid.cellIndexAt(column * pitch + pitch / 2,
                                             top + pitch / 2) === found.section.rows[found.offset])
            wait(100) // let the section's loader finish incubating

            const image = grabImage(grid)
            let ink = 0
            let coloured = 0
            for (let x = column * pitch; x < (column + 1) * pitch; ++x) {
                for (let y = top - grid.contentY; y < top - grid.contentY + pitch; ++y) {
                    const pixel = image.pixel(x, y)
                    if (pixel.a <= 0.1)
                        continue
                    ink++
                    const max = Math.max(pixel.r, pixel.g, pixel.b)
                    const min = Math.min(pixel.r, pixel.g, pixel.b)
                    if (max - min > 0.15)
                        coloured++
                }
            }
            verify(ink > 50, `${data.shortname}: the cell is blank (${ink} px of ink)`)
            verify(coloured > 20,
                   `${data.shortname}: the cell has ink but no colour (${coloured} of ${ink} px)`)
        }

        // Typing must not blank the grid. Replacing the view's model - or handing
        // a Repeater a new array - destroys every delegate, and the asynchronous
        // loaders then leave one or two painted frames empty: the content blinks
        // on every keystroke. The sections are therefore updated row by row, and
        // a loaded text run must survive the keystroke.
        function test_typingDoesNotBlankTheGrid() {
            tryVerify(() => page.loadedSections > 0, 2000)
            verify(inkInFirstCell() > 50, "the grid must start out painted")

            for (const phrase of ["s", "sm", "smi", "sm", "s", ""]) {
                page.searchString = phrase
                verify(page.total > 0)
                verify(page.loadedSections > 0,
                       `nothing is loaded right after typing "${phrase}"`)
                const ink = inkInFirstCell()
                verify(ink > 50,
                       `the grid went blank right after typing "${phrase}" (${ink} px of ink)`)
            }
        }

        function inkInFirstCell() {
            const pitch = page.cellSize
            const image = grabImage(grid)
            let ink = 0
            for (let x = 0; x < pitch; ++x)
                for (let y = page.headerHeight; y < page.headerHeight + pitch; ++y)
                    if (image.pixel(x, y).a > 0.1)
                        ink++
            return ink
        }

        // ── search ───────────────────────────────────────────────────────────

        function search(phrase) {
            if (page.searchString === phrase)
                return 0
            const before = page.rebuildCount
            page.searchString = phrase
            tryVerify(() => page.rebuildCount > before, 5000)
            return page.rebuildCount - before
        }

        // One keystroke is one call to sections(), and that call is all it takes:
        // the grid reads no model rows of its own.
        function test_aKeystrokeCostsOneCallAndNoRowReads() {
            compare(search("s"), 1)
            compare(page.readsPerRebuild, 0)
            compare(search("sm"), 1)
            compare(page.readsPerRebuild, 0)
            compare(search(""), 1)
            compare(page.readsPerRebuild, 0)
        }

        function test_searchRebuildsTheSections() {
            const all = page.total
            search("cat")
            verify(page.total < all)
            verify(page.sections.length >= 1)
            compare(grid.cellIndexAt(page.cellSize / 2,
                                     page.sections[0].top + page.headerHeight + page.cellSize / 2),
                    page.sections[0].rows[0])

            search("zzzxq")
            compare(page.sections.length, 0)
            compare(page.total, 0)
            compare(grid.cellIndexAt(page.cellSize / 2, page.cellSize / 2), -1)

            search("")
            compare(page.total, all)
        }
    }
}
