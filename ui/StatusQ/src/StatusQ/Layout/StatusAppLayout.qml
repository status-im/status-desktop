import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: statusAppLayout

    implicitWidth: 900
    implicitHeight: 600

    color: Theme.palette.statusAppLayout.backgroundColor
    
    property StatusAppNavBar appNavBar
    property Item appView

    onAppNavBarChanged: {
        if (!!appNavBar) {
            appNavBar.parent = appNavBarSlot
        }
    }

    onAppViewChanged: {
        if (!!appView) {
            appView.parent = appViewSlot
        }
    }

    Row {
        id: rowLayout
        spacing: 0
        height: statusAppLayout.height
        width: statusAppLayout.width

        Item {
            id: appNavBarSlot
            height: statusAppLayout.height
            width: 78
        }

        Item {
            id: appViewSlot
            height: statusAppLayout.height
            width: statusAppLayout.width - appNavBarSlot.width
        }
    }
}
