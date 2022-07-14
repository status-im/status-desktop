import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Controls 0.1

/*!
   \qmltype StatusScrollView
   \inherits ScrollView
   \inqmlmodule StatusQ.Core
   \since StatusQ.Core 0.1
   \brief ScrollView wrapper with tuned flickable.

   The \c StatusScrollView can be used just like a plain ScrollView but with tuned scrolling parameters.

   Example of how to use it:

   \qml
        StatusScrollView {
            id: scrollView
            anchors.fill: parent

            ColumnView {
                width: scrollView.avaiulableWidth
            }
        }
   \endqml

   For a list of components available see StatusQ.
*/
ScrollView {
    id: root

    clip: true // NOTE: in Qt6 clip true will be default
    background: null

    ScrollBar.horizontal.policy: ScrollBar.AsNeeded
    ScrollBar.vertical.policy: ScrollBar.AsNeeded

    Flickable {
        id: flickable

        contentWidth: contentItem.childrenRect.width
        contentHeight: contentItem.childrenRect.height
        boundsBehavior: Flickable.StopAtBounds
        maximumFlickVelocity: 0
        synchronousDrag: true
    }
}
