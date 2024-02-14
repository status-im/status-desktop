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
                    let word = root.words[i]
                    word = word.replace(/\r?\n|\r/, "")
                    if (word !== "") {
                        insert(count, {"seedWord": word});
                    }
                }
            }
        }
        xhr.send();
    }
}
