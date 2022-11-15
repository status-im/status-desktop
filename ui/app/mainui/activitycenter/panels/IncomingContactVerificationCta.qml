import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import shared 1.0
import utils 1.0

StatusFlatButton {
    id: root

    property int verificationStatus: -1

    signal activate()

    enabled: verificationStatus == Constants.verificationStatus.verifying ||
             verificationStatus == Constants.verificationStatus.verified
    size: StatusBaseButton.Size.Small
    text: {
        switch (verificationStatus) {
        case Constants.verificationStatus.verifying:
            return qsTr("Answer")
        case Constants.verificationStatus.verified:
            return qsTr("Edit Answer")
        case Constants.verificationStatus.canceled:
            return qsTr("Canceled")
        case Constants.verificationStatus.declined:
            return qsTr("Declined")
        // That should never happen
        case Constants.verificationStatus.trusted:
        case Constants.verificationStatus.untrustworthy:
        case Constants.verificationStatus.unverified:
        default:
            return qsTr("Unknown")
        }
    }
    disabledTextColor: {
        switch (verificationStatus) {
        case Constants.verificationStatus.declined:
            return Theme.palette.dangerColor1
        case Constants.verificationStatus.trusted:
            return Theme.palette.successColor1
        default:
            return Theme.palette.baseColor1
        }
    }

    onClicked: root.activate()
}