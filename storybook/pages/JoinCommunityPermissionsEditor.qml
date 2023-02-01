import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Models 1.0

import utils 1.0

ColumnLayout {
    id: root

    property string channelName: "#vip"
    property bool joinCommunity: true // Otherwise, enter channel
    property bool requirementsMet: true
    property bool isInvitationPending: false
    property bool isJoinRequestRejected: false
    property bool requiresRequest: false
    property var communityHoldings: PermissionsModel.shortPermissionsModel
    property var viewOnlyHoldings: PermissionsModel.shortPermissionsModel
    property var viewAndPostHoldings: PermissionsModel.shortPermissionsModel
    property var moderateHoldings: PermissionsModel.shortPermissionsModel

    spacing: 16

    ColumnLayout {
        Label {
            Layout.fillWidth: true
            text: "View type:"
        }

        RadioButton {
            checked: true
            text: "Join community"
            onCheckedChanged: if(checked) d.joinCommunity =  true
        }
        RadioButton {
            text: "Enter channel"
            onCheckedChanged: if(checked) d.joinCommunity = false
        }
    }

    ColumnLayout {
        Label {
            Layout.fillWidth: true
            text: "Requirements met:"
        }

        CheckBox {
            checked: root.requirementsMet
            onCheckedChanged: root.requirementsMet = checked
        }
    }

    ColumnLayout {
        Label {
            Layout.fillWidth: true
            text: "Request pending:"
        }

        CheckBox {
            checked: root.isInvitationPending
            onCheckedChanged: root.isInvitationPending = checked
        }
    }

    ColumnLayout {
        Label {
            Layout.fillWidth: true
            text: "Request rejected:"
        }

        CheckBox {
            checked: root.isJoinRequestRejected
            onCheckedChanged: root.isJoinRequestRejected = checked
        }
    }

    ColumnLayout {
        visible: root.joinCommunity
        Label {
            Layout.fillWidth: true
            text: "Requires request:"
        }

        CheckBox {
            checked: root.requiresRequest
            onCheckedChanged: root.requiresRequest = checked
        }
    }

    ColumnLayout {
        visible: root.joinCommunity
        Label {
            Layout.fillWidth: true
            text: "Holdings model type:"
        }

        RadioButton {
            checked: true
            text: "Short model"
            onCheckedChanged: if(checked) root.communityHoldings = PermissionsModel.shortPermissionsModel
        }

        RadioButton {
            text: "Long model"
            onCheckedChanged: if(checked) root.communityHoldings = PermissionsModel.longPermissionsModel
        }
    }

    ColumnLayout {
        visible: !root.joinCommunity

        Label {
            Layout.fillWidth: true
            text: "Channel name"
        }

        TextField {
            background: Rectangle { border.color: 'lightgrey' }
            Layout.preferredWidth: 200
            text: root.channelName
            onTextChanged: root.channelName = text
        }
    }

    ColumnLayout {
        visible: !root.joinCommunity

        Label {
            Layout.fillWidth: true
            text: "Only view holdings model type:"
        }

        RadioButton {
            checked: true
            text: "Short model"
            onCheckedChanged: if(checked) root.viewOnlyHoldings = PermissionsModel.shortPermissionsModel
        }

        RadioButton {
            text: "Long model"
            onCheckedChanged: if(checked) root.viewOnlyHoldings = PermissionsModel.longPermissionsModel
        }

        RadioButton {
            text: "None"
            onCheckedChanged: if(checked) root.viewOnlyHoldings = undefined
        }
    }

    ColumnLayout {
        visible: !root.joinCommunity

        Label {
            Layout.fillWidth: true
            text: "View and post holdings model type:"
        }

        RadioButton {
            checked: true
            text: "Short model"
            onCheckedChanged: if(checked) root.viewAndPostHoldings = PermissionsModel.shortPermissionsModel
        }

        RadioButton {
            text: "Long model"
            onCheckedChanged: if(checked) root.viewAndPostHoldings = PermissionsModel.longPermissionsModel
        }

        RadioButton {
            text: "None"
            onCheckedChanged: if(checked) root.viewAndPostHoldings = undefined
        }
    }

    ColumnLayout {
        visible: !root.joinCommunity

        Label {
            Layout.fillWidth: true
            text: "Moderate holdings model type:"
        }

        RadioButton {
            checked: true
            text: "Short model"
            onCheckedChanged: if(checked) root.moderateHoldings = PermissionsModel.shortPermissionsModel
        }

        RadioButton {
            text: "Long model"
            onCheckedChanged: if(checked) root.moderateHoldings = PermissionsModel.longPermissionsModel
        }

        RadioButton {
            text: "None"
            onCheckedChanged: if(checked) root.moderateHoldings = undefined
        }
    }
}
