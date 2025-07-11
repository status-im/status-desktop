import QtQuick

import StatusQ.Core
import StatusQ.Components
import StatusQ.Core.Theme

import utils


StatusFlowSelector {
    id: root

    property alias addressesModel: addressesSelectorPanel.model
    property alias membersModel: membersSelectorPanel.model

    property alias loadingAddresses: addressesSelectorPanel.loading
    property alias addressesInputText: addressesSelectorPanel.text

    property bool showAddressesInputWhenEmpty: false
    property int maxNumberOfRecipients: 0
    property bool infiniteMaxNumberOfRecipients: false

    readonly property int count: addressesSelectorPanel.count +
                                 membersSelectorPanel.count

    readonly property bool valid:
        addressesSelectorPanel.invalidAddressesCount === 0 &&
        (infiniteMaxNumberOfRecipients || count <= maxNumberOfRecipients)

    signal addAddressesRequested(string addresses)
    signal removeAddressRequested(int index)
    signal removeMemberRequested(int index)

    placeholderItem.visible: !addressesSelectorPanel.visible &&
                             !membersSelectorPanel.visible

    title: qsTr("To")
    icon: Theme.svg("member")
    flowSpacing: addressesSelectorPanel.visible || membersSelectorPanel.visible
                 ? 12 : 6

    placeholderText: qsTr("Example: 12 addresses and 3 members")

    function forceInputFocus() {
        addressesSelectorPanel.forceInputFocus()
    }

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

        readonly property bool valid: root.infiniteMaxNumberOfRecipients ||
                                      root.count <= root.maxNumberOfRecipients

        text: root.count + " / " + (root.infiniteMaxNumberOfRecipients
              ? qsTr("∞ recipients", "infinite number of recipients")
              : qsTr("%n recipient(s)", "", root.maxNumberOfRecipients))

        font.pixelSize: Theme.additionalTextSize
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
