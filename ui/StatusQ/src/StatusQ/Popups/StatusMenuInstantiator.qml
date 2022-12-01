import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQml.Models 2.14

Instantiator {
    id: root

    property Menu menu

    onObjectAdded: {
        if (object instanceof Menu)
            menu.addMenu(object)
        else if (object instanceof Action)
            menu.addAction(object)
        else
            menu.addItem(object)
    }

    onObjectRemoved: {
        if (object instanceof Menu)
            menu.removeMenu(object)
        else if (object instanceof Action)
            menu.removeAction(object)
        else
            menu.removeItem(object)
    }
}
