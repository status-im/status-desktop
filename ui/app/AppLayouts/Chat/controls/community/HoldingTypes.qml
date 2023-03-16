import QtQml 2.14

QtObject {
    enum Type {
        Asset, Collectible, Ens
    }

    enum Mode {
        Add, Update, UpdateOrRemove
    }
}
