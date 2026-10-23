import QtQuick
import QtTest

import StatusQ.Components

/*
 Checks what the tile shader actually draws. The offscreen QPA platform has no
 RHI backend to compile and run shaders with, so the whole case is skipped
 there; run it with a real window (no QT_QPA_PLATFORM=offscreen).
*/
Item {
    id: root
    width: 400
    height: 200

    Component {
        id: tileComp

        Rectangle {
            readonly property alias tile: tile

            width: 240
            height: 80
            color: "#0000ff"

            LoadingSkeletonTile {
                id: tile
                x: 20
                y: 20
                width: 200
                height: 40
                radius: 12
                color: "#404040"
            }
        }
    }

    TestCase {
        name: "LoadingSkeletonTileRendering"
        when: windowShown

        function initTestCase() {
            if (Qt.platform.pluginName === "offscreen")
                skip("shaders are not run on the offscreen platform")
        }

        function brightness(c) {
            return c.r + c.g + c.b
        }

        function fuzzyCompareColor(actual, expected, message) {
            const tolerance = 2 / 255
            verify(Math.abs(actual.r - expected.r) <= tolerance
                   && Math.abs(actual.g - expected.g) <= tolerance
                   && Math.abs(actual.b - expected.b) <= tolerance,
                   `${message}: got ${actual}, expected ${expected}`)
        }

        // darkest and brightest pixel along the middle row, edges excluded
        function middleRowExtremes(image, scale) {
            const row = Math.floor(image.height / 2)
            const step = Math.max(1, Math.round(scale))
            let darkest = null
            let brightest = null
            for (let x = 2 * step; x < image.width - 2 * step; x += step) {
                const c = image.pixel(x, row)
                if (!darkest || brightness(c) < brightness(darkest))
                    darkest = c
                if (!brightest || brightness(c) > brightness(brightest))
                    brightest = c
            }
            return { darkest, brightest }
        }

        function test_draws_rounded_tile_with_moving_band() {
            const frame = createTemporaryObject(tileComp, root)
            verify(!!frame)
            const tile = frame.tile

            tryCompare(tile, "status", ShaderEffect.Compiled)
            waitForRendering(frame)

            const image = grabImage(tile)
            const scale = image.width / tile.width
            fuzzyCompareColor(image.pixel(0, 0), Qt.color("#0000ff"),
                              "the rounded corner must leave the background visible")
            fuzzyCompareColor(middleRowExtremes(image, scale).darkest,
                              Qt.color("#404040"),
                              "the body outside the band must be the base color")

            // the band sweeps on the render thread; sample frames until it
            // crosses the middle row
            tryVerify(() => {
                const e = middleRowExtremes(grabImage(tile), scale)
                return brightness(e.brightest) > brightness(e.darkest) + 0.03
            }, 3000, "the sweep band must brighten the tile in some frame")
        }
    }
}
