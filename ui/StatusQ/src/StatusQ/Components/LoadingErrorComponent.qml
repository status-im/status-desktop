import QtQuick 2.13
import QtQuick.Controls 2.12

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

/*!
   \qmltype LoadingErrorComponent
   \inherits Control
   \inqmlmodule StatusQ.Components
   \since StatusQ.Components 0.1
   \brief A component that can be used to adding a load error state to a widget
   Example:

   \qml
    AnimatedImage {
        id: root
        LoadingErrorComponent {
            visible: root.status === AnimatedImage.Error
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

    /*!
        \qmlproperty string LoadingComponent::text
        This property lets user set error message
    */
    property string text: qsTr("Failed\nto load")

    /*!
        \qmlproperty string LoadingComponent::icon
        This property lets user set error icon
    */
    property alias icon: errorIcon.icon

    background: Rectangle {
        color: Theme.palette.baseColor4
        radius: root.radius
    }

    contentItem: Item {
        Column {
            anchors.centerIn: parent
            spacing: 10
            StatusIcon {
                id: errorIcon

                anchors.horizontalCenter: parent.horizontalCenter
                icon: "frowny"
                color: Theme.palette.directColor7
            }
            StatusBaseText {
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Qt.AlignHCenter
                color: Theme.palette.directColor6
                text: root.text
            }
        }
    }
}
