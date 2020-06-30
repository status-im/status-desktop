#!/bin/sh
cd ./ui/
QRC=./resources.qrc
echo '<!DOCTYPE RCC>' > $QRC
echo '<RCC version="1.0">' >> $QRC
echo '  <qresource>' >> $QRC
for a in $(find . -not -name "*.pro" -not -name "*.rcc" -not -name "*.sh" -not -name "*.qrc"    )
do
    if [ ! -d "$a" ]; then
        echo '      <file>'$a'</file>' >> $QRC
    fi
done
echo '  </qresource>' >> $QRC
echo '</RCC>' >> $QRC
cd ..