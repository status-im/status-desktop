import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

import StatusQ.Core.Theme

import utils
import ".."
import "../panels"

Item {
    id: root
    property bool isValid: true
    property alias errorMessage: txtValidationError.text
    property alias secondaryErrorMessage: txtValidationExtraInfo.text
    property var images: []
    property var validImages: []

    visible: !isValid
    width: imgExclamation.width + txtValidationError.width + txtValidationExtraInfo.width + 24
    height: txtValidationError.height + 14

    Rectangle {
        anchors.fill: parent
        color: Theme.palette.background
        radius: Theme.halfPadding
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 3
            radius: 8
            samples: 15
            fast: true
            cached: true
            color: "#22000000"
        }

        SVGImage {
            id: imgExclamation
            width: 20
            height: 20
            sourceSize.height: height * 2
            sourceSize.width: width * 2
            verticalAlignment: Image.AlignVCenter
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 6
            anchors.leftMargin: 6
            fillMode: Image.PreserveAspectFit
            source: Theme.svg("exclamation_outline")
        }
        StyledText {
            id: txtValidationError
            verticalAlignment: Text.AlignVCenter
            anchors.top: parent.top
            anchors.left: imgExclamation.right
            anchors.topMargin: 7
            anchors.leftMargin: 6
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.additionalTextSize
            height: 18
            color: Theme.palette.dangerColor1
        }
        StyledText {
            id: txtValidationExtraInfo
            verticalAlignment: Text.AlignVCenter
            anchors.top: parent.top
            anchors.left: txtValidationError.right
            anchors.topMargin: 7
            anchors.leftMargin: 6
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.additionalTextSize
            height: 18
            color: Theme.palette.textColor
        }
    }
}
