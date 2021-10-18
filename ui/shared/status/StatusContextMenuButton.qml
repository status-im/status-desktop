import QtQuick 2.13

import utils 1.0

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

StatusFlatRoundButton  {
    id: moreActionsBtn
    implicitHeight: 32
    implicitWidth: 32
    anchors.verticalCenter: parent.verticalCenter
    icon.name: "more"
    type: StatusFlatRoundButton.Type.Secondary
    backgroundHoverColor: Style.current.contextMenuButtonBackgroundHoverColor
}
