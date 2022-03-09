TEMPLATE = aux

ios {
    message("statusgo build for ipados")
    system(./build_ipad.sh)
}

android {
    message("statusgo build for android")
    system(./build_android.sh)
}
