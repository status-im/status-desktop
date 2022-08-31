import QtQuick 2.13

ListModel {
    id: root

    property var words: []

    Component.onCompleted: {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "english.txt");
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                root.words = xhr.responseText.split('\n');
                for (var i = 0; i < root.words.length; i++) {
                    if (root.words[i] !== "") {
                        insert(count, {"seedWord": root.words[i]});
                    }
                }
            }
        }
        xhr.send();
    }
}
