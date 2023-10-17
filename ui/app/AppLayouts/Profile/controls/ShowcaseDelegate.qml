import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusDraggableListItem {
    id: root

    property var showcaseObj
    property int showcaseVisibility: Constants.ShowcaseVisibility.NoOne

    signal showcaseVisibilityRequested(int value)

    component ShowcaseVisibilityAction: StatusMenuItem {
        property int showcaseVisibility: Constants.ShowcaseVisibility.NoOne
        icon.name: ProfileUtils.visibilityIcon(showcaseVisibility)
        icon.color: Theme.palette.primaryColor1
    }

    icon.width: 40
    icon.height: 40

    draggable: true
    dragAxis: Drag.XAndYAxis

    actions: [
        StatusRoundButton {
            icon.name: ProfileUtils.visibilityIcon(root.showcaseVisibility)
            Layout.preferredWidth: 58
            Layout.preferredHeight: 28
            border.width: 1
            border.color: Theme.palette.directColor7
            radius: 14
            highlighted: menuLoader.item && menuLoader.item.opened
            onClicked: {
                menuLoader.active = true
                menuLoader.item.popup(width - menuLoader.item.width, height)
            }

            ButtonGroup {
                id: showcaseVisibilityGroup
                exclusive: true
                onClicked: function(button) {
                    const newVisibility = (button as ShowcaseVisibilityAction).showcaseVisibility
                    if (newVisibility !== root.showcaseVisibility)
                        root.showcaseVisibilityRequested(newVisibility)
                }
            }

            Loader {
                id: menuLoader
                active: false
                sourceComponent: StatusMenu {
                    onClosed: menuLoader.active = false
                    StatusMenuHeadline { text: qsTr("Show to") }

                    ShowcaseVisibilityAction {
                        ButtonGroup.group: showcaseVisibilityGroup
                        showcaseVisibility: Constants.ShowcaseVisibility.Everyone
                        text: qsTr("Everyone")
                        checked: root.showcaseVisibility === showcaseVisibility
                    }
                    ShowcaseVisibilityAction {
                        ButtonGroup.group: showcaseVisibilityGroup
                        showcaseVisibility: Constants.ShowcaseVisibility.Contacts
                        text: qsTr("Contacts")
                        checked: root.showcaseVisibility === showcaseVisibility
                    }
                    ShowcaseVisibilityAction {
                        ButtonGroup.group: showcaseVisibilityGroup
                        showcaseVisibility: Constants.ShowcaseVisibility.IdVerifiedContacts
                        text: qsTr("ID verified contacts")
                        checked: root.showcaseVisibility === showcaseVisibility
                    }

                    StatusMenuSeparator {}

                    ShowcaseVisibilityAction {
                        ButtonGroup.group: showcaseVisibilityGroup
                        showcaseVisibility: Constants.ShowcaseVisibility.NoOne
                        text: qsTr("No one")
                        checked: root.showcaseVisibility === showcaseVisibility
                    }
                }
            }
        }
    ]
}
