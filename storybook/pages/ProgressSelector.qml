import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ
import StatusQ.Core.Utils

import Storybook

import AppLayouts.Onboarding.enums

Control {
    id: root

    readonly property alias value: d.value

    property string label

    QtObject {
        id: d

        property int value: Onboarding.ProgressState.Idle
    }

    contentItem: RowLayout {
        Label {
            id: label

            text: root.label + ": "
        }

        Flow {
            spacing: 2

            ButtonGroup {
                id: group
            }

            Repeater {
                model: Onboarding.getModelFromEnum("ProgressState")

                RoundButton {
                    focusPolicy: Qt.NoFocus
                    text: modelData.name
                    checkable: true
                    checked: root.value === modelData.value

                    ButtonGroup.group: group

                    onClicked: d.value = modelData.value
                }
            }
        }
    }
}
