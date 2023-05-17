import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.impl 2.15
import QtQuick.Templates 2.15 as T

import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Core.Theme 0.1

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
            contentWidth: availableWidth

            ColumnView {
                width: scrollView.availableWidth
            }
        }
   \endqml

   For a list of components available see StatusQ.
*/

T.ScrollView {
    id: root

    readonly property Flickable flickable: root.contentItem

    function ensureVisible(rect) {
        Utils.ensureVisible(flickable, rect)
    }

    function applyFlickableFix() {
        flickable.boundsBehavior = Flickable.StopAtBounds
        flickable.maximumFlickVelocity = 2000
        flickable.synchronousDrag = true
    }

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    padding: 8
    clip: true

    Component.onCompleted: {
        applyFlickableFix()
    }

    ScrollBar.vertical: StatusScrollBar {
        parent: root
        x: root.mirrored ? 0 : root.width - width
        y: root.topPadding
        height: root.availableHeight
        active: root.ScrollBar.horizontal.active
        policy: ScrollBar.AsNeeded
        visible: resolveVisibility(policy, root.availableHeight, root.contentHeight)
    }

    ScrollBar.horizontal: StatusScrollBar {
        parent: root
        x: root.leftPadding
        y: root.height - height
        width: root.availableWidth
        active: root.ScrollBar.vertical.active
        policy: ScrollBar.AsNeeded
        visible: resolveVisibility(policy, root.availableWidth, root.contentWidth)
    }
}
