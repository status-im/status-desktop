import QtQuick

import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Core.Theme

StatusButton {
    required property string formattedValue
    property bool markAsInvalid: false

    text: qsTr("Max. %1").arg(formattedValue)
    type: markAsInvalid ? StatusBaseButton.Type.Danger
                        : StatusBaseButton.Type.Normal

    horizontalPadding: 8
    verticalPadding: 3
    implicitHeight: 22

    radius: 20
    font.pixelSize: Theme.tertiaryTextFontSize
    font.weight: Font.Normal
}
