import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core.Utils as StatusQUtils

import shared.controls

/*
 The emoji grid as proposed in #22874, on its own.

 A Flickable over a Column of asynchronous Loaders, one per section, where a
 section is a category of the catalogue. Each section is a single wrapping
 Text: every glyph in the emoji font advances exactly one em, so letterSpacing
 supplies the cell pitch and arithmetic supplies the hit test.

 All of the content comes from one call - StatusEmojiModel.sections(filter) -
 which hands back each section's name and its emoji as a single string. There
 is no filtering proxy and no per-row model read, so a keystroke costs that one
 call instead of a re-filter plus a walk over every entry.

 Heights come from the entry count rather than from what has been laid out, so
 the content height - and the scrollbar - are right before anything loads, the
 column count can follow the width for the price of a height recomputation,
 and the scroll position survives it.
*/
Item {
    id: root

    readonly property int cellSize: 44
    readonly property int emojiSize: 32
    readonly property int headerHeight: 24

    readonly property int columns: Math.max(4, Math.floor(grid.width / cellSize))

    readonly property var emojiModel: StatusQUtils.Emoji.emojiModel

    // exposed for tst_EmojiSectionGrid
    readonly property alias sections: d.sections
    readonly property alias total: d.total
    readonly property alias loadedSections: d.loadedSections
    readonly property alias rebuildCount: d.rebuildCount
    readonly property alias rebuildMs: d.rebuildMs
    readonly property alias readsPerRebuild: d.readsPerRebuild
    property alias searchString: searchBox.text

    // What the sections look like to the view. It is kept in step row by row -
    // see sync() - so a keystroke never destroys a delegate.
    ListModel {
        id: sectionsModel
    }

    QtObject {
        id: d

        // Every glyph advances one em, so pixelSize is the advance and the rest
        // of the cell is letter spacing; the leading offset centres the ink in
        // the first cell, after which k * pitch lands on every cell centre.
        readonly property int advance: Math.round(root.emojiSize / Fonts.emojiArtRatio)
        readonly property int spacing: root.cellSize - advance
        readonly property real leading: (root.cellSize - advance) / 2

        // [{ name, text, count, rows, lines, top }]
        property var sections: []
        property int total: 0
        // bumped once the section tops are up to date again, so the sections can
        // re-test themselves against the viewport after a column change
        property int layoutGeneration: 0
        property int loadedSections: 0
        property int rebuildCount: 0
        property real rebuildMs: 0
        // model rows read since the last rebuild started: building the grid must
        // read none, only a hover or a click does
        property int reads: 0
        property int readsPerRebuild: 0
        property string hoveredShortname: ""
        property string lastPicked: "-"

        // the only model read in the page: one row, one role
        function read(row, role) {
            d.reads++
            return StatusQUtils.ModelUtils.get(root.emojiModel, row, role)
        }

        function rebuild() {
            const started = Date.now()
            d.reads = 0

            const previous = d.sections
            const sections = []
            let total = 0
            for (const section of root.emojiModel.sections(searchBox.text)) {
                sections.push({ name: section.name, text: section.text,
                                count: section.count, rows: section.rows,
                                lines: 0, top: 0 })
                total += section.count
            }
            // laid out before it is published: a section asked to check itself
            // against the viewport before it has a `top` would see itself at the
            // very top and load
            relayout(sections)
            d.sections = sections
            d.total = total
            sync(previous, sections)

            d.readsPerRebuild = d.reads
            d.rebuildMs = Date.now() - started
            d.rebuildCount++
        }

        // Row by row, and only where something actually changed. Replacing the
        // model instead - or handing a Repeater a new array - destroys every
        // delegate, and the asynchronous loaders then leave the grid blank for a
        // frame or two: the content blinks on every keystroke.
        function sync(previous, sections) {
            for (let i = 0; i < sections.length; ++i) {
                const section = sections[i]
                const old = i < previous.length ? previous[i] : null
                if (!old) {
                    sectionsModel.append({ sectionName: section.name,
                                           glyphs: section.text,
                                           count: section.count })
                    continue
                }
                if (old.name !== section.name)
                    sectionsModel.setProperty(i, "sectionName", section.name)
                if (old.count !== section.count)
                    sectionsModel.setProperty(i, "count", section.count)
                if (old.text !== section.text)
                    sectionsModel.setProperty(i, "glyphs", section.text)
            }
            if (sectionsModel.count > sections.length)
                sectionsModel.remove(sections.length,
                                     sectionsModel.count - sections.length)
        }

        function topOf(index) {
            return index < d.sections.length ? d.sections[index].top : 0
        }

        // geometry only: this is all a width change has to run
        function relayout(sections) {
            let top = 0
            for (const section of sections) {
                section.lines = Math.ceil(section.count / root.columns)
                section.top = top
                top += root.headerHeight + section.lines * root.cellSize
            }
            d.layoutGeneration++
        }

        function sectionAt(y) {
            for (let i = d.sections.length - 1; i >= 0; --i)
                if (y >= d.sections[i].top)
                    return d.sections[i]
            return null
        }
    }

    Component.onCompleted: d.rebuild()
    onColumnsChanged: d.relayout(d.sections)
    onSearchStringChanged: d.rebuild()

    Connections {
        target: root.emojiModel
        // the catalogue is parsed lazily, and recents can arrive later
        function onEmojiJsonChanged() { Qt.callLater(d.rebuild) }
        function onRecentEmojisChanged() { Qt.callLater(d.rebuild) }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        SearchBox {
            objectName: "emojiSearchBox"
            id: searchBox

            Layout.fillWidth: true
            Layout.maximumWidth: 420
            height: 36
        }

        Flickable {
            id: grid
            objectName: "emojiGrid"

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: 420
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            contentWidth: width
            contentHeight: sections.height

            ScrollBar.vertical: StatusScrollBar {}

            // the hovered cell, in content coordinates
            property int hoveredX: 0
            property int hoveredY: 0
            property int hoveredModelRow: -1

            // A point resolves without asking any item: the section table knows
            // where every section sits, and the cells are on a fixed pitch.
            // Returns { x, y, row } - the cell's top left in content coordinates
            // and the row of the emoji model drawn there - or null.
            function cellAt(x, y) {
                const column = Math.floor(x / root.cellSize)
                if (column < 0 || column >= root.columns || y < 0)
                    return null
                const section = d.sectionAt(y)
                if (!section)
                    return null
                // the section's own header is not part of its grid, which is why
                // a cell cannot be found by dividing y by the cell size alone
                const top = section.top + root.headerHeight
                const line = Math.floor((y - top) / root.cellSize)
                if (line < 0 || line >= section.lines)
                    return null
                const offset = line * root.columns + column
                if (offset >= section.count)
                    return null
                return { x: column * root.cellSize, y: top + line * root.cellSize,
                         row: section.rows[offset] }
            }

            // the row of the emoji model drawn at this point, or -1
            function cellIndexAt(x, y) {
                const cell = cellAt(x, y)
                return cell ? cell.row : -1
            }

            Column {
                id: sections
                width: grid.width

                Repeater {
                    model: sectionsModel

                    delegate: Item {
                        id: section

                        required property int index
                        required property string sectionName
                        required property string glyphs
                        required property int count

                        // Derived here rather than read from the section table so
                        // that a column change re-lays the sections out through
                        // bindings - the entries themselves do not change, so
                        // nothing is re-created and nothing is loaded again.
                        readonly property int lines: Math.ceil(count / root.columns)

                        width: sections.width
                        height: root.headerHeight + lines * root.cellSize

                        // Latched on the section's own top, not on y: a Column
                        // positions its children after creating them, so every
                        // section would briefly report y == 0 and load at once.
                        property bool reached: false
                        Component.onCompleted: check()

                        function check() {
                            if (reached)
                                return
                            const prefetch = root.cellSize * 4
                            const first = grid.contentY - prefetch
                            const last = grid.contentY + grid.height + prefetch
                            const top = d.topOf(section.index)
                            if (top + height >= first && top <= last)
                                reached = true
                        }

                        Connections {
                            target: grid
                            function onContentYChanged() { section.check() }
                            function onHeightChanged() { section.check() }
                        }

                        Connections {
                            target: d
                            function onLayoutGenerationChanged() { section.check() }
                        }

                        StatusBaseText {
                            width: parent.width
                            height: root.headerHeight
                            leftPadding: 2
                            verticalAlignment: Text.AlignVCenter
                            text: section.sectionName
                            font.pixelSize: Theme.additionalTextSize
                            font.capitalization: Font.AllUppercase
                            color: Theme.palette.secondaryText
                        }

                        Loader {
                            y: root.headerHeight
                            width: root.columns * root.cellSize + d.spacing
                            height: section.lines * root.cellSize
                            asynchronous: true
                            active: section.reached

                            onLoaded: d.loadedSections++
                            Component.onDestruction: {
                                // during teardown the ids a delegate captured
                                // may no longer resolve
                                if (status === Loader.Ready && typeof d !== "undefined")
                                    d.loadedSections--
                            }

                            sourceComponent: Text {
                                objectName: "emojiRun"
                                x: d.leading
                                textFormat: Text.PlainText
                                wrapMode: Text.WrapAnywhere
                                text: section.glyphs
                                color: Theme.palette.directColor1
                                font.family: Fonts.emojiFont.family
                                font.pixelSize: d.advance
                                font.letterSpacing: d.spacing
                                lineHeight: root.cellSize
                                lineHeightMode: Text.FixedHeight
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }

            Rectangle {
                objectName: "hoverHighlight"

                visible: grid.hoveredModelRow >= 0
                x: grid.hoveredX
                y: grid.hoveredY
                width: root.cellSize
                height: root.cellSize
                radius: Theme.radius
                color: Theme.palette.backgroundHover
                z: -1
            }

            // A handler declared inside a Flickable attaches to its contentItem,
            // so the positions it reports are already content coordinates - the
            // space the section table and the highlight work in. Adding contentY
            // to them counts the scroll twice.
            HoverHandler {
                id: hover
                cursorShape: Qt.PointingHandCursor
                onPointChanged: grid.hover(point.position)
                onHoveredChanged: if (!hovered) grid.hover(null)
            }

            function hover(position) {
                const cell = position ? cellAt(position.x, position.y) : null
                hoveredModelRow = cell ? cell.row : -1
                if (!cell) {
                    d.hoveredShortname = ""
                    return
                }
                hoveredX = cell.x
                hoveredY = cell.y
                d.hoveredShortname = d.read(cell.row, "shortname")
            }

            TapHandler {
                onSingleTapped: eventPoint => {
                    const cell = grid.cellAt(eventPoint.position.x, eventPoint.position.y)
                    if (cell)
                        d.lastPicked = d.read(cell.row, "shortname")
                }
            }

            StatusToolTip {
                objectName: "hoverTooltip"

                text: d.hoveredShortname
                visible: hover.hovered && !!text
                x: grid.hoveredX
                y: grid.hoveredY - grid.contentY - height
            }
        }

        Label {
            Layout.fillWidth: true
            color: Theme.palette.secondaryText
            text: `${d.total} emoji in ${d.sections.length} sections | ` +
                  `${root.columns} columns | ${d.loadedSections} loaded | ` +
                  `sections(): ${d.rebuildMs} ms | ` +
                  `hovered: ${d.hoveredShortname || "-"} | picked: ${d.lastPicked}`
        }
    }
}

// category: Components
// status: good
