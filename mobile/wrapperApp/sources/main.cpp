#include <stdlib.h>
#include <unistd.h>

#if QT_VERSION >= 0x060000
#include <QtResource>
#else
#include <QDir>
#endif

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
