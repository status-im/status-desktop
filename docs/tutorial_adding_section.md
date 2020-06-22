## Adding a sidebar section

The sidebar and each section is defined at `AppMain.qml`, it contains

* sidebar - `TabBar` with `TabButton` elements
* main section - `StackLayout`

The currently displayed section in the `StackLayout` is determined by the `currentIndex` property, for example `0` will show the first child (in this case `ChatLayout`), `1` will show the second child, and so on

This property is being defined by whatever is the currently selected button in the `Tabbar` with `currentIndex: tabBar.currentIndex`

```qml
TabBar {
    id: tabBar
    
    TabButton { ... }
    TabButton { ... }
    ...
}

StackLayout {
    ...
    currentIndex: tabBar.currentIndex

    ChatLayout {}
    WalletLayout {}
    ...
}
```

To add a new section, then add a new TabButton to the TabBar, for example:

```qml
TabBar {
    ...
    TabButton {
        id: myButton
        visible: this.enabled
        width: 40
        height: this.enabled ? 40 : 0
        text: ""
        anchors.topMargin: this.enabled ? 50 : 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: nodeBtn.top // needs to be previous button
        background: Rectangle {
            color: Theme.lightBlue
            opacity: parent.checked ? 1 : 0
            radius: 50
        }

        Image {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
            source: parent.checked ? "img/node.svg" : "img/node.svg"
        }
    }
}
```

Then a section to the StackLayout

```qml
StackLayout {
    ...

    Text {
        text: "hello world!"
    }
}
```

The section can be any qml element, to create your own custom element, see the next section
