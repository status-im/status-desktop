import QtQuick 2.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusBaseButton {
    id: statusButton

    normalColor: type === StatusBaseButton.Type.Primary ? Theme.palette.primaryColor1 :
                                                          type === StatusBaseButton.Type.Normal ? Theme.palette.primaryColor3
                                                                                                : Theme.palette.dangerColor3
    hoverColor: type === StatusBaseButton.Type.Primary ? Theme.palette.hoverColor(normalColor) :
                                                         type === StatusBaseButton.Type.Normal ? Theme.palette.primaryColor2
                                                                                               : Theme.palette.dangerColor2
    disaledColor: Theme.palette.baseColor2

    textColor: type === StatusBaseButton.Type.Primary ? Theme.palette.white :
                                                        type === StatusBaseButton.Type.Normal ? Theme.palette.primaryColor1
                                                                                              : Theme.palette.dangerColor1
    disabledTextColor: Theme.palette.baseColor1

    font.weight: type === StatusBaseButton.Type.Primary ? Font.Medium : Font.Normal
}
