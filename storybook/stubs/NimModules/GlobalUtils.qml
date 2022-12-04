import QtQuick 2.14

QtObject {
    property var plainText: function (htmlText) {
        return htmlText.replace(/(?:<style[^]+?>[^]+?<\/style>|[\n]|<script[^]+?>[^]+?<\/script>|<(?:!|\/?[a-zA-Z]+).*?\/?>)/g,'')
    }

    property var isCompressedPubKey: function (publicKey) {
        return true
    }

    property var getCompressedPk: function (publicKey) {
        return "123456789"
    }

    property var getColorHashAsJson: function (publicKey) {
        return JSON.stringify([{colorId: 0, segmentLength: 1},
                               {colorId: 19, segmentLength: 2}])
    }

    property var getColorId: function (publicKey) {
        return Math.floor(Math.random() * 10)
    }

    property var isEnsVerified: function (publicKey)  {
        return false
    }


    property var getEmojiHashAsJson: function(publicKey) {
        return JSON.stringify(["👨🏻‍🍼", "🏃🏿‍♂️", "🌇", "🤶🏿", "🏮","🤷🏻‍♂️", "🤦🏻", "📣", "🤎", "👷🏽", "😺", "🥞", "🔃", "🧝🏽‍♂️"])
    }
}
