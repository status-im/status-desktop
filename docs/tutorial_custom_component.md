## Creating a Custom QML component

Creating a custom element typically involves
* creating a new QML file
* adding that QML file in a qmldir file
* adding that QML file to the project `nim-status-client.pro` file (automatic if done in QT Creator)

The easiest way is to do it in QT creator although this can be done manually as well, if not using QT Creator make sure the files are added in the nim-status-client.pro.pro file.

**step 1 - create folder**

In QT creator, go to `app/AppLayouts` right click, and select "New folder", name the folder `MySection`

**step 2 - create QML file**

In `MySection`, right click, and select "Add New", select "QT" -> "QML File (Qt Quick 2)", as a name put `MyQMLComponent.qml` and create the file.

Add the desired content, for example

```qml
import QtQuick 2.0

Item {
    Text {
        text: "hello"
    }
}
```

if not using QT Creator, make sure the files are added in the nim-status-client.pro.pro file, for e.g:

```
 DISTFILES += \
    app/AppLayouts/MySection/MyQMLComponent.qml \
```

**step 3 - add the component to qmldir**

In `app/AppLayouts/` edit `qmldir` and add the file

```
BrowserLayout 1.0 Browser/BrowserLayout.qml
ChatLayout 1.0 Chat/ChatLayout.qml
NodeLayout 1.0 Node/NodeLayout.qml
ProfileLayout 1.0 Profile/ProfileLayout.qml
WalletLayout 1.0 Wallet/WalletLayout.qml

MyQMLComponent 1.0 MySection/MyQMLComponent.qml
```

This ensures that when `app/AppLayouts/` is imported, the component `MyQMLComponent` will point to the component at `MySection/MyQMLComponent.qml`

**step 4 - use the component**

Note that `AppMain.qml` already imports AppLayouts

```qml
import "./AppLayouts"
```

which makes the `MyQMLComponent` available

In the section created in the `Adding a sidebar section`, replace it with this component

```qml
StackLayout {
    ...

    MyQMLComponent {
    }
}
```
