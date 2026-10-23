import QtQuick
import QtQuick.Controls

/*!
   \qmltype LoadingComponent
   \inherits Control
   \inqmlmodule StatusQ.Components
   \since StatusQ.Components 0.1
   \brief A component that can be used to adding a loading state to a widget
   Example:

   \qml
    StatusBaseText {
    id: root
        LoadingComponent {
            anchors.fill: parent
            radius: 8
        }
    }
   \endqml

   For a list of components available see StatusQ.
*/

Control {
    id: root

    /*!
        \qmlproperty bool LoadingComponent::radius
        This property lets user set custom radius
    */
    property int radius: 4

    background: null

    contentItem: LoadingSkeletonTile {
        radius: root.radius
    }
}
