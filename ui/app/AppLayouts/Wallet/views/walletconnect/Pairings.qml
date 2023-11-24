import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

ListView {
    id: root

    signal disconnect(string topic)

    delegate: Item {
        implicitWidth: delegateLayout.implicitWidth
        implicitHeight: delegateLayout.implicitHeight

        RowLayout {
            id: delegateLayout
            width: root.width

            StatusBaseText {
                text: `${SQUtils.Utils.elideText(model.topic, 6, 6)}\n${new Date(model.expiry * 1000).toLocaleString()}`
                color: model.active ? "green" : "orange"
            }
            StatusButton {
                text: "Disconnect"

                visible: model.active

                onClicked: {
                    root.disconnect(model.topic)
                }
            }
        }
    }
}