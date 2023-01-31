test_dependencies = dependency('qt5', modules : ['Core', 'Gui', 'Widgets', 'Quick', 'Qml', 'Test'])
test_sources = ['test_dotherside.cpp', 'MockQAbstractItemModel.cpp', 'MockQObject.cpp']
test_resources = 'Resources.qrc'
test_include_directories = ['../lib/include', '../lib/include/Qt']
test_pch = ['../pch/test_pch.h', '../pch/test_pch.cpp']

qt5 = import('qt5')
test_moc_files = qt5.preprocess(moc_sources : test_sources, qresources : test_resources)

executable('TestDOtherSide',
  sources : [test_sources, test_moc_files],
  include_directories : include_directories(test_include_directories),
  link_with : lib,
  dependencies : test_dependencies,
  cpp_pch: test_pch
)