#include <stdlib.h>
#include <unistd.h>
#include <QDir>

extern "C" {
    void NimMain();
}

int main(int argc, char* argv[])
{
    Q_INIT_RESOURCE(resources);
    qputenv("QT_FILE_SELECTORS", "noWebEngine");
    NimMain();
    return 0;
}
