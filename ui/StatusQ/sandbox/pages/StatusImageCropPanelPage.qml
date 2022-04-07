import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import QtGraphicalEffects 1.14

Item {
    id: root

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

    property var testControls: [ctrl1, ctrl2, ctrl3]

    property bool globalStylePreferRound: true

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent

        RowLayout {
            ColumnLayout {
                Text {
                    text: `AR: ${ctrl1.aspectRatio.toFixed(2)}`
                }

                StatusImageCropPanel {
                    id: ctrl1
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    source: "qrc:/demoapp/data/logo-test-image.png"
                    windowStyle: globalStylePreferRound ? StatusImageCrop.WindowStyle.Rounded : StatusImageCrop.WindowStyle.Rectangular
                }
                Text {
                    text: `AR: ${ctrl2.aspectRatio.toFixed(2)}`
                }
                StatusImageCropPanel {
                    id: ctrl2
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    source: "qrc:/demoapp/data/logo-test-image.png"
                    windowStyle: globalStylePreferRound ? StatusImageCrop.WindowStyle.Rectangular : StatusImageCrop.WindowStyle.Rounded
                    aspectRatio: 16/9
                    enableCheckers: true
                }
            }
            ColumnLayout {
                Text {
                    text: `AR: ${ctrl3.aspectRatio.toFixed(2)}`
                }
                StatusImageCropPanel {
                    id: ctrl3

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    source: "qrc:/demoapp/data/logo-test-image.png"
                    windowStyle: globalStylePreferRound ? StatusImageCrop.WindowStyle.Rounded : StatusImageCrop.WindowStyle.Rectangular
                    aspectRatio: 0.8
                }
            }
        }

        Shortcut {
            sequence: StandardKey.ZoomIn
            onActivated: {
                for(let i in testControls) {
                    const c = testControls[i]
                    c.setCropRect(ctrl1.inflateRectBy(c.cropRect, -0.05))
                }
            }
        }

        Shortcut {
            sequence: StandardKey.ZoomOut
            onActivated: {
                for(let i in testControls) {
                    const c = testControls[i]
                    c.setCropRect(ctrl1.inflateRectBy(c.cropRect, 0.05))
                }
            }
        }

        Shortcut {
            sequences: ["Ctrl+W"]
            onActivated: globalStylePreferRound = !globalStylePreferRound
        }
    }
}
