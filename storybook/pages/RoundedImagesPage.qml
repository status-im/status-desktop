pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts

import StatusQ.Components

/*
  Prototype comparison of ways of rounding an image's corners:

    plain    an Image with no rounding - the floor everything is measured against
    layer    what chat images do today (StatusImageMessage): the image is
             rendered into a layer, a mask is rendered into a second one, and
             a MultiEffect combines them
    shader   StatusShaderRoundedImage: one ShaderEffect samples the image's
             own texture and computes the rounded edge itself
    shape    StatusShapeRoundedImage: a rounded PathRectangle filled with the
             image's texture (ShapePath.fillItem), curve renderer

  The top row shows one large sample of each with a magnified corner; the grid
  below holds `count` images of the chosen technique, all alive at once, as the
  rows of a chat window are.

  The metrics are the process' own: frames presented, and - on Linux with a DRM
  driver that reports per-client stats (i915, xe, amdgpu, ...) - GPU memory and
  GPU busy time from /proc/self/fdinfo. Reading those needs
  QML_XHR_ALLOW_FILE_READ=1. Run with vsync off (Mesa: vblank_mode=0) for the
  frame rates to mean anything; GPU time per frame is meaningful either way.

  "Run benchmark" measures every technique in turn: build time, memory, and
  the cost of a frame when nothing changes, while scrolling, while the images
  are resized and while they are animated GIFs.
*/
SplitView {
    id: root

    readonly property var techniques: ["plain", "layer", "shader", "shape"]
    readonly property var techniqueNames: ({
        plain: "Plain Image (no rounding)",
        layer: "Layer + MultiEffect mask (current)",
        shader: "ShaderEffect",
        shape: "Shape fillItem"
    })

    property string technique: "shader"
    property int imageCount: 100
    property real cellSize: 144
    // Decoding follows the cell size, except while the benchmark animates it.
    property real decodeCellSize: cellSize
    property real radius: 16
    // The chat bubble's tail: a small bottom-left corner.
    property bool tail: true
    property int fillMode: Image.PreserveAspectCrop
    property bool animated: false
    // A distinct pixmap per cell, as distinct photos in a chat are; otherwise
    // every cell shares one texture.
    property bool uniqueSources: true
    property bool scrolling: false
    property bool showComparison: true

    property url stillSource: Qt.resolvedUrl("../testData/image_example.png")
    property url animatedSource: Qt.resolvedUrl("../testData/image_example_animated.gif")

    // Cells the benchmark builds.
    property int benchmarkCount: 200
    // Techniques it measures, in turn. GPU memory and RSS deltas are exact
    // only for the first one in a process: freed texture-atlas pages and heap
    // are reused by the next technique rather than returned.
    property var benchmarkTechniques: techniques
    // Measures GIFs (playback, scroll) instead of stills (redraw, scroll,
    // resize).
    property bool benchmarkAnimated: false

    readonly property alias benchmarkRunning: bench.running
    readonly property alias benchmarkResults: bench.results
    readonly property alias benchmarkReport: bench.report

    signal benchmarkFinished()

    function runBenchmark() {
        bench.start()
    }

    readonly property real devicePixelRatio: root.Window.window
                                             ? root.Window.window.devicePixelRatio : 1
    readonly property size decodeSize: fillMode === Image.PreserveAspectCrop
        ? Qt.size(Math.ceil(decodeCellSize * devicePixelRatio), Math.ceil(decodeCellSize * devicePixelRatio))
        : Qt.size(Math.ceil(decodeCellSize * devicePixelRatio), 0)

    readonly property real cornerRadius: radius
    readonly property real tailRadius: tail ? Math.min(4, radius) : radius

    function sourceFor(index) {
        const base = (animated ? animatedSource : stillSource).toString()
        // the query only keys the pixmap cache; a local file loads without it
        return uniqueSources ? `${base}?cell=${index}` : base
    }

    function readyCount() {
        let n = 0
        for (let i = 0; i < cells.count; ++i) {
            const cell = cells.itemAt(i)
            if (cell && cell.ready)
                ++n
        }
        return n
    }

    // An Image, or an AnimatedImage for animated sources.
    component CellImage: Loader {
        id: cellImage

        property url imageSource

        readonly property int status: item ? item.status : Image.Null
        readonly property real paintedWidth: item ? item.paintedWidth : 0
        readonly property real paintedHeight: item ? item.paintedHeight : 0

        sourceComponent: root.animated ? animatedImage : stillImage

        Component {
            id: stillImage

            Image {
                source: cellImage.imageSource
                sourceSize: root.decodeSize
                fillMode: root.fillMode
                asynchronous: true
            }
        }

        Component {
            id: animatedImage

            AnimatedImage {
                source: cellImage.imageSource
                sourceSize: root.decodeSize
                fillMode: root.fillMode
                asynchronous: true
            }
        }
    }

    // What StatusImageMessage does: the painted image rendered into a layer,
    // masked by a second layer holding the rounded shape.
    component LayerMaskedImage: Item {
        id: layered

        property url imageSource

        readonly property int status: image.status

        Item {
            id: box

            anchors.centerIn: parent
            width: root.fillMode === Image.PreserveAspectCrop ? layered.width : image.paintedWidth
            height: root.fillMode === Image.PreserveAspectCrop ? layered.height : image.paintedHeight

            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
                maskSource: Rectangle {
                    parent: layered
                    width: box.width
                    height: box.height
                    visible: false
                    layer.enabled: true

                    topLeftRadius: root.cornerRadius
                    topRightRadius: root.cornerRadius
                    bottomRightRadius: root.cornerRadius
                    bottomLeftRadius: root.tailRadius
                }
            }

            CellImage {
                id: image

                anchors.centerIn: parent
                width: layered.width
                height: layered.height
                imageSource: layered.imageSource
            }
        }
    }

    component Technique: Loader {
        id: techniqueLoader

        property string technique
        property url imageSource

        readonly property bool ready: item !== null && item.status === Image.Ready

        sourceComponent: {
            switch (technique) {
            case "plain": return plainComponent
            case "layer": return layerComponent
            case "shader": return shaderComponent
            case "shape": return shapeComponent
            }
            return null
        }

        Component {
            id: plainComponent

            CellImage {
                imageSource: techniqueLoader.imageSource
            }
        }

        Component {
            id: layerComponent

            LayerMaskedImage {
                imageSource: techniqueLoader.imageSource
            }
        }

        Component {
            id: shaderComponent

            StatusShaderRoundedImage {
                source: techniqueLoader.imageSource
                animated: root.animated
                fillMode: root.fillMode
                sourceSize: root.decodeSize
                radius: root.cornerRadius
                bottomLeftRadius: root.tailRadius
            }
        }

        Component {
            id: shapeComponent

            StatusShapeRoundedImage {
                source: techniqueLoader.imageSource
                animated: root.animated
                fillMode: root.fillMode
                sourceSize: root.decodeSize
                radius: root.cornerRadius
                bottomLeftRadius: root.tailRadius
            }
        }
    }

    // Per-process GPU stats from the DRM fdinfo, and the resident set.
    QtObject {
        id: stats

        property bool fileReadable: true
        property var drmFds: null

        function read(path) {
            if (!fileReadable)
                return ""
            try {
                const xhr = new XMLHttpRequest()
                xhr.open("GET", "file://" + path, false)
                xhr.send()
                return xhr.responseText || ""
            } catch (e) {
                return ""
            }
        }

        function rssKiB() {
            const status = read("/proc/self/status")
            if (!status) {
                fileReadable = false
                return NaN
            }
            const m = /VmRSS:\s+(\d+)/.exec(status)
            return m ? parseInt(m[1]) : NaN
        }

        function toKiB(value, unit) {
            const v = parseInt(value)
            switch (unit) {
            case "MiB": return v * 1024
            case "GiB": return v * 1024 * 1024
            case "KiB": return v
            default: return v / 1024 // plain bytes
            }
        }

        // One fd per DRM client: a client's fds all report the same numbers.
        function discover() {
            drmFds = []
            const seen = {}
            for (let fd = 0; fd < 512; ++fd) {
                const info = read("/proc/self/fdinfo/" + fd)
                const m = /drm-client-id:\s*(\d+)/.exec(info)
                if (m && !seen[m[1]]) {
                    seen[m[1]] = true
                    drmFds.push(fd)
                }
            }
        }

        // { memKiB, engineNs }, or null where the driver reports nothing.
        function gpu() {
            if (!fileReadable)
                return null
            if (drmFds === null)
                discover()
            if (drmFds.length === 0)
                return null

            let memKiB = 0
            let engineNs = 0
            for (const fd of drmFds) {
                const info = read("/proc/self/fdinfo/" + fd)
                const mem = /^drm-total-(\S+):\s+(\d+)\s*(\w*)/gm
                let m
                while ((m = mem.exec(info)) !== null)
                    if (m[1].indexOf("stolen") < 0)
                        memKiB += toKiB(m[2], m[3])
                const engine = /^drm-engine-(render|gfx):\s+(\d+)/gm
                while ((m = engine.exec(info)) !== null)
                    engineNs += parseInt(m[2])
            }
            return { memKiB, engineNs }
        }
    }

    QtObject {
        id: d

        property int frames: 0

        // A 1 px item kept turning makes every frame a redraw of the whole
        // scene, with nothing else changing.
        property bool driving: false
        property bool resizing: false

        // live metrics, refreshed every second
        property real fps: 0
        property real gpuMsPerFrame: NaN
        property real gpuMemMiB: NaN
        property real rssMiB: NaN
        property int lastFrames: 0
        property var lastGpu: null
        property real lastBuildMs: NaN

        function fmt(v, digits = 1) {
            return isNaN(v) ? "n/a" : v.toFixed(digits)
        }
    }

    Connections {
        target: root.Window.window
        function onFrameSwapped() {
            d.frames++
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.visible
        onTriggered: {
            const frames = d.frames - d.lastFrames
            d.lastFrames = d.frames
            d.fps = frames * 1000 / interval

            const gpu = stats.gpu()
            d.gpuMemMiB = gpu ? gpu.memKiB / 1024 : NaN
            d.gpuMsPerFrame = gpu && d.lastGpu && frames > 0
                    ? (gpu.engineNs - d.lastGpu.engineNs) / frames / 1e6 : NaN
            d.lastGpu = gpu
            d.rssMiB = stats.rssKiB() / 1024
        }
    }

    // Benchmark: a chain of steps, each handed the continuation.
    QtObject {
        id: bench

        property bool running: false
        property var results: []
        property string report: ""
        property var pending: null

        readonly property Timer timer: Timer {
            onTriggered: {
                const cb = bench.pending
                bench.pending = null
                if (cb)
                    cb()
            }
        }

        function delay(ms, cb) {
            pending = cb
            timer.interval = ms
            timer.restart()
        }

        function whenReady(cb, started = Date.now()) {
            if (root.readyCount() === cells.count || Date.now() - started > 20000) {
                cb()
                return
            }
            delay(20, () => whenReady(cb, started))
        }

        // Frames, GPU time and wall time over `ms`.
        function measure(ms, cb) {
            const gpu0 = stats.gpu()
            const frames0 = d.frames
            const t0 = Date.now()
            delay(ms, () => {
                const gpu1 = stats.gpu()
                const frames = d.frames - frames0
                const dt = Date.now() - t0
                const gpuMs = gpu0 && gpu1 ? (gpu1.engineNs - gpu0.engineNs) / 1e6 : NaN
                cb({
                    fps: frames * 1000 / dt,
                    gpuMsPerFrame: frames > 0 ? gpuMs / frames : NaN,
                    gpuMsPerSecond: gpuMs * 1000 / dt
                })
            })
        }

        function memory() {
            gc()
            const gpu = stats.gpu()
            return { gpuKiB: gpu ? gpu.memKiB : NaN, rssKiB: stats.rssKiB() }
        }

        function clearGrid(cb) {
            root.imageCount = 0
            delay(400, () => {
                gc()
                delay(200, cb)
            })
        }

        // Builds the grid, waits for every image and a few frames, and hands
        // over the build figures and the memory the grid added.
        function buildGrid(cb) {
            const before = memory()
            const t0 = Date.now()
            root.imageCount = root.benchmarkCount
            const syncMs = Date.now() - t0
            whenReady(() => {
                const readyMs = Date.now() - t0
                d.driving = true
                delay(500, () => {
                    d.driving = false
                    const after = memory()
                    cb({
                        syncMsPerItem: syncMs / root.benchmarkCount,
                        readyMs,
                        gpuMiB: (after.gpuKiB - before.gpuKiB) / 1024,
                        rssMiB: (after.rssKiB - before.rssKiB) / 1024
                    })
                })
            })
        }

        // Each scenario: what drives the frames while it is measured.
        readonly property var stillScenarios: [
            { name: "redraw", ms: 2000, begin: () => d.driving = true, end: () => d.driving = false },
            { name: "scroll", ms: 3000, begin: () => root.scrolling = true,
              end: () => { root.scrolling = false; flick.contentY = 0 } },
            { name: "resize", ms: 3000,
              begin: () => { root.decodeCellSize = root.cellSize; d.resizing = true },
              end: () => {
                  d.resizing = false
                  root.cellSize = root.decodeCellSize
                  root.decodeCellSize = Qt.binding(() => root.cellSize)
              } }
        ]
        readonly property var animatedScenarios: [
            // the GIFs drive the frames themselves
            { name: "playback", ms: 3000, begin: () => {}, end: () => {} },
            { name: "scroll", ms: 3000, begin: () => root.scrolling = true,
              end: () => { root.scrolling = false; flick.contentY = 0 } }
        ]

        function runScenarios(technique, scenarios, r, cb, i = 0) {
            if (i === scenarios.length) {
                cb()
                return
            }
            const s = scenarios[i]
            s.begin()
            // a moment for whatever starts to settle before it is measured
            delay(250, () => {
                console.info(`BENCH-BEGIN ${technique} ${s.name}`)
                measure(s.ms, m => {
                    console.info(`BENCH-END ${technique} ${s.name}`)
                    s.end()
                    r.scenarios[s.name] = m
                    delay(250, () => runScenarios(technique, scenarios, r, cb, i + 1))
                })
            })
        }

        function runTechnique(technique, cb) {
            const r = { technique, animated: root.animated, scenarios: {} }

            root.technique = technique
            clearGrid(() => buildGrid(build => {
                r.build = build
                runScenarios(technique, root.animated ? animatedScenarios : stillScenarios, r,
                             () => clearGrid(() => cb(r)))
            }))
        }

        function line(r) {
            const f = d.fmt
            let s = `${root.techniqueNames[r.technique].padEnd(36)}`
                  + ` | build ${f(r.build.syncMsPerItem, 2)} ms/item, ready ${f(r.build.readyMs, 0)} ms`
                  + ` | GPU mem +${f(r.build.gpuMiB)} MiB, RSS +${f(r.build.rssMiB)} MiB`
            for (const name in r.scenarios) {
                const m = r.scenarios[name]
                s += ` | ${name} ${f(m.fps, 0)} fps, ${f(m.gpuMsPerFrame, 2)} GPU ms/frame,`
                   + ` ${f(m.gpuMsPerSecond, 0)} GPU ms/s`
            }
            return s
        }

        function start() {
            if (running)
                return

            running = true
            results = []
            const techniques = root.benchmarkTechniques
            const saved = { technique: root.technique, count: root.imageCount,
                            comparison: root.showComparison, animated: root.animated }
            root.showComparison = false
            root.animated = root.benchmarkAnimated
            report = `${root.benchmarkCount} ${root.animated ? "GIFs" : "images"} of ${root.cellSize} px,`
                   + ` radius ${root.radius}, ${root.fillMode === Image.PreserveAspectCrop ? "crop" : "fit"},`
                   + ` dpr ${root.devicePixelRatio}, ${root.uniqueSources ? "unique" : "shared"} sources,`
                   + ` window ${root.Window.window ? root.Window.window.width + "x" + root.Window.window.height : "?"}\n`

            const next = i => {
                if (i === techniques.length) {
                    root.technique = saved.technique
                    root.imageCount = saved.count
                    root.showComparison = saved.comparison
                    root.animated = saved.animated
                    running = false
                    console.info("RoundedImagesPage benchmark\n" + report)
                    root.benchmarkFinished()
                    return
                }
                runTechnique(techniques[i], r => {
                    results = results.concat([r])
                    report += line(r) + "\n"
                    next(i + 1)
                })
            }
            next(0)
        }
    }

    Rectangle {
        // the frame driver: tiny, and in a corner
        width: 1
        height: 1
        color: "transparent"
        NumberAnimation on rotation {
            running: d.driving
            from: 0
            to: 360
            duration: 1000
            loops: Animation.Infinite
        }
    }

    SequentialAnimation {
        running: d.resizing
        loops: Animation.Infinite

        NumberAnimation {
            target: root
            property: "cellSize"
            to: root.decodeCellSize * 0.85
            duration: 500
        }
        NumberAnimation {
            target: root
            property: "cellSize"
            to: root.decodeCellSize
            duration: 500
        }
    }

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        padding: 0

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // One large sample of each technique, and its top-left corner
            // magnified 6x without smoothing.
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 12
                visible: root.showComparison
                spacing: 16

                Repeater {
                    model: root.techniques

                    ColumnLayout {
                        id: sample

                        required property string modelData

                        spacing: 4

                        Label {
                            text: root.techniqueNames[sample.modelData]
                            font.bold: root.technique === sample.modelData
                        }

                        Rectangle {
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 200
                            color: "#c8d0dc"

                            Technique {
                                id: sampleImage

                                anchors.fill: parent
                                technique: sample.modelData
                                imageSource: root.stillSource
                            }
                        }

                        ShaderEffectSource {
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 100
                            sourceItem: sampleImage.parent
                            sourceRect: Qt.rect(0, 0, 50, 25)
                            smooth: false
                            live: true
                        }
                    }
                }
            }

            Flickable {
                id: flick

                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentWidth: width
                contentHeight: flow.height

                ScrollBar.vertical: ScrollBar {}

                SequentialAnimation {
                    running: root.scrolling
                    loops: Animation.Infinite

                    NumberAnimation {
                        target: flick
                        property: "contentY"
                        to: Math.max(0, flick.contentHeight - flick.height)
                        duration: 1500
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: flick
                        property: "contentY"
                        to: 0
                        duration: 1500
                        easing.type: Easing.InOutQuad
                    }
                }

                Flow {
                    id: flow

                    width: flick.width
                    padding: 8
                    spacing: 8

                    Repeater {
                        id: cells

                        model: root.imageCount

                        Technique {
                            required property int index

                            width: root.cellSize
                            height: root.cellSize
                            technique: root.technique
                            imageSource: root.sourceFor(index)
                        }
                    }
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(implicitHeight, 160)
                visible: bench.report !== ""

                TextArea {
                    readOnly: true
                    selectByMouse: true
                    wrapMode: TextEdit.NoWrap
                    font.family: "monospace"
                    font.pixelSize: 11
                    text: bench.report
                }
            }
        }
    }

    Pane {
        SplitView.preferredWidth: 360
        SplitView.fillHeight: true

        ScrollView {
            anchors.fill: parent
            contentWidth: availableWidth

            ColumnLayout {
                width: parent.width
                spacing: 6
                enabled: !bench.running

                Label { text: "Technique"; font.bold: true }

                Repeater {
                    model: root.techniques

                    RadioButton {
                        required property string modelData

                        text: root.techniqueNames[modelData]
                        checked: root.technique === modelData
                        onToggled: root.technique = modelData
                    }
                }

                Label { text: `Images: ${root.imageCount}` }
                Slider {
                    Layout.fillWidth: true
                    from: 0
                    to: 500
                    stepSize: 10
                    value: root.imageCount
                    onMoved: {
                        const t0 = Date.now()
                        root.imageCount = value
                        d.lastBuildMs = Date.now() - t0
                    }
                }

                Label { text: `Size: ${root.cellSize} px` }
                Slider {
                    Layout.fillWidth: true
                    from: 40
                    to: 400
                    stepSize: 4
                    value: root.cellSize
                    onMoved: root.cellSize = value
                }

                Label { text: `Radius: ${root.radius} px` }
                Slider {
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    stepSize: 1
                    value: root.radius
                    onMoved: root.radius = value
                }

                CheckBox {
                    text: "Bubble tail (4 px bottom-left corner)"
                    checked: root.tail
                    onToggled: root.tail = checked
                }

                CheckBox {
                    text: "Crop (off: fit)"
                    checked: root.fillMode === Image.PreserveAspectCrop
                    onToggled: root.fillMode = checked ? Image.PreserveAspectCrop : Image.PreserveAspectFit
                }

                CheckBox {
                    text: "Animated GIF"
                    checked: root.animated
                    onToggled: root.animated = checked
                }

                CheckBox {
                    text: "Distinct pixmap per image"
                    checked: root.uniqueSources
                    onToggled: root.uniqueSources = checked
                }

                CheckBox {
                    text: "Scroll continuously"
                    checked: root.scrolling
                    onToggled: root.scrolling = checked
                }

                CheckBox {
                    text: "Redraw continuously"
                    checked: d.driving
                    onToggled: d.driving = checked
                }

                CheckBox {
                    text: "Show comparison"
                    checked: root.showComparison
                    onToggled: root.showComparison = checked
                }

                Label { text: "Live"; font.bold: true; Layout.topMargin: 8 }

                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    font.family: "monospace"
                    text: `ready     ${root.readyCount()} / ${cells.count}\n`
                        + `last build ${d.fmt(d.lastBuildMs, 0)} ms\n`
                        + `frames    ${d.fmt(d.fps, 0)} /s\n`
                        + `GPU       ${d.fmt(d.gpuMsPerFrame, 2)} ms/frame\n`
                        + `GPU mem   ${d.fmt(d.gpuMemMiB)} MiB\n`
                        + `RSS       ${d.fmt(d.rssMiB)} MiB`
                          + (stats.fileReadable ? "" : "\n(set QML_XHR_ALLOW_FILE_READ=1 for memory and GPU)")
                }

                Label { text: "Benchmark"; font.bold: true; Layout.topMargin: 8 }

                Label { text: `Images: ${root.benchmarkCount}` }
                Slider {
                    Layout.fillWidth: true
                    from: 50
                    to: 500
                    stepSize: 50
                    value: root.benchmarkCount
                    onMoved: root.benchmarkCount = value
                }

                CheckBox {
                    text: "Benchmark GIFs (off: stills)"
                    checked: root.benchmarkAnimated
                    onToggled: root.benchmarkAnimated = checked
                }

                Button {
                    text: bench.running ? "Running..." : "Run benchmark"
                    onClicked: root.runBenchmark()
                }
            }
        }
    }

}

// category: Components
// status: good
