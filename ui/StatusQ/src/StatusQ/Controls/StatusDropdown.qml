import QtQuick 2.13
import QtGraphicalEffects 1.13
import QtQuick.Controls 2.14 as QC

import StatusQ.Core.Theme 0.1

/*!
   \qmltype StatusDropdown
   \inherits Popup
   \inqmlmodule StatusQ.Popups
   \since StatusQ.Popups 0.1
   \brief The StatusDropdown provides a template for creating dropdowns.

   NOTE: Each consumer needs to set the x and y postion of the dropdown.

   Example of how to use it:

   \qml
        StatusDropdown {
            x: root.x + margins
            y: root.y + margins
            contentItem: ColumnLayout {
                ...
            }
        }
   \endqml

   For a list of components available see StatusQ.
*/
QC.Popup {
    dim: false
    closePolicy: QC.Popup.CloseOnPressOutside | QC.Popup.CloseOnEscape
    background: Rectangle {
       id: border
       color: Theme.palette.statusPopupMenu.backgroundColor
       radius: 8
       border.color: "transparent"
       layer.enabled: true
       layer.effect: DropShadow {
           source: border
           horizontalOffset: 0
           verticalOffset: 4
           radius: 12
           samples: 25
           spread: 0.2
           color: Theme.palette.dropShadow
       }
    }
}
