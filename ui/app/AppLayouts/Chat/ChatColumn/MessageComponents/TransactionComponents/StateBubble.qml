import QtQuick 2.3
import QtGraphicalEffects 1.13
import "../../../../../../shared"
import "../../../../../../imports"

Rectangle {
    property string state: Constants.pending

    id: root
    width: childrenRect.width + 12
    height: childrenRect.height
    border.width: 1
    border.color: Style.current.border
    radius: 24

    SVGImage {
        id: stateImage
        source: {
            switch (root.state) {
            case Constants.pending:
            case Constants.addressReceived:
            case Constants.shared:
            case Constants.addressRequested: return "../../../../../img/dotsLoadings.svg"
            case Constants.confirmed: return "../../../../../img/check.svg"
            case Constants.unknown:
            case Constants.failure:
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
        color: state == Constants.confirmed ? Style.current.transparent : Style.current.text
    }

    StyledText {
        id: stateText
        color: {
            if (root.state === Constants.unknown || root.state === Constants.failure) {
                return Style.current.danger
            }
            if (root.state === Constants.confirmed || root.state === Constants.declined) {
                return Style.current.text
            }

            return Style.current.secondaryText
        }
        text: {
            switch (root.state) {
            case Constants.pending: return qsTr("Pending")
            case Constants.confirmed: return qsTr("Confirmed")
            case Constants.unknown: return qsTr("Unknown token")
            case Constants.addressRequested: return qsTr("Address requested")
            case Constants.addressReceived: return qsTr("Address received")
            case Constants.declined: return qsTr("Transaction declined")
            case Constants.shared: return qsTr("Shared ‘Other Account’")
            case Constants.failure: return qsTr("Failure")
            default: return qsTr("Unknown state")
            }
        }
        font.weight: Font.Medium
        anchors.left: stateImage.right
        anchors.leftMargin: 4
        bottomPadding: Style.current.halfPadding
        topPadding: Style.current.halfPadding
        font.pixelSize: 13
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#808080";formeditorZoom:2}
}
##^##*/
