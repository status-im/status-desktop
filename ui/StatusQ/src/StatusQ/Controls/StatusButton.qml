import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusBaseButton {
    normalColor: {
        switch(type) {
        case StatusBaseButton.Type.Primary:
            return Theme.palette.primaryColor1
        case StatusBaseButton.Type.Warning:
            return Theme.palette.warningColor3
        case StatusBaseButton.Type.Danger:
            return Theme.palette.dangerColor3
        case StatusBaseButton.Type.Success:
            return Theme.palette.successColor2
        default:
            return Theme.palette.primaryColor3
        }
    }

    hoverColor: {
        switch(type) {
        case StatusBaseButton.Type.Primary:
            return Theme.palette.hoverColor(normalColor)
        case StatusBaseButton.Type.Warning:
            return Theme.palette.warningColor2
        case StatusBaseButton.Type.Danger:
            return Theme.palette.dangerColor2
        case StatusBaseButton.Type.Success:
            return Theme.palette.successColor3
        default:
            return Theme.palette.primaryColor2
        }
    }

    disabledColor: Theme.palette.baseColor2

    textColor: {
        switch(type) {
        case StatusBaseButton.Type.Primary:
            return Theme.palette.indirectColor4
        case StatusBaseButton.Type.Warning:
            return Theme.palette.warningColor1
        case StatusBaseButton.Type.Danger:
            return Theme.palette.dangerColor1
        case StatusBaseButton.Type.Success:
            return Theme.palette.successColor1
        default:
            return Theme.palette.primaryColor1
        }
    }

    disabledTextColor: Theme.palette.baseColor1
}
