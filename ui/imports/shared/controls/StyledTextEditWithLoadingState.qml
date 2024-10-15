import QtQuick 2.15

import utils 1.0

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

StyledTextEdit {
    id: root

    property bool loading: false
    property color customColor: Theme.palette.textColor

    color: loading ? "transparent" : customColor

    Loader {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        active: root.loading
        sourceComponent: LoadingComponent {
            radius: textMetrics.font.pixelSize <= 15 ? 4 : 8
            height: textMetrics.tightBoundingRect.height
            width: Math.min(root.width, 140)
        }
    }
    TextMetrics {
        id: textMetrics
        font: root.font
        text: root.text
    }
}
