import QtQuick
import QtQml
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Popups.Dialog

import shared.popups
import shared.controls

import utils

StatusDialog {
    id: root

    destroyOnClose: false

    property bool isCustomScrollingEnabled: false
    property real initialVelocity
    property real initialDeceleration

    signal velocityChanged(real value)
    signal decelerationChanged(real value)
    signal customScrollingChanged(bool enabled)

    footer.visible: false

    implicitHeight: 610 // see contentColumn.height's comment

    ColumnLayout {
        id: contentColumn

        // contentColumn will spread radio buttons evenly across all height if their height
        // is less than contentColumn's. And we want to maintain dialog's constant height, so
        // binding it to root's height when custom scrolling
        height: root.isCustomScrollingEnabled ? parent.implicitHeight : implicitHeight
        width: parent.width

        spacing: Theme.padding

        ButtonGroup { id: scrollSettingsGroup }

        RadioButtonSelector {
            Layout.fillWidth: true
            title: qsTr("System")
            buttonGroup: scrollSettingsGroup
            checked: !root.isCustomScrollingEnabled
            onClicked: {
                root.customScrollingChanged(false)
            }
        }

        RadioButtonSelector {
            Layout.fillWidth: true
            title: qsTr("Custom")
            buttonGroup: scrollSettingsGroup
            checked: root.isCustomScrollingEnabled
            onClicked: {
                root.customScrollingChanged(true)
            }
        }

        ColumnLayout {
            visible: root.isCustomScrollingEnabled

            spacing: Theme.padding

            Rectangle {
                id: scrollSeparator

                Layout.fillWidth: true
                height: 1
                color: Theme.palette.separator
            }

            StatusBaseText {
                color: Theme.palette.secondaryText
                font.pixelSize: Theme.secondaryTextFontSize
                text: qsTr("Velocity")
            }

            StatusSlider {
                id: scrollVelocitySlider

                Layout.fillWidth: true
                from: 0
                to: 1000
                stepSize: 1
                readonly property int scaleFactor: 10
                value: root.initialVelocity / scaleFactor
                onMoved: {
                    root.velocityChanged(value * scaleFactor)
                }
            }

            StatusBaseText {
                color: Theme.palette.secondaryText
                font.pixelSize: Theme.secondaryTextFontSize
                text: qsTr("Deceleration")
            }

            StatusSlider {
                id: scrollDecelerationSlider

                Layout.fillWidth: true
                from: 0
                to: 2000
                stepSize: 1
                readonly property int scaleFactor: 10
                value: initialDeceleration / scaleFactor
                onMoved: {
                    root.decelerationChanged(value * scaleFactor)
                }
            }

            StatusBaseText {
                color: Theme.palette.secondaryText
                font.pixelSize: Theme.secondaryTextFontSize
                text: qsTr("Test scrolling")
            }

            StatusListView {
                model: 100

                Layout.fillWidth: true
                Layout.preferredHeight: 170 // Bad, but setting fillHeight instead causes height being 0

                delegate: StatusListItem {
                    title: modelData
                }

                Binding on flickDeceleration {
                    when: root.isCustomScrollingEnabled
                    value: scrollDecelerationSlider.value * scrollDecelerationSlider.scaleFactor
                    restoreMode: Binding.RestoreBindingOrValue
                }

                Binding on maximumFlickVelocity {
                    when: root.isCustomScrollingEnabled
                    value: scrollVelocitySlider.value * scrollVelocitySlider.scaleFactor
                    restoreMode: Binding.RestoreBindingOrValue
                }
            }
        }
    }
}
