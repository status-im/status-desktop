import QtQuick

import StatusQ.Core
import StatusQ.Core.Theme

StatusBaseText {
    property bool checked
    property string caption

    text: "%1 %2".arg(checked ? "✓" : "+").arg(caption)
    font.pixelSize: Theme.tertiaryTextFontSize
    color: checked ? Theme.palette.successColor1 : Theme.palette.baseColor1
}
