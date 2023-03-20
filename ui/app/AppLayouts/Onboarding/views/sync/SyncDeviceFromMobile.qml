import QtQuick 2.13
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.13

import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Column {
    id: root

    property list<StatusValidator> validators

    signal qrCodeScanned(value: string)

    spacing: 12

    QtObject {
        id: d

        property string errorMessage
        property string lastTag
        property int counter: 0
    }

    StatusQrCodeScanner {
        id: scanner

        width: parent.width
        implicitHeight: 330

        onTagFound: {
//            if (tag === d.lastTag) {
//                console.log("<<< equals to last tag", tag, counter++)
//                return
//            }

            console.log("<<< validating", tag)

            d.lastTag = tag

            for (let i in validators) {
                const validator = validators[i]
                if (!validator.validate(tag)) {
                    d.errorMessage = validator.errorMessage
                    return
                }
                d.errorMessage = ""
                root.qrCodeScanned(value)
            }
        }
    }

    Item {
        width: parent.width
        height: 16
    }

    StatusBaseText {
        width: parent.width
        wrapMode: Text.WordWrap
        color: Theme.palette.dangerColor1
        horizontalAlignment: Text.AlignHCenter
        text: d.errorMessage
    }

    StatusBaseText {
        width: parent.width
        wrapMode: Text.WordWrap
        color: Theme.palette.baseColor1
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("Ensure that the QR code is in focus to scan")
    }
}
