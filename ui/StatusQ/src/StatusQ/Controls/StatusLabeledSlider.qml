import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

StatusSlider {
    id: root

    property var model: []
    property string textRole: ""
    property string valueRole: ""

    property int fontSize: 12
    property int labelMargin: 2

    readonly property string currentText: Array.isArray(root.model)
                                          ? root.model[value]
                                          : root.model.get(value)[root.textRole]

    readonly property var currentValue: Array.isArray(root.model)
                                        ? root.model[value]
                                        : root.model.get(value)[root.valueRole]

    fillColor: bgColor
    handleColor: Theme.palette.primaryColor1
    handleSize: 14
    from: 0
    to: (Array.isArray(model) ? model.length : model.count) - 1
    stepSize: 1
    snapMode: Slider.SnapAlways

    decoration: Item {
        implicitHeight: handleSize + fontSize + labelMargin

        Repeater {
            id: repeater
            model: root.model

            Rectangle {
                x: (background.width - width * 0.5) / (repeater.count - 1) * index
                y: (root.bgHeight -height) / 2
                implicitWidth: root.handleSize
                implicitHeight: root.handleSize
                radius: root.handleSize / 2
                color: root.bgColor
                border.color: Theme.palette.statusAppLayout.backgroundColor
                border.width: 2

                StatusBaseText {
                    anchors.top: parent.bottom
                    anchors.topMargin: root.labelMargin
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Qt.AlignHCenter
                    color: Theme.palette.baseColor1
                    font.pixelSize: root.fontSize

                    text: root.textRole ? (Array.isArray(root.model)
                                              ? modelData[root.textRole]
                                              : model[root.textRole])
                                           : modelData
                }
            }
        }
    }
}
