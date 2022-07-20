import os
import os.path as path
import shutil
import distutils.dir_util


def erase_directory(dir: str):
    directory = path.abspath(path.join(__file__, dir))
    if (os.path.isdir(directory)):
        print(directory)
        try:
            shutil.rmtree(directory)
        except OSError:
            os.remove(directory)
            
def clear_directory(dir: str):
    for files in os.listdir(dir):
        path = os.path.join(dir, files)
        try:
            shutil.rmtree(path)
        except OSError:
            os.remove(path)
            
def copy_directory(src: str, dst: str):
    if os.path.isdir(src) and os.path.isdir(dst):
        try:
            distutils.dir_util.copy_tree(src, dst)
        except OSError:
            os.remove(dst)
