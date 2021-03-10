import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.0
import "../../imports"
import ".."

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
            source: "../../app/img/exclamation_outline.svg"
        }
        StyledText {
            id: txtValidationError
            verticalAlignment: Text.AlignVCenter
            anchors.top: parent.top
            anchors.left: imgExclamation.right
            anchors.topMargin: 7
            anchors.leftMargin: 6
            wrapMode: Text.WordWrap
            font.pixelSize: 13
            height: 18
            color: Style.current.danger
        }
        StyledText {
            id: txtValidationExtraInfo
            verticalAlignment: Text.AlignVCenter
            anchors.top: parent.top
            anchors.left: txtValidationError.right
            anchors.topMargin: 7
            anchors.leftMargin: 6
            wrapMode: Text.WordWrap
            font.pixelSize: 13
            height: 18
            color: Style.current.textColor
        }
    }
}
