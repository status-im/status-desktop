
var cryptokitty = "cryptokitty"
var kudo = "kudo"
var ethermon = "ethermon"
var stickers = "stickers"

var collectiblesData = {
    [cryptokitty] :{
        collectibleName: "CryptoKitties",
        collectibleIconSource: "CryptoKitties",
        buttonText: qsTr("View in Cryptokitties"),
        getLink: function (id) {
            return `https://www.cryptokitties.co/kitty/${id}`
        }
    },
    [ethermon] :{
        collectibleName: "Ethermons",
        collectibleIconSource: "ethermons",
        buttonText: qsTr("View in Ethermon"),
        getLink: function (id) {
            // TODO find a more direct URL
            return "https://ethermon.io/inventory"
        }
    },
    [kudo] :{
        collectibleName: "Kudos",
        collectibleIconSource: "kudos",
        buttonText: qsTr("View in Gitcoin"),
        getLink: function (id, externalUrl) {
            return externalUrl
        }
    },
    [stickers] :{
        collectibleName: qsTr("Purchased Stickers"),
        collectibleIconSource: "SNT",
        buttonText: "",
        getLink: function (id, externalUrl) {
            return ""
        }
    },
}
