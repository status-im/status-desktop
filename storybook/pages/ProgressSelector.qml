import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import Storybook 1.0

import AppLayouts.Onboarding.enums 1.0

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
