### QML Crash course

**Intro**

Every QML file imports at least QtQuick and then other imports that might be required for the QML Types being used. QML Types have properties (similar to CSS somewhat), and typically contain other QML Types as children.

```qml
import QtQuick 2.0
import <SomeImportNeededForTypeName>

TypeName {
   propertyName: value
   
   AnotherType {
       propertyName: value
       anotherProperty: value2
   }
}
```

example:

```qml
import QtQuick 2.0

Rectangle {
    id: page
    width: 320; height: 480
    color: "lightgray"

    Text {
        id: helloText
        text: "Hello world!"
        y: 30
        anchors.horizontalCenter: page.horizontalCenter
        font.pointSize: 24; font.bold: true
    }
}
```

**QML Properties - using ids**

QML Types can be identified by an `id` which can be used as variable to access other properties from that element as parameter to other elements.

In this example, the `Text` element is identified with the id `tabBtnText`, we can use this to access the width of the text and used as value for the width of the Rectangle so its width is always the same as the text:

```qml
Rectangle {
    id: tabButton
    width: tabBtnText.width // will always reflect the width of tabBtnText
    height: tabBtnText.height + 11

    Text {
        id: tabBtnText
        text: "hello there"
    }
}
```

Another example, combining a `TabBar` and a `StackLayout`, the StackLayout will display a different view depending on which TabButton has been selected since its index is taking the value of the tabbar

```qml
TabBar {
    id: tabBar
    currentIndex: 0
    
    TabButton { ... } // will change currentIndex to 0 if selected
    TabButton { ... } // will change currentIndex to 1 if selected
    ...
}

StackLayout {
    ...
    currentIndex: tabBar.currentIndex // use the newest value of the TabBar

    Item {} // will be displayed if currentIndex == 0
    item {} // will be displayed if currentIndex == 1
    ...
}
```

**QML Properties - parent and children**

It's possible to also refer to a `parent` of an element. This is typically used for widths & anchors but can be used to access any property from the parent, for example:

```qml
ColumnLayout {
    id: suggestionsContainer
    Layout.fillHeight: true
    Layout.fillWidth: true

    Row {
        id: description
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
        width: parent.width
    }
}
```

Or even a particular child using `children`, for example, here the rectangle remains at the width of the child text with an additional room of 10 pixels:

```qml
Rectangle {
    width: children[0].width + 10

    Text {
        text: "#" + channel
    }
}
```

**QML Types**
A complete list of QML Types can be found in the QT documentation [here](https://doc.qt.io/qt-5/qmltypes.html) 

some commonly used types in nim-status-client include:
* [Text](https://doc.qt.io/qt-5/qml-qtquick-text.html)
* [Image](https://doc.qt.io/qt-5/qml-qtquick-image.html)
* SplitView
* TabBar & TabButton
* StackLayout
* ColumnLayout & RowLayout
* ListView

**SplitView Example**

The SplitView list items with a draggable splitter between each item

```qml
import QtQuick 2.0
import QtQuick.Controls 2.13 // required for SplitView

SplitView {
    id: walletView

    // splitter settings
    handleDelegate: Rectangle {
        implicitWidth: 1
        implicitHeight: 4
        color: Theme.grey
    }

    Text {
        text: "item on the left"
    }
    
    Text {
        text: "item on the right"
    }
}
```

**TabBar & TabButton Example**

```qml
TabBar {
    id: tabBar
    currentIndex: 0

    TabButton { text: "foo" } // will change currentIndex to 0 if selected
    TabButton { text: "bar" } // will change currentIndex to 1 if selected
    ...
}
```

`tabBar.currentIndex` can then be used as value for some other property (typically used to supply the index for `StackLayout`)
