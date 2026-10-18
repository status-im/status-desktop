import QtQuick
import QtTest

import StatusQ.Components

/*
 StatusEmoji draws one emoji centred in the box the caller sized. Values that
 reach it are not always clean: the picker used to pad its payload with a space
 for text insertion, and that padding was saved with channel and account emoji,
 so stored values from older builds still carry it. The emoji font has a real
 space glyph a full em wide, so an untrimmed value lands half an em to the left
 of the box - outside the identicon it is meant to sit in.
*/
Item {
    id: root

    width: 200
    height: 48

    Rectangle {
        anchors.fill: parent
        color: "white"
    }

    Row {
        id: boxes

        // Each cell mimics a 24px identicon with a 12px emoji centred in it.
        Repeater {
            id: repeater

            model: ["\u{1F4E3}", "\u{1F4E3} "]
            delegate: Item {
                width: 24
                height: 24

                StatusEmoji {
                    objectName: "emoji"
                    anchors.centerIn: parent
                    width: 12
                    height: 12
                    emoji: modelData
                }
            }
        }
    }

    TestCase {
        name: "StatusEmoji"
        when: windowShown

        function test_whitespaceIsNotPartOfTheEmoji_data() {
            return [
                { tag: "plain", emoji: "\u{1F4E3}", expected: "\u{1F4E3}" },
                { tag: "trailing space", emoji: "\u{1F4E3} ", expected: "\u{1F4E3}" },
                { tag: "surrounded", emoji: " \u{1F4E3}\n", expected: "\u{1F4E3}" },
                { tag: "qualified", emoji: "❤️ ", expected: "❤️" },
                { tag: "blank", emoji: "   ", expected: "" },
                { tag: "unset", emoji: "", expected: "" },
            ]
        }

        function test_whitespaceIsNotPartOfTheEmoji(data) {
            const item = createTemporaryObject(emojiComponent, root, { emoji: data.emoji })
            verify(!!item)
            compare(item.text, data.expected)
        }

        // The symptom the trim exists for: with the space kept, the artwork is
        // drawn half an em left of the box and leaves the circle it sits in.
        function test_paddedValueIsDrawnInTheSamePlaceAsABareOne() {
            const image = grabImage(root)

            const centres = []
            for (let cell = 0; cell < repeater.count; ++cell) {
                let minX = -1
                let maxX = -1
                for (let x = cell * 24; x < (cell + 1) * 24; ++x) {
                    for (let y = 0; y < 24; ++y) {
                        if (Qt.colorEqual(image.pixel(x, y), "#ffffff"))
                            continue
                        if (minX < 0)
                            minX = x
                        maxX = x
                        break
                    }
                }
                verify(minX >= 0, `cell ${cell} drew nothing`)
                centres.push((minX + maxX) / 2 - cell * 24)
            }

            compare(centres[1], centres[0],
                    "a padded value must sit where a bare one does")
        }

        Component {
            id: emojiComponent

            StatusEmoji {}
        }
    }
}
