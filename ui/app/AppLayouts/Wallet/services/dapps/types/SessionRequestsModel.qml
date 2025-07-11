import QtQuick

/// Data model that holds a queue of SessionRequestResolved events as they are received from the SDK
ListModel {
    id: root

    signal requestAdded(var request)

    function enqueue(request) {
        root.append({requestId: request.requestId, requestItem: request});
        requestAdded(request);
    }

    function dequeue() {
        if (root.count > 0) {
            var item = root.get(0);
            root.remove(0);
            return item.requestItem;
        }
        return null;
    }

    function removeRequest(topic, id) {
        for (var i = 0; i < root.count; i++) {
            let entry = root.get(i).requestItem
            if (entry.topic == topic && entry.requestId == id) {
                root.remove(i, 1);
                return;
            }
        }
    }

    /// returns null if not found
    function findRequest(topic, id) {
        for (var i = 0; i < root.count; i++) {
            let entry = root.get(i).requestItem
            if (entry.topic == topic && entry.requestId == id) {
                return entry;
            }
        }
        return null;
    }

    // returns null if not found
    function findById(id) {
        for (var i = 0; i < root.count; i++) {
            let entry = root.get(i).requestItem
            if (entry.requestId == id) {
                return entry;
            }
        }
        return null;
    }
}
