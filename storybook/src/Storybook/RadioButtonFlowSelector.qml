import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core.Utils

import utils

Flow {
    id: root

    property alias model: repeater.model

    property string selection: model ? model[initialSelection] : ""
    property int initialSelection: 0

    Repeater {
        id: repeater

        RadioButton {
            text: modelData
            checked: root.initialSelection === index
            onToggled: selection = modelData
        }
    }
}
