import QtQuick 2.14
import QtQuick.Controls 2.14

import utils 1.0

import SortFilterProxyModel 0.2

Item {
    id: root

    property var sharedKeycardModule
    property bool filterProfilePair: false
    property var keyPairModel
    property ButtonGroup buttonGroup

    signal keyPairSelected()

    QtObject {
        id: d
        readonly property string profilePairTypeValue: Constants.keycard.keyPairType.profile
    }

    SortFilterProxyModel {
        id: proxyModel
        sourceModel: root.keyPairModel
        filters: ExpressionFilter {
            expression: model.keyPair.pairType == d.profilePairTypeValue
            inverted: !root.filterProfilePair
        }
    }

    ListView {
        anchors.fill: parent
        spacing: Style.current.padding
        clip: true
        model: proxyModel
        delegate: KeyPairItem {
            width: ListView.view.width

            sharedKeycardModule: root.sharedKeycardModule
            buttonGroup: root.buttonGroup
            usedAsSelectOption: true
            canBeSelected: !model.keyPair.containsPathOutOfTheDefaultStatusDerivationTree()

            keyPairType: model.keyPair.pairType
            keyPairKeyUid: model.keyPair.keyUid
            keyPairName: model.keyPair.name
            keyPairIcon: model.keyPair.icon
            keyPairImage: model.keyPair.image
            keyPairDerivedFrom: model.keyPair.derivedFrom
            keyPairAccounts: model.keyPair.accounts

            onKeyPairSelected: {
                root.keyPairSelected()
            }
        }
    }
}
