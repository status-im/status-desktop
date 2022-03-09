TEMPLATE = subdirs

CONFIG += ordered

app_dir.subdir = src-cpp/app
app_service.subdir = src-cpp/app_service
backend_dir.subdir = src-cpp/backend
dotherside_dir.subdir = src-cpp/dotherside
status_desktop.subdir = src-cpp
status_go_build.subdir = src-cpp/statusgo-build

SUBDIRS = \
    status_go_build \
    dotherside_dir \
    backend_dir \
    app_service \
    app_dir \
    status_desktop 
