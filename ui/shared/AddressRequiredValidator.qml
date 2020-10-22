import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "./status"

Column {
    id: root
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: 5

    visible: !isValid || isWarn

    property bool isValid: true
    property bool isWarn: address == Constants.zeroAddress
    property alias errorMessage: txtValidationError.text
    property string address: ""

    SVGImage {
        id: imgExclamation
        width: 13.33
        height: 13.33
        sourceSize.height: height * 2
        sourceSize.width: width * 2
        anchors.horizontalCenter: parent.horizontalCenter
        fillMode: Image.PreserveAspectFit
        source: "../app/img/exclamation_outline.svg"
    }
    StyledText {
        id: txtValidationError
        //% "You need to request the recipient’s address first.\nAssets won’t be sent yet."
        text: qsTrId("you-need-to-request-the-recipient-s-address-first--nassets-won-t-be-sent-yet-")
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.pixelSize: 13
        height: 18
        color: Style.current.danger
    }
}
