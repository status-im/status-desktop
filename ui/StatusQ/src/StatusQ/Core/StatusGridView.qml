import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Controls 0.1

/*!
   \qmltype StatusGridView
   \inherits GridView
   \inqmlmodule StatusQ.Core
   \since StatusQ.Core 0.1
   \brief GridView wrapper with tuned scrolling and custom scrollbars.

   The \c StatusGridView can be used just like a plain GridView.

   Example of how to use it:

   \qml
        StatusGridView {
            id: GridView
            anchors.fill: parent
            model: someModel

            delegate: DelegateItem {
                ...
            }
        }
   \endqml

   For a Grid of components available see StatusQ.
*/
GridView {
    id: root

    clip: true
    boundsBehavior: Flickable.StopAtBounds
    maximumFlickVelocity: 1000000
    flickDeceleration: 1000000
    synchronousDrag: true
}
