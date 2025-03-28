import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

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

    property real maxImplicitWidth: 640
    readonly property color defaultIconColor: Theme.palette.primaryColor1

    property int type: StatusAction.Type.Normal

    property StatusAssetSettings assetSettings: StatusAssetSettings {
        width: 18
        height: 18
        rotation: 0
        isLetterIdenticon: false
        isImage: false
        color: {
            if (!root.enabled)
                return Theme.palette.baseColor1
            if (root.type === StatusAction.Type.Danger)
                return Theme.palette.dangerColor1
            if (root.type === StatusAction.Type.Success)
                return Theme.palette.successColor1
            return Theme.palette.primaryColor1
        }
    }

    property StatusFontSettings fontSettings: StatusFontSettings {}

    property StatusIdenticonRingSettings ringSettings: StatusIdenticonRingSettings {
        ringPxSize: root.assetSettings.ringPxSize
        distinctiveColors: Theme.palette.identiconRingColors
    }

    property bool hideDisabledItems: true

    property var openHandler
    property var closeHandler

    dim: false
    closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
    topPadding: Theme.halfPadding
    bottomPadding: Theme.halfPadding
    margins: Theme.padding

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
        visible: root.hideDisabledItems && !visibleOnDisabled ? enabled : true
        height: visible ? implicitHeight : 0
    }

    contentItem: StatusScrollView {
        id: scrollView
        padding: 0

        ColumnLayout {
            spacing: 0
            Repeater {
                model: root.contentModel

                onItemAdded: (index, item) => {
                    item.Layout.fillWidth = true
                    item.Layout.minimumWidth = scrollView.width
                    item.Layout.maximumWidth = root.maxImplicitWidth
                }
            }
        }
    }

    background: Rectangle {
        id: backgroundContent
        implicitWidth: 176
        color: Theme.palette.statusMenu.backgroundColor
        radius: Theme.radius
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
