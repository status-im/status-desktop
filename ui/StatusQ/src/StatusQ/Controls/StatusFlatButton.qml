import QtQuick 2.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusBaseButton {
    id: statusFlatButton

    normalColor: "transparent"
    hoverColor:  type === StatusBaseButton.Type.Normal ? Theme.palette.primaryColor3
                                                       : Theme.palette.dangerColor3
    disaledColor: "transparent"

    textColor: type === StatusBaseButton.Type.Normal ? Theme.palette.primaryColor1
                                                     : Theme.palette.dangerColor1
    disabledTextColor: Theme.palette.baseColor1

    border.color: type === StatusBaseButton.Type.Normal || hovered ? "transparent"
                                                          : Theme.palette.baseColor2
    rightPadding: icon.name !== "" ? 18 : defaultRightPadding
    leftPadding: icon.name !== "" ? 14 : defaultLeftPadding
}
