import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusBaseText {
    property bool checked
    property string caption

    text: "%1 %2".arg(checked ? "✓" : "+").arg(caption)
    font.pixelSize: Theme.tertiaryTextFontSize
    color: checked ? Theme.palette.successColor1 : Theme.palette.baseColor1
}
