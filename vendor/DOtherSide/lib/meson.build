lib_version = '0.6.3'
lib_dependencies = dependency('qt5', modules : ['Core', 'Gui', 'Widgets', 'Quick', 'Qml', 'WebView'])
lib_sources = [
  'src/DOtherSide.cpp',
  'src/DOtherSideTypesCpp.cpp',
  'src/DosQAbstractItemModel.cpp',
  'src/DosQDeclarative.cpp',
  'src/DosQMetaObject.cpp',
  'src/DosQObject.cpp',
  'src/DosQObjectImpl.cpp',
  'src/DosQQuickImageProvider.cpp',
]
lib_include_directories = ['include', 'include/Qt']
lib_pch = ['../pch/lib_pch.h', '../pch/lib_pch.cpp']

lib = shared_library('DOtherSide',
  sources : lib_sources,
  include_directories : include_directories(lib_include_directories),
  dependencies : lib_dependencies,
  version: lib_version,
  soversion:0,
  cpp_pch: lib_pch
)
