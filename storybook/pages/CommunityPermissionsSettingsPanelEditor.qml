import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import Models 1.0

ScrollView {
    id: root

    property var model

    ScrollBar.vertical: ScrollBar { x: root.width }

    ColumnLayout {
        spacing: 25
        CommunityPermissionsSettingItemEditor {
            panelText: "Who holds"
            name: "Socks"
            icon: ""
            amount: 11.2
            isAmountVisible: true
            isENS: false
            isENSVisible: true
            isExpression: true
            isAnd: true
        }

        CommunityPermissionsSettingItemEditor {
            panelText: "Is allowed to"
            name: "Moderate"
            icon: ""
        }

        CommunityPermissionsSettingItemEditor {
            panelText: "In"
            name: "#general"
            icon: ""
        }
        CheckBox {
            text: "Permission is private"
            checked: true//model.isPrivate
            //onToggled: model.isPrivate = checked
        }
    }
}
