import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusListItem {
    id: root

    // input/output property
    property int checkState: Qt.Unchecked

    //input property
    // Defines the next state of the checkbox when clicked
    // By default, it toggles between checked and unchecked
    property int nextCheckState: checkState === Qt.Checked ? Qt.Unchecked : Qt.Checked

    required property string iconUrl
    property bool showIndicator: true
    property bool multiSelection: false
    property bool interactive: true

    // output signal
    // Emitted when the checkbox is clicked
    // This signal is useful when the check state needs to change
    // only after processing the toggle event E.g backend call
    signal toggled

    objectName: root.title
    asset.height: 24
    asset.width: 24
    asset.isImage: true
    asset.name: root.iconUrl
    onClicked: {
        d.toggled()
    }

    leftPadding: 16
    rightPadding: 16
    statusListItemTitleArea.anchors.leftMargin: 12
    highlighted: d.checkState !== Qt.Unchecked && !showIndicator

    Binding on bgColor {
        when: highlighted && !root.sensor.containsMouse
        value: root.interactive ? Theme.palette.baseColor4 : Theme.palette.primaryColor3
        restoreMode: Binding.RestoreBindingOrValue
    }

    onCheckStateChanged: {
        if (checkState !== d.checkState) {
            d.checkState = checkState
        }
    }

    components: [
        Loader {
            id: indicatorLoader
            sourceComponent: root.multiSelection ? checkBoxComponent : radioButtonComponent
            active: root.showIndicator
        }
    ]


    Component {
        id: checkBoxComponent
        StatusCheckBox {
            id: checkBox

            objectName: "networkSelectionCheckbox_" + root.title
            checkState: d.checkState
            tristate: true
            nextCheckState: () => d.checkState
            enabled: root.interactive

            onClicked: {
                d.toggled()
            }
        }
    }

    Component {
        id: radioButtonComponent
        StatusRadioButton {
            id: radioButton
            objectName: "networkSelectionRadioButton_" + root.title
            size: StatusRadioButton.Size.Large
            checked: d.checkState !== Qt.Unchecked
            enabled: root.interactive

            onClicked: {
                d.toggled()
            }
        }
    }

    QtObject {
        id: d
        property int checkState: root.checkState

        function toggled() {
            if (!root.interactive) {
                return
            }
            d.checkState = root.nextCheckState
            root.toggled()
        }

        onCheckStateChanged: {
            if (checkState !== root.checkState) {
                root.checkState = checkState
            }
        }
    }
}
