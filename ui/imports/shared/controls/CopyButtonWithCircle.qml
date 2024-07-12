import QtQuick 2.15
import QtQml 2.15

import StatusQ.Controls 0.1
import StatusQ.Core.Backpressure 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.stores 1.0

StatusRoundButton {
    id: root

    required property string textToCopy

    icon.name: d.copied ? "tiny/checkmark" : "copy"
    icon.width: 20
    icon.height: 20

    type: StatusRoundButton.Type.Tertiary

    property bool successCircleVisible: false

    implicitWidth: 32
    implicitHeight: 32

    Binding on icon.color {
        when: successCircleVisible && d.copied
        value: Theme.palette.successColor1
        restoreMode: Binding.RestoreBindingOrValue
    }

    Binding on icon.hoverColor {
        when: successCircleVisible && d.copied
        value: Theme.palette.successColor1
        restoreMode: Binding.RestoreBindingOrValue
    }

    Binding on color {
        when: successCircleVisible && d.copied
        value: Theme.palette.successColor2
        restoreMode: Binding.RestoreBindingOrValue
    }

    Rectangle {
        id: greenCircleAroundIcon

        anchors.centerIn: parent
        width: icon.width
        height: width
        radius: width / 2
        border.width: 1
        border.color: d.copied ? Theme.palette.successColor1 : "transparent"
        color: "transparent"
        visible: root.successCircleVisible
    }

    QtObject {
        id: d
        property bool copied: false
    }

    onClicked: {
        RootStore.copyToClipboard(root.textToCopy)
        d.copied = true
        Backpressure.debounce(root, 1500, function () {
            d.copied = false
        })()
    }
}
