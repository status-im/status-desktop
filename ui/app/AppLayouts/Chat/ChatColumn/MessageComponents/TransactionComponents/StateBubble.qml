import QtQuick 2.3
import QtGraphicalEffects 1.13
import "../../../../../../shared"
import "../../../../../../imports"

Rectangle {
    property int state: Constants.pending
    property bool outgoing: true

    id: root
    width: childrenRect.width + 24
    height: 28
    border.width: 1
    border.color: Style.current.border
    radius: 24
    color: Style.current.background

    SVGImage {
        id: stateImage
        source: {
            switch (root.state) {
            case Constants.pending:
            case Constants.addressReceived:
            case Constants.transactionRequested:
            case Constants.addressRequested: return "../../../../../img/dotsLoadings.svg"
            case Constants.confirmed: return "../../../../../img/check.svg"
            case Constants.transactionDeclined:
            case Constants.declined: return "../../../../../img/exclamation.svg"
            default: return ""
            }
        }
        width: 16
        height: 16
        anchors.left: parent.left
        anchors.leftMargin: Style.current.halfPadding
        anchors.verticalCenter: stateText.verticalCenter
    }

    ColorOverlay {
        anchors.fill: stateImage
        source: stateImage
        color: state === Constants.confirmed ? Style.current.transparent : Style.current.textColor
    }

    StyledText {
        id: stateText
        color: {
            if (root.state === Constants.unknown || root.state === Constants.failure) {
                return Style.current.danger
            }
            if (root.state === Constants.confirmed || root.state === Constants.declined) {
                return Style.current.textColor
            }

            return Style.current.secondaryText
        }
        text: {
            switch (root.state) {
            case Constants.pending: return qsTr("Pending")
            case Constants.confirmed: return qsTr("Confirmed")
            case Constants.unknown: return qsTr("Unknown token")
            case Constants.addressRequested: return qsTr("Address requested")
            case Constants.transactionRequested: return qsTr("Waiting to accept")
            case Constants.addressReceived: return (!root.outgoing ? 
                qsTr("Address shared") : 
                qsTr("Address received"))
            case Constants.transactionDeclined:
            case Constants.declined: return qsTr("Transaction declined")
            case Constants.failure: return qsTr("failure")
            default: return qsTr("Unknown state")
            }
        }
        font.weight: Font.Medium
        anchors.left: stateImage.right
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 13
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#808080";formeditorZoom:2}
}
##^##*/
