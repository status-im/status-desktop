import QtQuick 2.13
import QtGraphicalEffects 1.0
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

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
