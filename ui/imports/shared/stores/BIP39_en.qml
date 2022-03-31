import QtQuick 2.13

ListModel {
    Component.onCompleted: {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "english.txt");
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                var words = xhr.responseText.split('\n');
                for (var i = 0; i < words.length; i++) {
                    if (words[i] !== "") {
                        insert(count, {"seedWord": words[i]});
                    }
                }
            }
        }
        xhr.send();
    }
}
