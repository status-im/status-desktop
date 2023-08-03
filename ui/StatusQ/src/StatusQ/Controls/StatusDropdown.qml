import QtQuick 2.15
import QtGraphicalEffects 1.15
import QtQuick.Controls 2.15 as QC
import QtQml 2.15

import StatusQ.Core.Theme 0.1

/*!
   \qmltype StatusDropdown
   \inherits Popup
   \inqmlmodule StatusQ.Controls
   \since StatusQ.Controls 0.1
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
    id: root

    dim: false
    closePolicy: QC.Popup.CloseOnPressOutside | QC.Popup.CloseOnEscape
    background: Rectangle {
       color: Theme.palette.statusMenu.backgroundColor
       radius: 8
       border.color: "transparent"
       layer.enabled: true
       layer.effect: DropShadow {
           source: root.background
           horizontalOffset: 0
           verticalOffset: 4
           radius: 12
           samples: 25
           spread: 0.2
           color: Theme.palette.dropShadow
       }
    }

    // workaround for https://bugreports.qt.io/browse/QTBUG-87804
    Binding on margins{
        id: workaroundBinding

        when: false
        restoreMode: Binding.RestoreBindingOrValue
    }

    onImplicitContentHeightChanged: {
        workaroundBinding.value = root.margins + 1
        workaroundBinding.when = true
        workaroundBinding.when = false
    }
}
