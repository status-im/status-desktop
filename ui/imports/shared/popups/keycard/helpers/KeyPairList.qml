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

    SortFilterProxyModel {
        id: proxyModel
        sourceModel: root.keyPairModel
        filters: ValueFilter {
            roleName: "pairType"
            value: Constants.keycard.keyPairType.profile
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

            keyPairType: model.pairType
            keyPairPubKey: model.pubKey
            keyPairName: model.name
            keyPairIcon: model.icon
            keyPairImage: model.image
            keyPairDerivedFrom: model.derivedFrom
            keyPairAccounts: model.accounts

            onKeyPairSelected: {
                root.keyPairSelected()
            }
        }
    }
}
