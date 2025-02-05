#include <stdlib.h>
#include <unistd.h>

extern "C" {
    void NimMain();
    void mainProc();
}

int main(int argc, char* argv[])
{
    NimMain();
    mainProc();
    return 0;
}
