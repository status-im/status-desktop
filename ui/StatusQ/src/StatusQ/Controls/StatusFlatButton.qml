import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusBaseButton {
    normalColor: "transparent"

    hoverColor: {
        switch(type) {
        case StatusBaseButton.Type.Primary:
            return Theme.palette.primaryColor2
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

    disabledColor: "transparent"

    textColor: {
        switch(type) {
        case StatusBaseButton.Type.Primary:
            return Theme.palette.primaryColor1
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

    borderColor: (type === StatusBaseButton.Type.Normal || hovered) && !loading ? "transparent"
                                                                                : Theme.palette.baseColor2
}
