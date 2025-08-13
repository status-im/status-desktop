import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Controls as QC
import QtQml

import StatusQ.Core.Theme

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

    property bool bottomSheetEnabled: true

    // The max width of a phone in portrait mode
    readonly property bool bottomSheet: !bottomSheetEnabled ? false:
                                            d.windowHeight > d.windowWidth
                                            && d.windowWidth <= Theme.portraitBreakpoint.width

    QtObject {
       id: d
       readonly property var window: root.contentItem.Window.window
       readonly property int windowWidth: window ? window.width: Screen.width
       readonly property int windowHeight: window ? window.height: Screen.height
    }

    modal: root.bottomSheet
    dim: root.bottomSheet

    Binding on parent {
        when: root.bottomSheet
        value: {
            return QC.Overlay && QC.Overlay.overlay ? QC.Overlay.overlay:
                   d.window && d.window.contentItem ? d.window.contentItem : parent
        }
    }
    Binding on closePolicy      { when: root.bottomSheet; value: QC.Popup.CloseOnPressOutside}
    Binding on x                { when: root.bottomSheet; value: 0}
    Binding on y                { when: root.bottomSheet; value: d.windowHeight - height}
    Binding on width            { when: root.bottomSheet; value: d.windowWidth}
    Binding on height           { when: root.bottomSheet; value: Math.min(implicitHeight, d.windowHeight * 0.9)}
    Binding on bottomPadding    { when: root.bottomSheet; value: !!d.window ? d.window.SafeArea.margins.bottom: 0}

    background: Rectangle {
       color: Theme.palette.statusMenu.backgroundColor
       radius: Theme.radius
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
    Binding on margins {
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
