import QtQml 2.14

QtObject {
    enum Type {
        Unknown, Asset, Collectible, Ens
    }

    enum Mode {
        Add, Update, UpdateOrRemove
    }
}
