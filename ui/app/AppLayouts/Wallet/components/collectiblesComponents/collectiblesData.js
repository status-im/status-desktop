
var cryptokitty = "cryptokitty"
var kudo = "kudo"
var ethermon = "ethermon"
var stickers = "stickers"

var collectiblesData = {
    [cryptokitty] :{
        collectibleName: "CryptoKitties",
        collectibleIconSource: "CryptoKitties.png",
        buttonText: qsTr("View in Cryptokitties"),
        getLink: function (id) {
            return `https://www.cryptokitties.co/kitty/${id}`
        }
    },
    [ethermon] :{
        collectibleName: "Ethermons",
        collectibleIconSource: "ethermons.png",
        buttonText: qsTr("View in Ethermon"),
        getLink: function (id) {
            // TODO find a more direct URL
            return "https://ethermon.io/inventory"
        }
    },
    [kudo] :{
        collectibleName: "Kudos",
        collectibleIconSource: "kudos.png",
        buttonText: qsTr("View in Gitcoin"),
        getLink: function (id, externalUrl) {
            return externalUrl
        }
    },
    [stickers] :{
        collectibleName: qsTr("Purchased Stickers"),
        collectibleIconSource: "SNT.png",
        buttonText: "",
        getLink: function (id, externalUrl) {
            return ""
        }
    },
}
