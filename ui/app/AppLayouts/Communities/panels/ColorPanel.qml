import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Controls.Validators
import StatusQ.Components
import StatusQ.Popups

StatusScrollView {
    id: root

    property string title: qsTr("Community Colour")
    property string buttonText: qsTr("Select Community Colour")

    property var rightButtons: StatusButton {
        objectName: "communityColorPanelSelectColorButton"
        text: root.buttonText
        onClicked: root.accepted()
        enabled: hexInput.valid
    }

    property alias color: colorSpace.color

    signal accepted()

    onColorChanged: {
        if (!hexInput.locked)
            hexInput.text = color.toString();

        if (colorSelectionGrid.selectedColor != color)
            colorSelectionGrid.selectedColorIndex = -1;
    }

    Component.onCompleted: {
        hexInput.text = color.toString();
    }

    contentWidth: availableWidth
    padding: 0
    clip: false

    ColumnLayout {
        id: column
        width: root.availableWidth
        spacing: 16

        StatusColorSpace {
            id: colorSpace

            readonly property real hueFactor: Math.max(rootColor.g + rootColor.b * 0.4,
                                                       rootColor.g + rootColor.r * 0.6)

            minSaturate: Math.max(0.4, hueFactor * 0.55)
            maxSaturate: 1.0
            minValue: 0.4
            // Curve to pick colors readable with white text
            maxValue: Math.min(1.0, 1.65 - hueFactor * 0.5)
            Layout.alignment: Qt.AlignHCenter
        }

        StatusInput {
            id: hexInput
            input.edit.objectName: "communityColorPanelHexInput"

            property color newColor: text
            // TODO: editingFinished() signal instead of this crutch
            property bool locked: false

            Layout.preferredWidth: 256
            validators: [
                StatusRegularExpressionValidator {
                    regularExpression: /^#(?:[0-9a-fA-F]{3}){1,2}$/
                    errorMessage: qsTr("This is not a valid colour")
                }
            ]
            validationMode: StatusInput.ValidationMode.Always

            onNewColorChanged: {
                if (!valid)
                    return;

                locked = true;
                root.color = newColor;
                locked = false;
            }
            Layout.alignment: Qt.AlignHCenter
        }

        StatusBaseText {
            text: qsTr("Preview")
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            radius: 10
            color: root.color

            StatusBaseText {
                anchors.centerIn: parent
                text: qsTr("White text should be legible on top of this colour")
                color: StatusColors.colors.white
            }
        }

        StatusColorSelectorGrid {
            id: colorSelectionGrid
            titleText: qsTr("Standard colours")
            title.color: Theme.palette.directColor1
            columns: 8
            model: Theme.palette.communityColorsArray
            selectedColorIndex: -1
            onColorSelected: {
                root.color = selectedColor;
            }
            Layout.fillWidth: true
        }
    }
}
