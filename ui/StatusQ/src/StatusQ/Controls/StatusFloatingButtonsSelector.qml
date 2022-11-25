import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import SortFilterProxyModel 0.2

/*!
   \qmltype StatusModalFloatingButtonsSelector
   \inherits Row
   \inqmlmodule StatusQ.Controls
   \since StatusQ.Controls 0.1
   \brief The StatusModalFloatingButtonsSelector provides a template for creating a selectable buttons list
   this list can be parially hidden and the rest of the items are shown under the more button in a popup

   Example of how to use it:

   \qml
        StatusModalFloatingButtonsSelector {
            id: floatingHeader
            model: dummyAccountsModel
            delegate: StatusAccountSelectorTag {
                title: "name"
                icon.name: "iconName"
                isSelected: floatingHeader.currentIndex === index
                visible: visibleIndices.includes(index)
                onClicked: floatingHeader.currentIndex = index
            }
            popupMenuDelegate: StatusListItem {
                implicitWidth: 272
                title: "name"
                onClicked: floatingHeader.itemSelected(index)
                visible: !visibleIndices.includes(index)
            }
        }
   \endqml

   For a list of components available see StatusQ.
*/
Row {
    id: root

    /*!
       \qmlproperty repeater
        This property represents the repeater of selectable items shown to the user.
        Can be used to assign objectName to the repeater
        \endqml
    */
    readonly property alias repeater: itemSelectionRepeater

    /*!
       \qmlproperty delegate
        This property represents the delegate of selectable items shown to the user.
        Can be used to assign delegate to the buttons selector
        \endqml
    */
    property alias delegate: itemSelectionRepeater.delegate
    /*!
       \qmlproperty popupMenuDelegate
        This property represents the delegate of popupmenu fropm which items can be selected by the user.
        Can be used to assign delegate to the popupmenu
        \endqml
    */
    property alias popupMenuDelegate: popupMenuSelectionInstantiator.delegate

    /*!
       \qmlproperty model
        This property represents the model of selectable items shown to the user.
        Can be used to assign selectable items in the buttons selector
        \endqml
    */
    property var model
    /*!
       \qmlproperty visibleIndices
        This property represents the indices from the selectable items that will visible to the user
        Can be used to set visible items in the buttons selector
        \endqml
    */
    property var visibleIndices: [0,1,2]
    /*!
       \qmlproperty currentIndex
        This property represents the index of the currently selected item
        Can be used to set the currnetly selected item in the buttons selector
        \endqml
    */
    property int currentIndex: 0

    function itemSelected(index) {
        visibleIndices = [0, 1, visibleIndices.length + index]
        root.currentIndex = index
        popupMenu.close()
    }

    height: 32
    spacing: 12
    clip: true

    SortFilterProxyModel {
        id: menuModel

        sourceModel: root.model

        filters: [
            ExpressionFilter {
                enabled: root.visibleIndices.length > 0
                expression: !root.visibleIndices.includes(index)
            }
        ]
    }

    Repeater {
        id: itemSelectionRepeater
        model: root.model
    }

    Rectangle {
        width: button.width
        height: button.height
        radius: 8
        visible: root.model.count > 3
        color: Theme.palette.statusAppLayout.backgroundColor
        StatusButton {
            id: button
            implicitHeight: 32
            topPadding: 8
            bottomPadding: 0
            horizontalPadding: 4
            hoverColor: Theme.palette.statusFloatingButtonHighlight
            normalColor: Theme.palette.baseColor3
            asset.name: "more"
            asset.bgColor: "transparent"
            onClicked: popupMenu.popup(parent.x + 4, y + height + 4)
        }
    }

    // Empty item to fill up empty space
    Item {
        Layout.preferredHeight: parent.height
        Layout.fillWidth: true
    }

    StatusPopupMenu {
        id: popupMenu
        width: implicitWidth

        StatusMenuInstantiator {
            id: popupMenuSelectionInstantiator
            model: menuModel
            menu: popupMenu
        }
    }
}
