import QtQuick 2.14
import QtQml.Models 2.14
import QtQuick.Controls 2.14

import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0

Item {
    id: root

    property var sharedKeycardModule
    property bool filterProfilePair: false
    property var keyPairModel
    property ButtonGroup buttonGroup

    DelegateModel {
        id: delegateModel

        function update() {
            var visible = [];
            for (var i = 0; i < items.count; ++i) {
                var item = items.get(i);
                if(root.filterProfilePair) {
                    if (item.model.pairType === Constants.keycard.keyPairType.profile)
                        visible.push(item);
                }
                else if (item.model.pairType !== Constants.keycard.keyPairType.profile) {
                    visible.push(item);
                }
            }

            for (i = 0; i < visible.length; ++i) {
                item = visible[i];
                item.inPairType = true;
                if (item.pairTypeIndex !== i) {
                    visibleItems.move(item.pairTypeIndex, i, 1);
                }
            }
        }

        model: root.keyPairModel

        groups: [DelegateModelGroup {
                id: visibleItems
                name: "pairType"
                includeByDefault: false
            }]

        filterOnGroup: "pairType"
        items.onChanged: update()
        delegate: KeyPairItem {
            width: parent.width

            sharedKeycardModule: root.sharedKeycardModule
            buttonGroup: root.buttonGroup
            usedAsSelectOption: true

            keyPairPubKey: model.pubKey
            keyPairName: model.name
            keyPairIcon: model.icon
            keyPairImage: model.image
            keyPairDerivedFrom: model.derivedFrom
            keyPairAccounts: model.accounts
        }
    }

    ListView {
        anchors.fill: parent
        spacing: Style.current.padding
        clip: true
        model: delegateModel
    }
}
