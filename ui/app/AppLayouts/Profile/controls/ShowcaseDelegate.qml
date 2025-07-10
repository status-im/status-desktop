import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import QtQml 2.15

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import AppLayouts.Wallet.controls 1.0

import utils 1.0
import shared.controls 1.0

StatusDraggableListItem {
    id: root

    property alias actionComponent: additionalActionsLoader.sourceComponent

    property int showcaseVisibility: Constants.ShowcaseVisibility.NoOne
    property int showcaseMaxVisibility: Constants.ShowcaseVisibility.Everyone

    property bool blurState: false
    property bool contextMenuEnabled: true
    property string tooltipTextWhenContextMenuDisabled

    signal showcaseVisibilityRequested(int value)

    component ShowcaseVisibilityAction: StatusMenuItem {
        id: menuItem
        required property int showcaseVisibility

        ButtonGroup.group: showcaseVisibilityGroup
        icon.name: ProfileUtils.visibilityIcon(showcaseVisibility)
        icon.color: Theme.palette.primaryColor1
        checked: root.showcaseVisibility === showcaseVisibility
        
        enabled: root.showcaseMaxVisibility >= showcaseVisibility
    }

    layer.enabled: root.blurState
    layer.effect: fastBlur

    height: ProfileUtils.defaultDelegateHeight
    topInset: 0
    bottomInset: 0
    changeColorOnDragActive: false
    bgColor: Theme.palette.getColor(Theme.palette.statusAppLayout.rightPanelBackgroundColor, 0.7)

    icon.width: 40
    icon.height: 40

    draggable: true
    dragAxis: Drag.XAndYAxis

    actions: [
        Loader {
            id: additionalActionsLoader

            Layout.maximumWidth: root.width *.4
        },
        StatusButton {
            interactive: root.contextMenuEnabled
            tooltip.text: root.tooltipTextWhenContextMenuDisabled
            icon.name: ProfileUtils.visibilityIcon(root.showcaseVisibility)
            horizontalPadding: Theme.halfPadding
            verticalPadding: 3
            Layout.preferredWidth: 72
            Layout.preferredHeight: root.height/2
            radius: height/2
            highlighted: menuLoader.item && menuLoader.item.opened
            onClicked: {
                menuLoader.active = true
                menuLoader.item.popup(width - menuLoader.item.width, height)
            }
            text: "    " // NB to give the icon and indicator some even space

            indicator: StatusIcon {
                anchors.right: parent.right
                anchors.rightMargin: parent.horizontalPadding
                anchors.verticalCenter: parent.verticalCenter
                icon: "chevron-down"
                color: parent.interactive ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
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
                        id: everyoneAction
                        showcaseVisibility: Constants.ShowcaseVisibility.Everyone
                        text: enabled ? qsTr("Everyone") : qsTr("Everyone (set account to Everyone)")
                    }
                    ShowcaseVisibilityAction {
                        id: contactsAction
                        showcaseVisibility: Constants.ShowcaseVisibility.Contacts
                        text: enabled ? qsTr("Contacts") : qsTr("Contacts (set account to Contacts)")
                    }

                    StatusMenuSeparator {}

                    ShowcaseVisibilityAction {
                        showcaseVisibility: Constants.ShowcaseVisibility.NoOne
                        text: qsTr("No one")
                    }
                }
            }
        }
    ]

    Component {
        id: fastBlur

        FastBlur {
            radius: 32
            transparentBorder: true
        }
    }
}
