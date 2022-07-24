import requests, json, hashlib, pyodbc, os, shutil, random, subprocess, PIL
import typing as tp
from psd_tools import PSDImage
from PIL import Image

def main(): 


    inputFolderImages = 'D:\\OutputImages'
    outputFolderImages = 'D:\\OutputThumbnails'
    
        
    f3 = open("gp_thumbnails.csv", "w")
    f3.write("gp,tnhash\n")
    
    for filename in os.listdir(inputFolderImages):
        punknumber = filename[:len(filename)-4]
        
        im = Image.open(os.path.join(inputFolderImages,filename))
        im = im.resize((200, 200), PIL.Image.ANTIALIAS)
        im.save(os.path.join(outputFolderImages,filename))
        
        result = subprocess.getoutput('ipfs add --cid-version 0 ' + os.path.join(outputFolderImages,filename))
        result = subprocess.getoutput('ipfs-only-hash --cid-version 0 ' + os.path.join(outputFolderImages,filename))
        punkThumbnailIPFShash = result
        print(str(punknumber) + "," + punkThumbnailIPFShash)
        f3.write(str(punknumber) + "," + punkThumbnailIPFShash+"\n")
        
        
    f3.close()
    
        
if __name__ == "__main__":
    main()
    
    
