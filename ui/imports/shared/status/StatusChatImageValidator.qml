import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.0

import utils 1.0
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
        color: Style.current.background
        radius: Style.current.halfPadding
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: Style.dp(3)
            radius: Style.current.radius
            samples: 15
            fast: true
            cached: true
            color: "#22000000"
        }

        SVGImage {
            id: imgExclamation
            width: Style.dp(20)
            height: Style.dp(20)
            sourceSize.height: height * 2
            sourceSize.width: width * 2
            verticalAlignment: Image.AlignVCenter
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: Style.dp(6)
            anchors.leftMargin: Style.dp(6)
            fillMode: Image.PreserveAspectFit
            source: Style.svg("exclamation_outline")
        }
        StyledText {
            id: txtValidationError
            verticalAlignment: Text.AlignVCenter
            anchors.top: parent.top
            anchors.left: imgExclamation.right
            anchors.topMargin: Style.dp(7)
            anchors.leftMargin: Style.dp(6)
            wrapMode: Text.WordWrap
            font.pixelSize: Style.current.additionalTextSize
            height: Style.dp(18)
            color: Style.current.danger
        }
        StyledText {
            id: txtValidationExtraInfo
            verticalAlignment: Text.AlignVCenter
            anchors.top: parent.top
            anchors.left: txtValidationError.right
            anchors.topMargin: Style.dp(7)
            anchors.leftMargin: Style.dp(6)
            wrapMode: Text.WordWrap
            font.pixelSize: Style.current.additionalTextSize
            height: Style.dp(18)
            color: Style.current.textColor
        }
    }
}
