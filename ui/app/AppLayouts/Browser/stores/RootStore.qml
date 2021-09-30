pragma Singleton

import QtQuick 2.13

QtObject {
    id: root

    property string activeChannelName: chatsModel.channelView.activeChannel.name

    property var currentNetwork: profileModel.network.current

    function getUrlFromUserInput(input) {
        return utilsModel.urlFromUserInput(input)
    }

    function getAscii2Hex(input) {
        return utilsModel.ascii2Hex(input)
    }

    function getHex2Ascii(input) {
        return utilsModel.hex2Ascii(input)
    }

    function getWei2Eth(wei,decimals) {
        return utilsModel.wei2Eth(wei,decimals)
    }

    function generateIdenticon(pk) {
        return utilsModel.generateIdenticon(pk)
    }
}
