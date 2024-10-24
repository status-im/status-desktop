import QtQml 2.15

import utils 1.0

QtObject {
    id: root

    readonly property QtObject _d: QtObject {
        id: d

        property var globalUtilsInst: globalUtils
    }

    function isChatKey(value) {
        return (Utils.startsWith0x(value) && Utils.isHex(value) && value.length === 132)
                || d.globalUtilsInst.isCompressedPubKey(value)
    }

    function isCommunityPublicKey(value) {
        return (Utils.startsWith0x(value) && Utils.isHex(value) && value.length === Constants.communityIdLength)
                || d.globalUtilsInst.isCompressedPubKey(value)
    }

    function isCompressedPubKey(pubKey) {
        return d.globalUtilsInst.isCompressedPubKey(pubKey)
    }

    function isAlias(name) {
        return d.globalUtilsInst.isAlias(name)
    }


    function getEmojiHash(publicKey) {
        if (publicKey === "" || !isChatKey(publicKey))
            return []

        return JSON.parse(d.globalUtilsInst.getEmojiHashAsJson(publicKey))
    }
}
