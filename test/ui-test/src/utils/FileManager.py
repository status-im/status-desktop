import os, shutil
import os.path as path
  
      
def erase_directory(dir: str):
    directory = path.abspath(path.join(__file__ , dir)) 
    if (os.path.isdir(directory)):
        print(directory)
        try:
            shutil.rmtree(directory)
        except OSError:
            os.remove(directory)
            
