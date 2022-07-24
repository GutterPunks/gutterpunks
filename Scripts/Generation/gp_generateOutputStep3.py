import requests, json, hashlib, pyodbc, os, shutil, random, subprocess
import typing as tp
from psd_tools import PSDImage
from PIL import Image

def main(): 


    inputFolderJSON = 'D:\\OutputMetadata_2' #output metadata from step 2
    outfilename = 'D:\\punkMDhashes.csv' #output tokenId and pin hash to csv file 
    fout = open(outfilename, "w")
    fout.write("tokenId,hash\n")
    
    for filename in os.listdir(inputFolderJSON):
        punkNumber = filename[:len(filename)-5]
        
        result = subprocess.getoutput('ipfs-only-hash --cid-version 0 ' + os.path.join(inputFolderJSON,punkNumber+".json"))
        punkMDIPFShash = result
        
        print(str(punkNumber) + "," + punkMDIPFShash)
        
        fout.write(str(punkNumber) + "," + punkMDIPFShash+"\n")
        
    fout.close() 
    
    
        
if __name__ == "__main__":
    main()