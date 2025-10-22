import shared.controls
import StatusQ.Core.Utils

SearchBox {
    input.leftPadding: 14
    input.rightPadding: 14

    minimumHeight: 56
    maximumHeight: 56
    input.showBackground: false
    focus: visible && !Utils.isMobile
}
