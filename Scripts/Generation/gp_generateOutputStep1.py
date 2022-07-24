import json, hashlib, os, shutil, random, subprocess

def main(): 
    createdPunks = 1 #starting ID
    totalPunks = 9999 #finish ID
    inputFolderImages = 'D:\\InputImages' #source folder for images to include, image name must match metadata name + "_partial" on metadata
    inputFolderJSON = 'D:\\InputMetadata' #source folder for metadata, only include metadata attributes
    outputFolderImages = 'D:\\OutputImages_1' #output folder for serialized items for set, randomly sorted
    outputFolderJSON = 'D:\\OutputMetadata_1' #output folder for metadata
    inputPunks = [] 
    combinedHashString = ""
    
    for filename in os.listdir(inputFolderImages):
        inputPunks.append(filename) 
    
    
    while createdPunks <= totalPunks and len(inputPunks) > 0: 
        nextPunkIndex = random.randint(0,len(inputPunks)-1)
        nextPunkFile = inputPunks.pop(nextPunkIndex)
        nextPunkBase = nextPunkFile[:len(nextPunkFile)-4]
        print(nextPunkBase) 
        
        f = open(os.path.join(inputFolderImages,nextPunkBase+".png"),"rb")
        bytes = f.read() # read entire file as bytes
        readable_hash = hashlib.sha256(bytes).hexdigest()
        combinedHashString += readable_hash
        print(readable_hash)

        shutil.copy(os.path.join(inputFolderImages,nextPunkBase+".png"), os.path.join(outputFolderImages,str(createdPunks)+".png"))
        shutil.copy(os.path.join(inputFolderJSON,nextPunkBase+"_partial.txt"), os.path.join(outputFolderJSON,str(createdPunks)+"_partial.txt"))
        
        
        createdPunks += 1 
    
    provenanceHash = hashlib.sha256(combinedHashString.encode('utf-8')).hexdigest()
    print("Provenance Hash: " + provenanceHash) 
        
if __name__ == "__main__":
    main()
    
    
