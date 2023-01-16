import QtQuick 2.0

import Models 1.0
import StatusQ.Core.Utils 0.1
import AppLayouts.Chat.controls.community 1.0

ListModel {
    id: root

    Component.onCompleted:
        append([
                   {
                       isPrivate: true,
                       holdingsListModel: root.createHoldingsModel1(),
                       permissionsObjectModel: {
                           key: 1,
                           text: "Become member",
                           imageSource: "in-contacts"
                       },
                       channelsListModel: root.createChannelsModel1()
                   },
                   {
                       isPrivate: false,
                       holdingsListModel: root.createHoldingsModel2(),
                       permissionsObjectModel: {
                           key: 2,
                           text: "View and post",
                           imageSource: "edit"
                       },
                       channelsListModel: root.createChannelsModel2()
                   }
               ])

    function createHoldingsModel1() {
        var holdings = []
        holdings.push({
                          operator: OperatorsUtils.Operators.None,
                          type: HoldingTypes.Type.Asset,
                          key: "SOCKS",
                          name: "SOCKS",
                          amount: 1.2,
                          imageSource: ModelsData.assets.socks
                      });
        holdings.push({
                          operator: OperatorsUtils.Operators.Or,
                          type: HoldingTypes.Type.Asset,
                          key: "ZRX",
                          name: "ZRX",
                          amount: 15,
                          imageSource: ModelsData.assets.zrx
                      });
        holdings.push({
                          operator: OperatorsUtils.Operators.And,
                          type: HoldingTypes.Type.Collectible,
                          key: "Furbeard",
                          name: "Furbeard",
                          amount: 12,
                          imageSource: ModelsData.collectibles.kitty1
                      });
        return holdings
    }

    function createHoldingsModel2() {
        var holdings = []
        holdings.push({
                          operator: OperatorsUtils.Operators.None,
                          type: HoldingTypes.Type.Collectible,
                          key: "Happy Meow",
                          name: "Happy Meow",
                          amount: 50.25,
                          imageSource: ModelsData.collectibles.kitty3
                      });
        holdings.push({
                          operator: OperatorsUtils.Operators.And,
                          type: HoldingTypes.Type.Collectible,
                          key: "AMP",
                          name: "AMP",
                          amount: 11,
                          imageSource: ModelsData.assets.amp
                      });
        return holdings
    }

    function createChannelsModel1() {
        var channels = []
        channels.push({
                          key: "help",
                          iconSource: ModelsData.assets.zrx,
                          name: "#help"
                      });
        channels.push({
                          key: "faq",
                          iconSource: ModelsData.assets.zrx,
                          name: "#faq"
                      });
        return channels
    }

    function createChannelsModel2() {
        var channels = []
        channels.push({
                          key: "welcome",
                          iconSource: ModelsData.assets.inch,
                          name: "#welcome"
                      });
        channels.push({
                          key: "general",
                          iconSource: ModelsData.assets.inch,
                          name: "#general"
                      });
        return channels
    }
}
