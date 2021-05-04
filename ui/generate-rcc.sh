#!/bin/sh
cd ./ui/
QRC=./resources.qrc
echo '<!DOCTYPE RCC>' > $QRC
echo '<RCC version="1.0">' >> $QRC
echo '  <qresource>' >> $QRC
for a in $(find -L . -not -name "*.pro" -not -name "*.rcc" -not -name "*.sh" -not -name "*.qrc" -not -name ".git" -not -name ".gitignore"   )
do
    if [ ! -d "$a" ]; then
        echo '      <file>'$a'</file>' >> $QRC
    fi
done
echo '  </qresource>' >> $QRC
echo '</RCC>' >> $QRC
cd ..