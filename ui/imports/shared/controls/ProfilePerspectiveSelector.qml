import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Popups

import utils

StatusButton {
    id: root

    property int showcaseVisibility: Constants.ShowcaseVisibility.Everyone

    signal visibilitySelected(int showcaseVisibility)

    implicitWidth: d.maxTextWidth + 2 * horizontalPadding + indicator.width + icon.width + 2 * spacing
    hoverColor: normalColor
    normalColor: Theme.palette.primaryColor1
    textColor: Theme.palette.indirectColor1
    text: (showcaseVisibilityGroup.checkedButton as ShowcaseVisibilityAction).selectedText
    textFillWidth: true
    icon.name: showcaseVisibilityGroup.checkedButton.icon.name

    indicator: StatusIcon {
        anchors.right: parent.right
        anchors.rightMargin: parent.horizontalPadding
        anchors.verticalCenter: parent.verticalCenter
        icon: "chevron-down"
        color: root.textColor
    }

    onClicked: {
        menu.open()
    }

    ButtonGroup {
        id: showcaseVisibilityGroup
        exclusive: true
        onClicked: (button) => root.visibilitySelected((button as ShowcaseVisibilityAction).showcaseVisibility)
    }

    StatusMenu {
        id: menu

        y: root.height + 4
        width: root.width

        ShowcaseVisibilityAction {
            showcaseVisibility: Constants.ShowcaseVisibility.Everyone
            text: qsTr("Stranger")
        }
        ShowcaseVisibilityAction {
            showcaseVisibility: Constants.ShowcaseVisibility.Contacts
            text: qsTr("Contact")
        }
        ShowcaseVisibilityAction {
            showcaseVisibility: Constants.ShowcaseVisibility.IdVerifiedContacts
            text: qsTr("Trusted contact")
        }
    }

    component ShowcaseVisibilityAction: StatusMenuItem {
        id: menuItem
        required property int showcaseVisibility

        readonly property string selectedText: qsTr("Preview as %1").arg(text)
        readonly property alias selectedTextWidth: textMetricsMaxWidth.width

        ButtonGroup.group: showcaseVisibilityGroup
        icon.name: ProfileUtils.visibilityIcon(showcaseVisibility)
        icon.color: Theme.palette.primaryColor1
        checked: root.showcaseVisibility === showcaseVisibility

        TextMetrics {
            id: textMetricsMaxWidth
            font: root.font
            text: menuItem.selectedText
        }
    }

    QtObject {
        id: d        
        property real maxTextWidth: {
                let max = 0
                for (var i = 0; i < showcaseVisibilityGroup.buttons.length; i++) {
                    max = Math.max(max, (showcaseVisibilityGroup.buttons[i] as ShowcaseVisibilityAction).selectedTextWidth)
                }
                return max
        }
    }
}
