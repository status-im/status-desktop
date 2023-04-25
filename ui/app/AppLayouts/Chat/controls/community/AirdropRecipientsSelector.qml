import QtQuick 2.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0


StatusFlowSelector {
    id: root

    property alias addressesModel: addressesSelectorPanel.model
    property alias membersModel: membersSelectorPanel.model

    property alias loadingAddresses: addressesSelectorPanel.loading
    property alias addressesInputText: addressesSelectorPanel.text

    property bool showAddressesInputWhenEmpty: false
    property int expectedNumberOfRecipients: 0
    property bool infiniteExpectedNumberOfRecipients: false

    readonly property int count: addressesSelectorPanel.count +
                                 membersSelectorPanel.count

    readonly property bool valid:
        addressesSelectorPanel.invalidAddressesCount === 0

    signal addAddressesRequested(string addresses)
    signal removeAddressRequested(int index)
    signal removeMemberRequested(int index)

    placeholderItem.visible: !addressesSelectorPanel.visible &&
                             !membersSelectorPanel.visible

    title: qsTr("To")
    icon: Style.svg("member")
    flowSpacing: 12

    placeholderText: qsTr("Example: 12 addresses and 3 members")

    function clearAddressesInput() {
        addressesSelectorPanel.clearInput()
    }

    function positionAddressesListAtEnd() {
        addressesSelectorPanel.positionListAtEnd()
    }

    function positionMembersListAtEnd() {
        membersSelectorPanel.positionListAtEnd()
    }

    StatusBaseText {
        parent: label

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right

        readonly property bool valid: root.infiniteExpectedNumberOfRecipients ||
                                      root.count <= root.expectedNumberOfRecipients

        text: root.count + " / " + (root.infiniteExpectedNumberOfRecipients
              ? qsTr("∞ recipients", "infinite number of recipients")
              : qsTr("%n recipient(s)", "", root.expectedNumberOfRecipients))

        font.pixelSize: Theme.tertiaryTextFontSize + 1
        color: valid ? Theme.palette.baseColor1 : Theme.palette.dangerColor1
        elide: Text.ElideRight
    }

    AddressesSelectorPanel {
        id: addressesSelectorPanel

        visible: count > 0 || root.showAddressesInputWhenEmpty
        width: root.availableWidth

        Component.onCompleted: {
            addAddressesRequested.connect(root.addAddressesRequested)
            removeAddressRequested.connect(root.removeAddressRequested)
        }
    }

    MembersSelectorPanel {
        id: membersSelectorPanel

        visible: count > 0
        width: root.availableWidth

        Component.onCompleted: removeMemberRequested.connect(
                                   root.removeMemberRequested)
    }
}
