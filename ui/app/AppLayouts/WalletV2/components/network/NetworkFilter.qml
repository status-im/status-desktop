import QtQuick 2.13
import "../../../../../shared"
import "../../../../../imports"

Grid {
    id: root
    columns: 2
    spacing: 2

    Repeater {
        id: chainRepeater
        model: walletV2Model.networksView.enabledNetworks
        width: parent.width
        height: parent.height

        Rectangle {
            color: Utils.setColorAlpha(Style.current.blue, 0.1)
            width: text.width + Style.current.halfPadding
            height: text.height + Style.current.halfPadding
            radius: Style.current.radius

            StyledText {
                id: text
                text: model.chainName
                color: Style.current.blue
                font.pixelSize: Style.current.secondaryTextFontSize
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}