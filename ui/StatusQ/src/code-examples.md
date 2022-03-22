# Code examples

## Parent assumptions

### Don't assume parent's context bad example

`PreanchoredItem.qml` component

```qml
Item {
  // This limits the usage of the component and can lead to maintenance burden
  anchors.fill: parent

  //...
}
```

Broken usage of `PreanchoredItem` component

```qml
Item {
  id: root

  // Using PreanchoredItem with a container (layouts, delegate in a ListView ..) will result in warning or broken UI layout.
  ColumnLayout {
    // This will generate a qml warning and Layout won't work as expected
    PreanchoredItem {
      Layout.fillWidth: true
      Layout.fillHeight: true
    }

    // ....
  }
}
```

### Give user choice

User should be allowed to choose how to size the control based on it's design and UX requirements. Only provide hints and recommendations.

`GoodItem.qml` component

```qml
Item {
  // Rather provide implicit sizes if appropriate and leave user to layout or anchors as
  // he see fit given its panel/view design
  implicitWidth: 200
  implicitHeight: 100

  //...
}
```

Usage of `GoodItem` component

```qml
// Using GoodItem with a container (layouts, positioners, delegate in a ListView ..) works well
ColumnLayout {
  // This will generate a qml warning and Layout won't work as expected
  GoodItem {
    Layout.fillWidth: true
    Layout.fillHeight: true
  }

  GoodItem {
    Layout.preferredWidth: true
    Layout.preferredHeight: true
  }

  GoodItem {
    // Nothing will still show the "optimal" size provided by the control
  }

  // ....
}
```
