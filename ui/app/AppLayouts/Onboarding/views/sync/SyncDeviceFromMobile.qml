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

    signal connectionStringFound(connectionString: string)

    spacing: 12

    QtObject {
        id: d

        property string errorMessage
        property string lastTag
        property int counter: 0

        function validateConnectionString(connectionString) {
            for (let i in root.validators) {
                const validator = root.validators[i]
                if (!validator.validate(connectionString)) {
                    d.errorMessage = validator.errorMessage
                    return
                }
                d.errorMessage = ""
                root.connectionStringFound(connectionString)
            }
        }
    }

    StatusQrCodeScanner {
        id: scanner
        anchors.horizontalCenter: parent.horizontalCenter
        width: 330
        height: 330
        onLastTagChanged: {
            d.validateConnectionString(lastTag)
        }
    }

    Item {
        width: parent.width
        height: 16
    }

    StatusBaseText {
        width: parent.width
        opacity: scanner.currentTag ? 1 : 0
        wrapMode: Text.WordWrap
        color: Theme.palette.dangerColor1
        horizontalAlignment: Text.AlignHCenter
        text: d.errorMessage
    }

    StatusBaseText {
        width: parent.width
        opacity: scanner.camera ? 1 : 0
        wrapMode: Text.WordWrap
        color: Theme.palette.baseColor1
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("Ensure that the QR code is in focus to scan")
    }
}
