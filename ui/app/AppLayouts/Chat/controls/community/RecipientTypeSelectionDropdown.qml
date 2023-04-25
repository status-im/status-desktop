import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Controls 0.1


StatusDropdown {
    id: root

    signal ethAddressesSelected
    signal communityMembersSelected

    width: 289
    padding: 8
    leftPadding: 16

    contentItem: ColumnLayout {
        spacing: 8

        StatusIconTextButton {
            Layout.preferredHeight: 36
            Layout.fillWidth: true

            spacing: 9
            statusIcon: "address"
            icon.width: 15
            icon.height: 15
            text: qsTr("ETH adresses")

            onClicked: root.ethAddressesSelected()
        }

        StatusIconTextButton {
            Layout.preferredHeight: 36
            Layout.fillWidth: true

            spacing: 9
            statusIcon: "profile"
            icon.width: 15
            icon.height: 15
            text: qsTr("Community members")

            onClicked: root.communityMembersSelected()
        }
    }
}
