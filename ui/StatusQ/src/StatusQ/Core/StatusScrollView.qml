import QtQuick 2.14
import QtQuick.Controls 2.14

import StatusQ.Controls 0.1

/*!
   \qmltype StatusScrollView
   \inherits Flickable
   \inqmlmodule StatusQ.Core
   \since StatusQ.Core 0.1
   \brief ScrollView component based on a Flickable with padding and scrollbars.

   The \c StatusScrollView can be used just like a plain ScrollView but without ability to decarate existing Flickable.

   Example of how to use it:

   \qml
        StatusScrollView {
            id: scrollView
            anchors.fill: parent

            ColumnView {
                width: scrollView.availableWidth
            }
        }
   \endqml

   For a list of components available see StatusQ.
*/
Flickable {
    id: root

    // NOTE: this should be replaced with margins since Qt 5.15
    property int padding: 8
    property int topPadding: padding
    property int bottomPadding: padding
    property int leftPadding: padding
    property int rightPadding: padding

    readonly property int availableWidth: width - leftPadding - rightPadding
    readonly property int availableHeight: height - topPadding - bottomPadding

    // NOTE: in Qt6 clip true will be default
    clip: true
    topMargin: topPadding
    bottomMargin: bottomPadding
    leftMargin: leftPadding
    rightMargin: rightPadding
    contentWidth: contentItem.childrenRect.width
    contentHeight: contentItem.childrenRect.height
    implicitWidth: contentWidth + leftPadding + rightPadding
    implicitHeight: contentHeight + topPadding + bottomPadding
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
