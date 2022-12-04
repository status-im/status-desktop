import QtQuick 2.14

QtObject {
    property ListModel gifColumnA: ListModel{}
    property ListModel gifColumnB: ListModel{}
    property ListModel gifColumnC: ListModel{}
    property var searchGifs: function(query) {
        console.log("searchGifs")
    }

    property var getTrendingsGifs: function() {
        console.log("getTrendingsGifs")
    }

    property var getRecentsGifs: function() {
        console.log("getRecentsGifs")
    }

    property var getFavoritesGifs: function() {
        console.log("getRecentsGifs")
    }

    property var isFavorite: function(id) {
        console.log("getRecentsGifs")
    }

    property var toggleFavoriteGif: function(id, reload) {
        console.log("getRecentsGifs")
    }

    property var addToRecentsGif: function(id) {
        console.log("getRecentsGifs")
    }
}
