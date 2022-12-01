import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

/*!
    To create menu elements from a model, use Instantiator:

    \qml
        StatusMenu {
            id: myMenu

            StatusMenuInstantiator {
                model: myModel
                menu: myMenu
                delegate: StatusAction {
                    text: model.text
                    assetSettings.name: model.iconName
                    onTriggered: {
                        popupMenu.dismiss()
                    }
                }
            }
        }
    \endqml
 */

Menu {
    id: root

    readonly property color defaultIconColor: Theme.palette.primaryColor1

    property StatusAssetSettings assetSettings: StatusAssetSettings {
        width: 18
        height: 18
        rotation: 0
        isLetterIdenticon: false
        isImage: false
        color: root.defaultIconColor
    }

    property StatusFontSettings fontSettings: StatusFontSettings {}

    property StatusIdenticonRingSettings ringSettings: StatusIdenticonRingSettings {
        ringPxSize: root.assetSettings.ringPxSize
        distinctiveColors: Theme.palette.identiconRingColors
    }

    property bool hideDisabledItems: true

    property var openHandler
    property var closeHandler

    signal menuItemClicked(int menuIndex)

    dim: false
    closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
    topPadding: 8
    bottomPadding: 8
    bottomMargin: 16

    onOpened: {
        if (typeof openHandler === "function") {
            openHandler()
        }
    }

    onClosed: {
        if (typeof closeHandler === "function") {
            closeHandler()
        }
    }

    delegate: StatusMenuItem {
        visible: root.hideDisabledItems ? enabled : true
        height: visible ? implicitHeight : 0
    }

    contentItem: StatusListView {
        currentIndex: root.currentIndex
        implicitHeight: contentHeight
        implicitWidth: contentWidth
        interactive: contentHeight > availableHeight
        model: root.contentModel
    }

    background: Rectangle {
        id: backgroundContent
        implicitWidth: 176
        color: Theme.palette.statusMenu.backgroundColor
        radius: 8
        layer.enabled: true
        layer.effect: DropShadow {
            width: backgroundContent.width
            height: backgroundContent.height
            x: backgroundContent.x
            visible: backgroundContent.visible
            source: backgroundContent
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12
            samples: 25
            spread: 0.2
            color: Theme.palette.dropShadow
        }
    }
}
