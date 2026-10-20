import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models

import StatusQ
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core.Utils as StatusQUtils

import SortFilterProxyModel

/*
 PoC: the emoji picker grid drawn as text runs instead of one item per cell.

 Today every cell of StatusEmojiPopup's GridView is an ItemDelegate + background
 Rectangle + StatusEmoji + HoverHandler + StatusToolTip. Since the switch to the
 bundled font an emoji is a glyph, and the font's conformance test guarantees
 every catalogue entry shapes to exactly one glyph of exactly 1 em - so a whole
 row can be a single Text, with letterSpacing supplying the cell pitch and
 arithmetic supplying the hit test.

 Left pane is the current structure, right pane the text runs, same model, same
 cell size. The panel underneath counts items and times a scripted scroll.
*/
Item {
    id: root

    readonly property int cellSize: cellSizeSpin.value
    // Resizing: with "adapt to width" the panes share the available width and
    // the column count follows it, the way the real popup would behave.
    readonly property int paneCount: 6
    readonly property int paneWidth: adaptColumns.checked
        ? Math.max(4 * cellSize, Math.floor((root.width - 40 - 16 * paneCount) / paneCount))
        : columnsSpin.value * cellSize
    readonly property int columns: adaptColumns.checked
        ? Math.max(4, Math.floor(paneWidth / cellSize))
        : columnsSpin.value
    // ink target inside the cell, as the picker uses it today
    readonly property int emojiSize: Math.round(root.cellSize * 32 / 44)
    readonly property int headerHeight: 24
    // 0 = one chunk per category; otherwise the largest node is this many glyphs
    readonly property int chunkSize: chunkSpin.value
    // Colour glyphs that cannot be painted as colour fall back to the glyph
    // outline in the Text's colour. Default black on a dark page looks like a
    // missing emoji, so the runs are tinted and the checkbox makes it obvious.
    readonly property color runColor: markFallbacks.checked ? "red" : Theme.palette.directColor1
    // Colour glyphs cannot go through the distance-field cache, but the two
    // paths use different glyph caches, so this is worth a try against the
    // glyph that fails to paint in the single-node panes.
    readonly property int runRenderType: nativeRendering.checked ? Text.NativeRendering
                                                                 : Text.QtRendering

    // what the two panes render
    readonly property var sourceModel: StatusQUtils.Emoji.emojiModel

    readonly property var filteredModel: SortFilterProxyModel {
        sourceModel: root.sourceModel
        filters: [
            AllOf {
                enabled: searchField.text !== ""
                AnyOf {
                    StatusQUtils.SearchFilter { roleName: "name"; searchPhrase: searchField.text }
                    StatusQUtils.SearchFilter { roleName: "shortname"; searchPhrase: searchField.text }
                }
            },
            AnyOf {
                ValueFilter { roleName: "skinColor"; value: "" }
                ValueFilter { roleName: "skinColor"; value: root.sourceModel.baseSkinColorName }
            }
        ]
        sorters: RoleSorter { roleName: "emoji_order" }
    }

    // exposed for tst_EmojiGridPoC and for measuring from outside
    readonly property alias rows: d.rows
    readonly property alias rowBuildMs: d.rowBuildMs
    readonly property alias wholeBuildMs: d.wholeBuildMs
    readonly property alias wholeLayoutMs: d.wholeLayoutMs
    readonly property alias categoryBlocks: d.categoryBlocks
    readonly property alias categoryBuildMs: d.categoryBuildMs
    readonly property alias relayoutMs: d.relayoutMs
    readonly property alias lazySectionsLoaded: d.lazyLoaded
    readonly property alias paragraphLayoutMs: d.paragraphLayoutMs
    readonly property alias setupResults: d.setupResults
    readonly property alias resizeResults: d.resizeResults
    function measureSetup() { d.measureSetup() }
    function measureColumnChange() { d.measureColumnChange() }
    function rowTextAt(row) { return d.rows[row].text }
    function countItemsIn(view) { return d.countItems(view.contentItem) }

    QtObject {
        id: d

        // One Text per row needs the glyphs on a fixed pitch. Every glyph in the
        // emoji font advances exactly 1 em, so pixelSize is the advance and the
        // rest of the cell is letter spacing; the leading offset centres the ink
        // in the first cell, after which k*pitch lands on every cell centre.
        readonly property int advance: Math.round(root.emojiSize / Fonts.emojiArtRatio)
        readonly property int spacing: root.cellSize - advance
        readonly property real leading: (root.cellSize - advance) / 2

        property var rows: []
        property int rowBuildMs: 0
        property string wholeCatalogue: ""
        // [{ name, text, first, count, lines, top }], one entry per category
        property var categoryBlocks: []
        property int categoryBuildMs: 0
        property int relayoutMs: 0
        property string paragraphs: ""
        property int paragraphLayoutMs: 0
        property double paragraphAssignedAt: 0
        property int wholeBuildMs: 0
        property int wholeLayoutMs: 0
        property double wholeAssignedAt: 0

        // Content and layout are separate on purpose: the strings of the
        // wrapping variants do not depend on the column count, so a resize only
        // has to recompute heights. The row variant has to re-chunk.
        function rebuildRows() {
            const started = Date.now()
            const count = root.filteredModel.count
            const perRow = root.columns
            const budget = root.chunkSize > 0 ? root.chunkSize : count

            const all = []
            const rows = []
            const chunks = []
            const categoryTexts = []

            for (let i = 0; i < count; ++i) {
                const emoji = StatusQUtils.ModelUtils.get(root.filteredModel, i, "emoji")
                const name = StatusQUtils.ModelUtils.get(root.filteredModel, i, "category")
                all.push(emoji)

                let chunk = chunks.length ? chunks[chunks.length - 1] : null
                const newCategory = !chunk || chunk.name !== name
                if (newCategory || chunk.count >= budget) {
                    chunk = { name, label: newCategory ? name : "", text: "",
                              first: i, count: 0, lines: 0, top: 0, paraTop: 0 }
                    chunks.push(chunk)
                    if (newCategory) {
                        rows.push({ header: name, text: "", first: i })
                        categoryTexts.push("")
                    }
                }
                if ((i - rows[rows.length - 1].first) % perRow === 0 && !!rows[rows.length - 1].header)
                    rows.push({ header: "", text: "", first: i })
                else if (!rows[rows.length - 1].header
                         && rows[rows.length - 1].text.length > 0
                         && (i - rows[rows.length - 1].first) >= perRow)
                    rows.push({ header: "", text: "", first: i })

                rows[rows.length - 1].text += emoji
                chunk.text += emoji
                chunk.count++
                categoryTexts[categoryTexts.length - 1] += emoji
            }

            d.rows = rows
            d.categoryBlocks = chunks
            d.rowBuildMs = Date.now() - started

            // a plain Text cannot carry the labels; kept as the baseline
            d.paragraphs = categoryTexts.join("\n")
            d.paragraphAssignedAt = Date.now()
            d.wholeCatalogue = all.join("")
            d.wholeAssignedAt = Date.now()

            relayout()
        }

        // column-dependent geometry only: no strings are touched
        function relayout() {
            const started = Date.now()
            let top = 0
            let paraTop = 0
            let lastCategory = ""
            for (const chunk of d.categoryBlocks) {
                chunk.lines = Math.ceil(chunk.count / root.columns)
                chunk.top = top
                top += (chunk.label ? root.headerHeight : 0) + chunk.lines * root.cellSize
                if (chunk.name !== lastCategory) {
                    lastCategory = chunk.name
                    chunk.paraTop = paraTop
                } else {
                    chunk.paraTop = paraTop
                }
                paraTop += chunk.lines * root.cellSize
            }
            d.categoryBlocksChanged()
            d.relayoutMs = Date.now() - started
        }

        // Items actually alive under a view, which is what the PoC is about.
        function countItems(item) {
            let n = 1
            for (let i = 0; i < item.children.length; ++i)
                n += countItems(item.children[i])
            return n
        }

        property int classicItems: 0
        property int rowsItems: 0
        property int wholeItems: 0
        property int categoryItems: 0
        property int paragraphItems: 0
        property int lazyItems: 0
        // how many sections of the lazy pane have been incubated so far
        property int lazyLoaded: 0

        // "setup time": content -> laid out and painted, measured one pane at a
        // time over two frames (blank it, then fill it and wait for the frame)
        property bool classicOn: true
        property bool rowsOn: true
        property bool categoriesOn: true
        property bool paragraphsOn: true
        property bool wholeOn: true
        property bool lazyOn: true

        property var setupQueue: []
        property string setupPhase: ""   // "", "blanking", "filling"
        property double setupStartedAt: 0
        property var setupResults: ({})

        function setOn(name, on) {
            if (name === "per-cell") classicOn = on
            else if (name === "rows") rowsOn = on
            else if (name === "categories") categoriesOn = on
            else if (name === "paragraphs") paragraphsOn = on
            else if (name === "single Text") wholeOn = on
            else if (name === "lazy") lazyOn = on
        }

        function forceLayoutOf(name) {
            if (name === "per-cell") classicGrid.forceLayout()
            else if (name === "rows") rowsView.forceLayout()
            else if (name === "categories") categoryView.forceLayout()
        }

        // What a width change costs each variant: one pane on at a time, the
        // column count stepped by one, timed to the frame that paints it.
        property var resizeQueue: []
        property string resizePhase: ""
        property double resizeStartedAt: 0
        property var resizeResults: ({})
        property int resizeBaseColumns: 0

        function onlyOn(name) {
            const names = ["per-cell", "rows", "categories", "lazy", "paragraphs", "single Text"]
            for (const other of names)
                setOn(other, other === name)
        }

        function measureColumnChange() {
            adaptColumns.checked = false
            resizeResults = ({})
            resizeBaseColumns = columnsSpin.value
            resizeQueue = ["per-cell", "rows", "categories", "lazy", "paragraphs", "single Text"]
            resizePhase = "prepare"
        }

        function nextResizeStep() {
            if (!resizeQueue.length) {
                resizePhase = ""
                for (const name of ["per-cell", "rows", "categories", "lazy", "paragraphs", "single Text"])
                    setOn(name, true)
                return
            }
            if (resizePhase === "prepare") {
                onlyOn(resizeQueue[0])
                resizePhase = "armed"
                return
            }
            if (resizePhase === "armed") {
                resizeStartedAt = Date.now()
                columnsSpin.value = resizeBaseColumns - 1
                forceLayoutOf(resizeQueue[0])
                resizePhase = "measuring"
                return
            }
            if (resizePhase === "measuring") {
                const results = resizeResults
                results[resizeQueue[0]] = Date.now() - resizeStartedAt
                resizeResults = results
                columnsSpin.value = resizeBaseColumns
                resizeQueue = resizeQueue.slice(1)
                resizePhase = "prepare"
            }
        }

        function measureSetup() {
            setupResults = ({})
            setupQueue = ["per-cell", "rows", "categories", "lazy", "paragraphs", "single Text"]
            nextSetupStep()
        }

        function nextSetupStep() {
            if (setupPhase === "" || setupPhase === "done") {
                if (!setupQueue.length) { setupPhase = ""; return }
                setOn(setupQueue[0], false)   // tear the pane's content down
                setupPhase = "blanking"
                return
            }
            if (setupPhase === "blanking") {
                setupStartedAt = Date.now()
                setOn(setupQueue[0], true)    // and build it again
                forceLayoutOf(setupQueue[0])
                setupPhase = "filling"
                return
            }
            if (setupPhase === "filling") {
                const results = setupResults
                results[setupQueue[0]] = Date.now() - setupStartedAt
                setupResults = results
                setupQueue = setupQueue.slice(1)
                setupPhase = "done"
                nextSetupStep()
            }
        }
        property string hoveredShortname: ""
        property string lastPicked: "-"
    }

    Component.onCompleted: d.rebuildRows()
    Connections {
        target: root.filteredModel
        function onCountChanged() { d.rebuildRows() }
    }
    // a resize that changes the column count re-chunks the rows; the wrapping
    // variants only need their heights recomputed
    onColumnsChanged: d.rebuildRows()
    onChunkSizeChanged: d.rebuildRows()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        ScrollView {
            id: panesScroll

            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: panesRow.implicitWidth
            clip: true

        RowLayout {
            id: panesRow
            height: panesScroll.availableHeight
            spacing: 16

            // ── current: one delegate per cell ────────────────────────────────
            ColumnLayout {
                Layout.fillHeight: true
                Layout.preferredWidth: root.columns * root.cellSize + 20
                Layout.minimumWidth: Layout.preferredWidth
                Layout.maximumWidth: Layout.preferredWidth

                Label { text: "per-cell delegates (today)"; font.bold: true }

                GridView {
                    id: classicGrid
                    objectName: "classicGrid"

                    Layout.fillHeight: true
                    Layout.preferredWidth: root.columns * root.cellSize
                    Layout.minimumWidth: Layout.preferredWidth
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    model: d.classicOn ? root.filteredModel : null
                    cellWidth: root.cellSize
                    cellHeight: root.cellSize

                    ScrollBar.vertical: ScrollBar {}

                    delegate: ItemDelegate {
                        required property var model
                        required property int index

                        width: classicGrid.cellWidth
                        height: classicGrid.cellHeight
                        padding: (root.cellSize - root.emojiSize) / 2

                        background: Rectangle {
                            radius: Theme.radius
                            color: hovered ? Theme.palette.backgroundHover : "transparent"
                        }
                        contentItem: StatusEmoji {
                            objectName: "statusEmoji_" + model.shortname.replace(/:/g, "")
                            Accessible.role: Accessible.StaticText
                            Accessible.name: model.emoji
                            emoji: model.emoji
                        }
                        onClicked: d.lastPicked = model.shortname
                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                        StatusToolTip {
                            text: model.shortname
                            visible: hovered && !!text
                            y: -height
                        }
                    }
                }
            }

            // ── PoC: one Text per row ─────────────────────────────────────────
            ColumnLayout {
                Layout.fillHeight: true
                Layout.preferredWidth: root.columns * root.cellSize + 20
                Layout.minimumWidth: Layout.preferredWidth
                Layout.maximumWidth: Layout.preferredWidth

                Label { text: "one Text per row (PoC)"; font.bold: true }

                ListView {
                    id: rowsView
                    objectName: "rowsView"

                    Layout.fillHeight: true
                    Layout.preferredWidth: root.columns * root.cellSize
                    Layout.minimumWidth: Layout.preferredWidth
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    model: d.rowsOn ? d.rows : []

                    ScrollBar.vertical: ScrollBar {}

                    // one highlight for the whole view, moved to the hovered cell
                    Rectangle {
                        parent: rowsView.contentItem
                        visible: hoverHandler.hovered && rowsView.hoveredIndex >= 0
                        x: rowsView.hoveredColumn * root.cellSize
                        y: rowsView.hoveredRowY
                        width: root.cellSize
                        height: root.cellSize
                        radius: Theme.radius
                        color: Theme.palette.backgroundHover
                        z: -1
                    }

                    property int hoveredColumn: -1
                    property int hoveredRowY: 0
                    property int hoveredIndex: -1

                    // rows are no longer uniform - a section header is shorter -
                    // so the delegate under the point decides, not arithmetic on y
                    function cellIndexAt(x, y) {
                        const column = Math.floor(x / root.cellSize)
                        if (column < 0 || column >= root.columns)
                            return -1
                        const row = rowAt(x, y)
                        if (row < 0 || row >= d.rows.length || !!d.rows[row].header)
                            return -1
                        const index = d.rows[row].first + column
                        const nextRow = row + 1 < d.rows.length ? d.rows[row + 1] : null
                        const limit = nextRow && !nextRow.header ? nextRow.first
                                                                 : d.rows[row].first + root.columns
                        return index < Math.min(limit, root.filteredModel.count) ? index : -1
                    }

                    // ListView.indexAt wants content coordinates
                    function rowAt(x, y) {
                        return rowsView.indexAt(x, y)   // ListView's own delegate lookup
                    }

                    HoverHandler {
                        id: hoverHandler
                        cursorShape: Qt.PointingHandCursor
                        onPointChanged: {
                            const pos = point.position
                            const y = pos.y + rowsView.contentY
                            rowsView.hoveredColumn = Math.floor(pos.x / root.cellSize)
                            rowsView.hoveredIndex = rowsView.cellIndexAt(pos.x, y)
                            const row = rowsView.rowAt(pos.x, y)
                            const item = row >= 0 ? rowsView.itemAtIndex(row) : null
                            rowsView.hoveredRowY = !!item ? item.y : 0
                            d.hoveredShortname = rowsView.hoveredIndex < 0 ? ""
                                : StatusQUtils.ModelUtils.get(root.filteredModel,
                                                              rowsView.hoveredIndex, "shortname")
                        }
                    }
                    TapHandler {
                        onSingleTapped: eventPoint => {
                            const index = rowsView.cellIndexAt(eventPoint.position.x,
                                                               eventPoint.position.y + rowsView.contentY)
                            if (index >= 0)
                                d.lastPicked = StatusQUtils.ModelUtils.get(root.filteredModel,
                                                                           index, "shortname")
                        }
                    }

                    delegate: DelegateChooser {
                        role: "header"

                        // a section label
                        DelegateChoice {
                            roleValue: ""
                            delegate: Text {
                                required property var modelData

                                x: d.leading
                                width: root.columns * root.cellSize
                                height: root.cellSize
                                verticalAlignment: Text.AlignVCenter
                                textFormat: Text.PlainText
                                text: modelData.text
                                color: root.runColor
                                font.family: Fonts.emojiFont.family
                                font.pixelSize: d.advance
                                font.letterSpacing: d.spacing
                                renderType: root.runRenderType
                            }
                        }

                        // anything else is a section label
                        DelegateChoice {
                            delegate: StatusBaseText {
                                required property var modelData

                                width: root.columns * root.cellSize
                                height: root.headerHeight
                                leftPadding: 2
                                verticalAlignment: Text.AlignVCenter
                                text: modelData.header
                                font.pixelSize: Theme.additionalTextSize
                                font.capitalization: Font.AllUppercase
                                color: Theme.palette.secondaryText
                            }
                        }
                    }

                    // the tooltip is one item for the view, not one per cell
                    StatusToolTip {
                        text: d.hoveredShortname
                        visible: hoverHandler.hovered && !!text
                        x: rowsView.hoveredColumn * root.cellSize
                        y: rowsView.hoveredRowY - rowsView.contentY - height
                    }
                }
            }

            // ── PoC 2: one Text for the whole catalogue ──────────────────────
            ColumnLayout {
                Layout.fillHeight: true
                Layout.preferredWidth: root.columns * root.cellSize + 20
                Layout.minimumWidth: Layout.preferredWidth
                Layout.maximumWidth: Layout.preferredWidth

                Label { text: "one Text, everything (PoC)"; font.bold: true }

                Flickable {
                    id: wholeView
                    objectName: "wholeView"

                    Layout.fillHeight: true
                    Layout.preferredWidth: root.columns * root.cellSize
                    Layout.minimumWidth: Layout.preferredWidth
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    contentWidth: width
                    contentHeight: wholeText.height

                    ScrollBar.vertical: ScrollBar {}

                    property int hoveredColumn: -1
                    property int hoveredRow: -1

                    function cellIndexAt(x, y) {
                        const column = Math.floor(x / root.cellSize)
                        const row = Math.floor(y / root.cellSize)
                        if (column < 0 || column >= root.columns || row < 0)
                            return -1
                        const index = row * root.columns + column
                        return index < root.filteredModel.count ? index : -1
                    }

                    Rectangle {
                        visible: wholeHover.hovered
                        x: wholeView.hoveredColumn * root.cellSize
                        y: wholeView.hoveredRow * root.cellSize
                        width: root.cellSize
                        height: root.cellSize
                        radius: Theme.radius
                        color: Theme.palette.backgroundHover
                    }

                    // The whole catalogue in one item: wrapping puts `columns`
                    // glyphs per line because every glyph is the same width, and
                    // a fixed line height keeps the rows on the cell pitch.
                    Text {
                        id: wholeText
                        objectName: "wholeText"

                        x: d.leading
                        // room for the trailing letter spacing of the last glyph
                        // in a line, but not for one more glyph
                        width: root.columns * root.cellSize + d.spacing
                        textFormat: Text.PlainText
                        wrapMode: Text.WrapAnywhere
                        text: d.wholeOn ? d.wholeCatalogue : ""
                        color: root.runColor
                        font.family: Fonts.emojiFont.family
                        font.pixelSize: d.advance
                        font.letterSpacing: d.spacing
                        renderType: root.runRenderType
                        lineHeight: root.cellSize
                        lineHeightMode: Text.FixedHeight
                        verticalAlignment: Text.AlignVCenter

                        onLineCountChanged: {
                            if (d.wholeAssignedAt > 0) {
                                d.wholeLayoutMs = Date.now() - d.wholeAssignedAt
                                d.wholeAssignedAt = 0
                            }
                        }
                    }

                    HoverHandler {
                        id: wholeHover
                        cursorShape: Qt.PointingHandCursor
                        onPointChanged: {
                            const pos = point.position
                            wholeView.hoveredColumn = Math.floor(pos.x / root.cellSize)
                            wholeView.hoveredRow = Math.floor((pos.y + wholeView.contentY) / root.cellSize)
                            const index = wholeView.cellIndexAt(pos.x, pos.y + wholeView.contentY)
                            d.hoveredShortname = index < 0 ? ""
                                : StatusQUtils.ModelUtils.get(root.filteredModel, index, "shortname")
                        }
                    }
                    TapHandler {
                        onSingleTapped: eventPoint => {
                            const index = wholeView.cellIndexAt(eventPoint.position.x,
                                                            eventPoint.position.y + wholeView.contentY)
                            if (index >= 0)
                                d.lastPicked = StatusQUtils.ModelUtils.get(root.filteredModel,
                                                                           index, "shortname")
                        }
                    }

                    StatusToolTip {
                        text: d.hoveredShortname
                        visible: wholeHover.hovered && !!text
                        x: wholeView.hoveredColumn * root.cellSize
                        y: wholeView.hoveredRow * root.cellSize - wholeView.contentY - height
                    }
                }
            }

            // ── PoC 3: one Text per category ─────────────────────────────────
            ColumnLayout {
                Layout.fillHeight: true
                Layout.preferredWidth: root.columns * root.cellSize + 20
                Layout.minimumWidth: Layout.preferredWidth
                Layout.maximumWidth: Layout.preferredWidth

                Label { text: "one Text per category (PoC)"; font.bold: true }

                ListView {
                    id: categoryView
                    objectName: "categoryView"

                    Layout.fillHeight: true
                    Layout.preferredWidth: root.columns * root.cellSize
                    Layout.minimumWidth: Layout.preferredWidth
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    model: d.categoriesOn ? d.categoryBlocks : []

                    ScrollBar.vertical: ScrollBar {}

                    property int hoveredColumn: -1
                    property int hoveredRow: -1

                    // y picks the category block, the rest is the same arithmetic
                    function blockAt(y) {
                        const blocks = d.categoryBlocks
                        for (let i = blocks.length - 1; i >= 0; --i)
                            if (y >= blocks[i].top)
                                return blocks[i]
                        return null
                    }

                    function cellIndexAt(x, y) {
                        const column = Math.floor(x / root.cellSize)
                        if (column < 0 || column >= root.columns || y < 0)
                            return -1
                        const block = blockAt(y)
                        if (!block)
                            return -1
                        // only the first chunk of a category carries a label
                        const header = block.label ? root.headerHeight : 0
                        const row = Math.floor((y - block.top - header) / root.cellSize)
                        if (row < 0 || row >= block.lines)
                            return -1
                        const offset = row * root.columns + column
                        return offset < block.count ? block.first + offset : -1
                    }

                    Rectangle {
                        parent: categoryView.contentItem
                        visible: categoryHover.hovered
                        x: categoryView.hoveredColumn * root.cellSize
                        y: categoryView.hoveredRow * root.cellSize
                        width: root.cellSize
                        height: root.cellSize
                        radius: Theme.radius
                        color: Theme.palette.backgroundHover
                        z: -1
                    }

                    delegate: Item {
                        required property var modelData

                        width: root.columns * root.cellSize + d.spacing
                        height: (!!modelData.label ? root.headerHeight : 0)
                                + modelData.lines * root.cellSize

                        StatusBaseText {
                            visible: !!parent.modelData.label
                            width: parent.width
                            height: parent.modelData.label ? root.headerHeight : 0
                            leftPadding: 2
                            verticalAlignment: Text.AlignVCenter
                            text: parent.modelData.label
                            font.pixelSize: Theme.additionalTextSize
                            font.capitalization: Font.AllUppercase
                            color: Theme.palette.secondaryText
                        }

                        Text {
                            x: d.leading
                            y: !!parent.modelData.label ? root.headerHeight : 0
                            width: root.columns * root.cellSize + d.spacing
                            height: parent.modelData.lines * root.cellSize
                            textFormat: Text.PlainText
                            wrapMode: Text.WrapAnywhere
                            text: parent.modelData.text
                            color: root.runColor
                            font.family: Fonts.emojiFont.family
                            font.pixelSize: d.advance
                            font.letterSpacing: d.spacing
                            renderType: root.runRenderType
                            lineHeight: root.cellSize
                            lineHeightMode: Text.FixedHeight
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    HoverHandler {
                        id: categoryHover
                        cursorShape: Qt.PointingHandCursor
                        onPointChanged: {
                            const pos = point.position
                            const y = pos.y + categoryView.contentY
                            categoryView.hoveredColumn = Math.floor(pos.x / root.cellSize)
                            categoryView.hoveredRow = Math.floor(y / root.cellSize)
                            const index = categoryView.cellIndexAt(pos.x, y)
                            d.hoveredShortname = index < 0 ? ""
                                : StatusQUtils.ModelUtils.get(root.filteredModel, index, "shortname")
                        }
                    }
                    TapHandler {
                        onSingleTapped: eventPoint => {
                            const index = categoryView.cellIndexAt(eventPoint.position.x,
                                                               eventPoint.position.y + categoryView.contentY)
                            if (index >= 0)
                                d.lastPicked = StatusQUtils.ModelUtils.get(root.filteredModel,
                                                                           index, "shortname")
                        }
                    }

                    StatusToolTip {
                        text: d.hoveredShortname
                        visible: categoryHover.hovered && !!text
                        x: categoryView.hoveredColumn * root.cellSize
                        y: categoryView.hoveredRow * root.cellSize - categoryView.contentY - height
                    }
                }
            }

            // ── PoC 4: one Text, one paragraph per category ──────────────────
            ColumnLayout {
                Layout.fillHeight: true
                Layout.preferredWidth: root.columns * root.cellSize + 20
                Layout.minimumWidth: Layout.preferredWidth
                Layout.maximumWidth: Layout.preferredWidth

                Label { text: "one Text, paragraph per category (PoC)"; font.bold: true }

                Flickable {
                    id: paragraphView
                    objectName: "paragraphView"

                    Layout.fillHeight: true
                    Layout.preferredWidth: root.columns * root.cellSize
                    Layout.minimumWidth: Layout.preferredWidth
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    contentWidth: width
                    contentHeight: paragraphText.height

                    ScrollBar.vertical: ScrollBar {}

                    property int hoveredColumn: -1
                    property int hoveredRow: -1

                    // the paragraphs break exactly where the category blocks do,
                    // so the same block geometry resolves a point
                    function cellIndexAt(x, y) {
                        const column = Math.floor(x / root.cellSize)
                        if (column < 0 || column >= root.columns || y < 0)
                            return -1
                        const blocks = d.categoryBlocks
                        let block = null
                        for (let i = blocks.length - 1; i >= 0; --i)
                            if (y >= blocks[i].paraTop) { block = blocks[i]; break }
                        if (!block)
                            return -1
                        // a plain Text has no labels, so the block's label-less top
                        const row = Math.floor((y - block.paraTop) / root.cellSize)
                        if (row < 0 || row >= block.lines)
                            return -1
                        const offset = row * root.columns + column
                        return offset < block.count ? block.first + offset : -1
                    }

                    Rectangle {
                        visible: paragraphHover.hovered
                        x: paragraphView.hoveredColumn * root.cellSize
                        y: paragraphView.hoveredRow * root.cellSize
                        width: root.cellSize
                        height: root.cellSize
                        radius: Theme.radius
                        color: Theme.palette.backgroundHover
                    }

                    Text {
                        id: paragraphText
                        objectName: "paragraphText"

                        x: d.leading
                        width: root.columns * root.cellSize + d.spacing
                        textFormat: Text.PlainText
                        wrapMode: Text.WrapAnywhere
                        text: d.paragraphsOn ? d.paragraphs : ""
                        color: root.runColor
                        font.family: Fonts.emojiFont.family
                        font.pixelSize: d.advance
                        font.letterSpacing: d.spacing
                        renderType: root.runRenderType
                        lineHeight: root.cellSize
                        lineHeightMode: Text.FixedHeight
                        verticalAlignment: Text.AlignVCenter

                        onLineCountChanged: {
                            if (d.paragraphAssignedAt > 0) {
                                d.paragraphLayoutMs = Date.now() - d.paragraphAssignedAt
                                d.paragraphAssignedAt = 0
                            }
                        }
                    }

                    HoverHandler {
                        id: paragraphHover
                        cursorShape: Qt.PointingHandCursor
                        onPointChanged: {
                            const pos = point.position
                            const y = pos.y + paragraphView.contentY
                            paragraphView.hoveredColumn = Math.floor(pos.x / root.cellSize)
                            paragraphView.hoveredRow = Math.floor(y / root.cellSize)
                            const index = paragraphView.cellIndexAt(pos.x, y)
                            d.hoveredShortname = index < 0 ? ""
                                : StatusQUtils.ModelUtils.get(root.filteredModel, index, "shortname")
                        }
                    }
                    TapHandler {
                        onSingleTapped: eventPoint => {
                            const index = paragraphView.cellIndexAt(eventPoint.position.x,
                                                                eventPoint.position.y + paragraphView.contentY)
                            if (index >= 0)
                                d.lastPicked = StatusQUtils.ModelUtils.get(root.filteredModel,
                                                                           index, "shortname")
                        }
                    }

                    StatusToolTip {
                        text: d.hoveredShortname
                        visible: paragraphHover.hovered && !!text
                        x: paragraphView.hoveredColumn * root.cellSize
                        y: paragraphView.hoveredRow * root.cellSize - paragraphView.contentY - height
                    }
                }
            }

            // ── PoC 5: Flickable + Column of async Loaders, one per chunk ────
            //
            // The heights are known before anything is loaded (lines = count /
            // columns), so the content height and the scrollbar are exact from
            // the first frame; each chunk's Text is incubated asynchronously the
            // first time it comes near the viewport, and then kept.
            ColumnLayout {
                Layout.fillHeight: true
                Layout.preferredWidth: root.columns * root.cellSize + 20
                Layout.minimumWidth: Layout.preferredWidth
                Layout.maximumWidth: Layout.preferredWidth

                Label {
                    text: `Flickable + async Loaders (PoC) - ${d.lazyLoaded}/${d.categoryBlocks.length} sections loaded`
                    font.bold: true
                }

                Flickable {
                    id: lazyView
                    objectName: "lazyView"

                    Layout.fillHeight: true
                    Layout.preferredWidth: root.columns * root.cellSize
                    Layout.minimumWidth: Layout.preferredWidth
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    contentWidth: width
                    contentHeight: lazyColumn.height

                    ScrollBar.vertical: ScrollBar {}

                    property int hoveredColumn: -1
                    property int hoveredRow: -1

                    function cellIndexAt(x, y) {
                        const column = Math.floor(x / root.cellSize)
                        if (column < 0 || column >= root.columns || y < 0)
                            return -1
                        const blocks = d.categoryBlocks
                        let block = null
                        for (let i = blocks.length - 1; i >= 0; --i)
                            if (y >= blocks[i].top) { block = blocks[i]; break }
                        if (!block)
                            return -1
                        const header = block.label ? root.headerHeight : 0
                        const row = Math.floor((y - block.top - header) / root.cellSize)
                        if (row < 0 || row >= block.lines)
                            return -1
                        const offset = row * root.columns + column
                        return offset < block.count ? block.first + offset : -1
                    }

                    Column {
                        id: lazyColumn
                        width: lazyView.width

                        Repeater {
                            model: d.lazyOn ? d.categoryBlocks : []

                            delegate: Item {
                                id: section

                                required property var modelData

                                width: lazyColumn.width
                                height: (!!modelData.label ? root.headerHeight : 0)
                                        + modelData.lines * root.cellSize

                                // latched: once it has been near the viewport it stays loaded
                                property bool reached: false
                                // Checked directly, not through Qt.callLater: the
                                // chunk table already knows where this section sits,
                                // so there is nothing to wait for - and a delayed
                                // call can outlive the delegate, which leaves the
                                // ids it captured unresolvable.
                                Component.onCompleted: check()

                                function check() {
                                    if (reached)
                                        return
                                    const prefetch = root.cellSize * 4
                                    const first = lazyView.contentY - prefetch
                                    const last = lazyView.contentY + lazyView.height + prefetch
                                    const top = modelData.top
                                    if (top + height >= first && top <= last)
                                        reached = true
                                }

                                Connections {
                                    target: lazyView
                                    function onContentYChanged() { section.check() }
                                    function onHeightChanged() { section.check() }
                                }

                                StatusBaseText {
                                    visible: !!section.modelData.label
                                    width: parent.width
                                    height: section.modelData.label ? root.headerHeight : 0
                                    leftPadding: 2
                                    verticalAlignment: Text.AlignVCenter
                                    text: section.modelData.label
                                    font.pixelSize: Theme.additionalTextSize
                                    font.capitalization: Font.AllUppercase
                                    color: Theme.palette.secondaryText
                                }

                                Loader {
                                    y: !!section.modelData.label ? root.headerHeight : 0
                                    width: root.columns * root.cellSize + d.spacing
                                    height: section.modelData.lines * root.cellSize
                                    asynchronous: true
                                    active: section.reached
                                    onLoaded: d.lazyLoaded++
                                    Component.onDestruction: {
                                        // typeof: during teardown the ids a delegate
                                        // captured may no longer resolve
                                        if (status === Loader.Ready && typeof d !== "undefined")
                                            d.lazyLoaded--
                                    }

                                    sourceComponent: Text {
                                        x: d.leading
                                        textFormat: Text.PlainText
                                        wrapMode: Text.WrapAnywhere
                                        text: section.modelData.text
                                        color: root.runColor
                                        font.family: Fonts.emojiFont.family
                                        font.pixelSize: d.advance
                                        font.letterSpacing: d.spacing
                                        renderType: root.runRenderType
                                        lineHeight: root.cellSize
                                        lineHeightMode: Text.FixedHeight
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        visible: lazyHover.hovered
                        x: lazyView.hoveredColumn * root.cellSize
                        y: lazyView.hoveredRow * root.cellSize
                        width: root.cellSize
                        height: root.cellSize
                        radius: Theme.radius
                        color: Theme.palette.backgroundHover
                        z: -1
                    }

                    HoverHandler {
                        id: lazyHover
                        cursorShape: Qt.PointingHandCursor
                        onPointChanged: {
                            const pos = point.position
                            const y = pos.y + lazyView.contentY
                            lazyView.hoveredColumn = Math.floor(pos.x / root.cellSize)
                            lazyView.hoveredRow = Math.floor(y / root.cellSize)
                            const index = lazyView.cellIndexAt(pos.x, y)
                            d.hoveredShortname = index < 0 ? ""
                                : StatusQUtils.ModelUtils.get(root.filteredModel, index, "shortname")
                        }
                    }
                    TapHandler {
                        onSingleTapped: eventPoint => {
                            const index = lazyView.cellIndexAt(eventPoint.position.x,
                                                               eventPoint.position.y + lazyView.contentY)
                            if (index >= 0)
                                d.lastPicked = StatusQUtils.ModelUtils.get(root.filteredModel,
                                                                           index, "shortname")
                        }
                    }
                }
            }

            Item { Layout.preferredWidth: 1 }
        }
        }

        // ── controls and measurements ─────────────────────────────────────────
        Frame {
            Layout.fillWidth: true

            GridLayout {
                anchors.fill: parent
                columns: 6
                columnSpacing: 12

                Label { text: "cell" }
                SpinBox { id: cellSizeSpin; from: 20; to: 96; value: 44; stepSize: 4 }
                Label { text: "chunk" }
                SpinBox {
                    id: chunkSpin
                    objectName: "chunkSpin"
                    from: 0; to: 2000; stepSize: 64; value: 0
                    ToolTip.text: "0 = one Text per category; otherwise the largest text node"
                    ToolTip.visible: hovered
                }
                Label { text: "columns" }
                SpinBox { id: columnsSpin; from: 4; to: 16; value: 8 }
                CheckBox {
                    id: adaptColumns
                    text: "adapt to width"
                    checked: true
                    ToolTip.text: "columns follow the available width instead of the spinbox"
                    ToolTip.visible: hovered
                }
                CheckBox {
                    id: nativeRendering
                    text: "native text rendering"
                    ToolTip.text: "Text.NativeRendering instead of Text.QtRendering for the runs"
                    ToolTip.visible: hovered
                }
                CheckBox {
                    id: markFallbacks
                    text: "mark fallback glyphs"
                    ToolTip.text: "paints the runs red: any emoji drawn as a red shape " +
                                  "fell back from the colour path to its outline"
                    ToolTip.visible: hovered
                }
                Label { text: "search" }
                TextField { id: searchField; objectName: "poCSearchField"; Layout.fillWidth: true; placeholderText: "shortname or name" }

                Button {
                    text: "Count items"
                    onClicked: {
                        d.classicItems = d.countItems(classicGrid.contentItem)
                        d.rowsItems = d.countItems(rowsView.contentItem)
                        d.wholeItems = d.countItems(wholeView.contentItem)
                        d.categoryItems = d.countItems(categoryView.contentItem)
                        d.paragraphItems = d.countItems(paragraphView.contentItem)
                        d.lazyItems = d.countItems(lazyView.contentItem)
                    }
                }
                Label {
                    Layout.columnSpan: 5
                    text: d.classicItems === 0 ? "items: press Count"
                        : `items alive - per-cell: ${d.classicItems}, rows: ${d.rowsItems}, ` +
                          `chunks: ${d.categoryItems}, lazy: ${d.lazyItems}, ` +
                          `paragraphs: ${d.paragraphItems}, ` +
                          `single Text: ${d.wholeItems}`
                }

                Button {
                    text: "Measure column change"
                    ToolTip.text: "one pane at a time: step the column count and time the repaint"
                    ToolTip.visible: hovered
                    onClicked: d.measureColumnChange()
                }
                Label {
                    Layout.columnSpan: 5
                    text: {
                        const names = ["per-cell", "rows", "categories", "lazy", "paragraphs", "single Text"]
                        const parts = names.filter(n => d.resizeResults[n] !== undefined)
                                           .map(n => `${n}: ${d.resizeResults[n]} ms`)
                        return parts.length ? "column change -- " + parts.join(", ")
                                            : "column change: press Measure"
                    }
                }

                Button {
                    text: "Measure setup"
                    ToolTip.text: "blanks each pane and times content -> painted frame"
                    ToolTip.visible: hovered
                    onClicked: d.measureSetup()
                }
                Label {
                    Layout.columnSpan: 5
                    text: {
                        const names = ["per-cell", "rows", "categories", "lazy", "paragraphs", "single Text"]
                        const parts = names.filter(n => d.setupResults[n] !== undefined)
                                           .map(n => `${n}: ${d.setupResults[n]} ms`)
                        return parts.length ? "setup -- " + parts.join(", ")
                                            : "setup: press Measure"
                    }
                }

                Button {
                    text: "Scroll both"
                    onClicked: {
                        meter.reset()
                        scrollClassic.restart()
                        scrollRows.restart()
                        scrollWhole.restart()
                        scrollCategories.restart()
                        scrollParagraphs.restart()
                        scrollLazy.restart()
                    }
                }
                Label {
                    Layout.columnSpan: 5
                    text: `rows: ${d.rows.length} (built in ${d.rowBuildMs} ms) | ` +
                          `entries: ${root.filteredModel.count} | ` +
                          `whole string laid out in ${d.wholeLayoutMs} ms (${wholeText.lineCount} lines) | ` +
                          `${d.categoryBlocks.length} chunks, relayout ${d.relayoutMs} ms | ` +
                          `paragraphs laid out in ${d.paragraphLayoutMs} ms | ` +
                          `lazy sections loaded: ${d.lazyLoaded}/${d.categoryBlocks.length} | ` +
                          `frames: ${meter.frames}, janky: ${meter.janky}, worst: ${meter.worst.toFixed(1)} ms | ` +
                          `hovered: ${d.hoveredShortname || "-"} | picked: ${d.lastPicked}`
                }
            }
        }
    }

    NumberAnimation {
        id: scrollLazy
        target: lazyView; property: "contentY"; duration: 3000
        from: 0; to: Math.max(0, lazyView.contentHeight - lazyView.height)
    }

    NumberAnimation {
        id: scrollParagraphs
        target: paragraphView; property: "contentY"; duration: 3000
        from: 0; to: Math.max(0, paragraphView.contentHeight - paragraphView.height)
    }

    // ── diagnostics for the glyph that does not paint on the desktop run ──
    //
    // :low_brightness: (U+1F505) comes out as two "?" in the single-Text pane
    // while rendering fine per cell. Offscreen everything measures 1 em and
    // paints, so these readouts are here to say what the desktop run does.
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 8
        width: diagnostics.implicitWidth + 24
        height: diagnostics.implicitHeight + 16
        color: Theme.palette.baseColor4
        border.width: 1
        border.color: Theme.palette.baseColor2
        radius: 4

        RowLayout {
            id: diagnostics
            anchors.centerIn: parent
            spacing: 12

            // the same two glyphs on their own, outside any long run
            Text {
                text: "\u{1F505}\u{1F506}"
                color: root.runColor
                font.family: Fonts.emojiFont.family
                font.pixelSize: 32
            }
            TextMetrics {
                id: dimMetrics
                font.family: Fonts.emojiFont.family
                font.pixelSize: 100
                text: "\u{1F505}"
            }
            TextMetrics {
                id: brightMetrics
                font.family: Fonts.emojiFont.family
                font.pixelSize: 100
                text: "\u{1F506}"
            }
            Label {
                text: `1F505 advance ${dimMetrics.advanceWidth.toFixed(0)} / ` +
                      `1F506 advance ${brightMetrics.advanceWidth.toFixed(0)} ` +
                      `(100 = one glyph, 200 = two)`
                color: Theme.palette.directColor1
            }
        }
    }

    NumberAnimation {
        id: scrollClassic
        target: classicGrid; property: "contentY"; duration: 3000
        from: 0; to: Math.max(0, classicGrid.contentHeight - classicGrid.height)
    }
    NumberAnimation {
        id: scrollRows
        target: rowsView; property: "contentY"; duration: 3000
        from: 0; to: Math.max(0, rowsView.contentHeight - rowsView.height)
    }

    NumberAnimation {
        id: scrollWhole
        target: wholeView; property: "contentY"; duration: 3000
        from: 0; to: Math.max(0, wholeView.contentHeight - wholeView.height)
    }

    NumberAnimation {
        id: scrollCategories
        target: categoryView; property: "contentY"; duration: 3000
        from: 0; to: Math.max(0, categoryView.contentHeight - categoryView.height)
    }

    FrameAnimation {
        id: meter
        running: true

        property int frames: 0
        property int janky: 0
        property real worst: 0

        function reset() { frames = 0; janky = 0; worst = 0 }

        onTriggered: {
            if (d.setupPhase === "blanking" || d.setupPhase === "filling")
                d.nextSetupStep()
            if (d.resizePhase !== "")
                d.nextResizeStep()

            const ms = frameTime * 1000
            if (frames === 0 && ms > 100) // first frame after a reset
                return
            frames++
            worst = Math.max(worst, ms)
            if (ms > 33.4)
                janky++
        }
    }
}

// category: Components
// status: good
