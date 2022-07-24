import requests, json, hashlib, pyodbc, os, shutil, random, subprocess
import typing as tp
from psd_tools import PSDImage
from PIL import Image

def main(): 


    inputFolderImages = 'D:\\OutputImages_1' #output from step 1
    inputFolderJSON = 'D:\\OutputMetadata_1'
    outputFolderJSON = 'D:\\OutputMetadata_2'
    
    for filename in os.listdir(inputFolderJSON):
        punkNumber = filename[:len(filename)-12]
        
        print(os.path.join(inputFolderImages,punkNumber+".png"))
        result = subprocess.getoutput('ipfs-only-hash --cid-version 0 ' + os.path.join(inputFolderImages,punkNumber+".png"))
        punkImgIPFShash = result
        strMetadataStart = '{"name":"#' + punkNumber + '","description":"Just a bunch of gutter punks rebelling against society and centralization. We’re a group of 9,999 randomly generated collectable NFTs minted and housed on the Ethereum blockchain.","image":"ipfs://'+punkImgIPFShash+'",'
        strMetadataEnd  = ',"compiler":"Gutter Punks Team"}'
        
        infilename = os.path.join(inputFolderJSON,filename)
        outfilename = os.path.join(outputFolderJSON,punkNumber+'.json')
        fin = open(infilename, "r")
        fout = open(outfilename, "w")
        strMetadataAttributes = fin.read() 
        fout.write(strMetadataStart + strMetadataAttributes + strMetadataEnd)
        fin.close()
        fout.close() 
    
    
        
if __name__ == "__main__":
    main()
    
    

