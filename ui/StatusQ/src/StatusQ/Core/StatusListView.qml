import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Controls 0.1

/*!
   \qmltype StatusListView
   \inherits ListView
   \inqmlmodule StatusQ.Core
   \since StatusQ.Core 0.1
   \brief ListView wrapper with tuned scrolling and custom scrollbars.

   The \c StatusListView can be used just like a plain ListView.

   Example of how to use it:

   \qml
        StatusListView {
            id: listView
            anchors.fill: parent
            model: someModel

            delegate: DelegateItem {
                ...
            }
        }
   \endqml

   For a list of components available see StatusQ.
*/
ListView {
    id: root

    clip: true
    boundsBehavior: Flickable.StopAtBounds
    maximumFlickVelocity: 2000
    synchronousDrag: true

    ScrollBar.horizontal: StatusScrollBar {
        policy: ScrollBar.AsNeeded
        visible: resolveVisibility(policy, root.width, root.contentWidth)
    }

    ScrollBar.vertical: StatusScrollBar {
        policy: ScrollBar.AsNeeded
        visible: resolveVisibility(policy, root.height, root.contentHeight)
    }
}
