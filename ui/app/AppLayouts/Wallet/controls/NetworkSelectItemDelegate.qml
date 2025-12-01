import QtQuick
import QtQml

import StatusQ.Components
import StatusQ.Controls
import StatusQ.Core.Theme

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
    property bool showNewIcon: false

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

    statusListItemTitleIcons.active: root.showNewIcon
    statusListItemTitleIcons.anchors.leftMargin: Theme.smallPadding
    statusListItemTitleIcons.sourceComponent: StatusNewTag {
        objectName: "networkSelectionNewIcon_" + root.title
        tooltipText: qsTr("%1 chain integrated. You can now view and swap <br>%1 assets, as well as interact with %1 dApps.").arg(root.title)
    }

    Binding on bgColor {
        when: highlighted && !root.sensor.containsMouse
        value: root.interactive ? root.Theme.palette.baseColor4 : root.Theme.palette.primaryColor3
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
