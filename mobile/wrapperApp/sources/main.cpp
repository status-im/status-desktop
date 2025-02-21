#include <stdlib.h>
#include <unistd.h>
#include <QDir>

extern "C" {
    void NimMain();
}

int main(int argc, char* argv[])
{
    Q_INIT_RESOURCE(resources);
    NimMain();
    return 0;
}
