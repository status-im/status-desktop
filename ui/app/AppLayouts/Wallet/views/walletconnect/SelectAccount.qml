import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0

import "../../../Profile/controls"

ListView {
    id: root

    property ButtonGroup buttonGroup

    signal accountSelected(string address)

    delegate: WalletAccountDelegate {
        implicitWidth: root.width
        nextIconVisible: false

        account: model
        totalCount: ListView.view.count

        components: StatusRadioButton {
            ButtonGroup.group: root.buttonGroup
            onClicked: {
                root.accountSelected(model.address)
            }
        }
    }
}
