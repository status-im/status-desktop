import QtQuick 2.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusBaseButton {
    id: statusButton

    normalColor: type === StatusBaseButton.Type.Primary ? Theme.palette.primaryColor1 :
                                                          type === StatusBaseButton.Type.Normal ? Theme.palette.primaryColor3 :
                                                                                                  type === StatusBaseButton.Type.Warning ? Theme.palette.warningColor3
                                                                                                                                         : Theme.palette.dangerColor3
    hoverColor: type === StatusBaseButton.Type.Primary ? Theme.palette.hoverColor(normalColor) :
                                                         type === StatusBaseButton.Type.Normal ? Theme.palette.primaryColor2 :
                                                                                                 type === StatusBaseButton.Type.Warning ? Theme.palette.warningColor2
                                                                                                                                        : Theme.palette.dangerColor2

    disabledColor: Theme.palette.baseColor2

    textColor: type === StatusBaseButton.Type.Primary ? Theme.palette.indirectColor4 :
                                                        type === StatusBaseButton.Type.Normal ? Theme.palette.primaryColor1 :
                                                                                                type === StatusBaseButton.Type.Warning ? Theme.palette.warningColor1
                                                                                                                                       : Theme.palette.dangerColor1
    disabledTextColor: Theme.palette.baseColor1
}
