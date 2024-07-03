import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core.Utils 0.1

import utils 1.0

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
