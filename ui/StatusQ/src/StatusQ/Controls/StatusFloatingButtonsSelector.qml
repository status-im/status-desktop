import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

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
    id: floatingButtons

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
    property alias popupMenuDelegate: popupMenuSelectionRepeater.delegate

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
        visibleIndices = [0,1,index]
        floatingButtons.currentIndex = index
        popupMenu.close()
    }

    height: 32
    spacing: 12
    clip: true

    Repeater {
        id: itemSelectionRepeater
        model: floatingButtons.model
    }

    Rectangle {
        width: button.width
        height: button.height
        radius: 8
        visible: floatingButtons.model.count > 3
        color: Theme.palette.statusAppLayout.backgroundColor
        StatusButton {
            id: button
            implicitHeight: 32
            topPadding: 8
            bottomPadding: 0
            defaultLeftPadding: 4
            defaultRightPadding: 4
            normalColor: "transparent"
            icon.name: "more"
            icon.background.color: "transparent"
            onClicked: popupMenu.popup(parent.x, y + height + 8)
        }
    }

    // Empty item to fill up empty space
    Item {
        Layout.preferredHeight: parent.height
        Layout.fillWidth: true
    }

    StatusPopupMenu {
        id: popupMenu
        width: layout.width
        ColumnLayout {
            id: layout
            Repeater {
                id: popupMenuSelectionRepeater
                model: floatingButtons.model
            }
        }
    }
}
