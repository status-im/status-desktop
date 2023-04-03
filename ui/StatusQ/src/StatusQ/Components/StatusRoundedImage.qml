import QtQuick 2.13
import QtGraphicalEffects 1.0
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

/*!
    \qmltype StatusRoundedImage
    \inherits StatusRoundedComponent
    \inqmlmodule StatusQ.Components
    \since StatusQ.Components 0.1
    \brief Specialization of StatusRoundedComponent with a StatusImage as content.

    Example of how to use it:

    \qml
        StatusRoundedImage {
            image.source: "qrc:/demoapp/data/logo-test-image.png"
        }
    \endqml
*/
StatusRoundedComponent {
    id: root

    property alias image: image

    isLoading: image.isLoading
    isError: image.isError

    StatusImage {
        id: image
        anchors.fill: parent
    }
}
