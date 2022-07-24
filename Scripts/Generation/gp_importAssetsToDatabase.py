import requests, json, hashlib, pyodbc


def main(): 
    startNum = 1
    endNum = 9999
    assets_by_name = {}
    conn = pyodbc.connect(r'DSN=gutterpunks')
    cursor = conn.cursor()
    inputFolder = "D:\\OutputMetadata_2"
    maxCategoryID = 1
    maxValueID = 1
    
    categoryIDs = {}
    valueIDs = {}
    
    for currentNum in range(startNum, endNum + 1, 1):
        print(str(currentNum))
        
        f = open(inputFolder + str(currentNum) + ".json", "r")
        asset = json.load(f)
        f.close()
    
        imageIPFS = asset["image"][7:]
        
        sqlcmd = "INSERT INTO asset (tokenID, imageIPFS) VALUES ("
        sqlcmd = sqlcmd + str(currentNum) + ", '" + imageIPFS + "');"
        print(sqlcmd)
        cursor.execute(sqlcmd)
        
        for trait in asset.get("attributes"): 
            trait_type = trait["trait_type"]
            trait_value = trait["value"]
            categoryID = 0
            valueID = 0 
            if trait_type in categoryIDs.keys(): 
                categoryID = categoryIDs[trait_type]
            #sqlcmd = "SELECT categoryID FROM trait_category WHERE categoryName = '" + trait_type + "';"
            #cursor.execute(sqlcmd)
            #for row in cursor.fetchall(): 
            #    categoryID = row[0]
            if categoryID == 0: 
                categoryID = maxCategoryID
                categoryIDs[trait_type] = categoryID
                maxCategoryID += 1
                sqlcmd = "INSERT INTO trait_category (categoryID, categoryName) VALUES (" + str(categoryID) + ", '" + trait_type.replace("'", "''") + "');"
                cursor.execute(sqlcmd)
                print(sqlcmd) 
            
            if categoryID in valueIDs.keys(): 
                if trait_value in valueIDs[categoryID].keys(): 
                    valueID = valueIDs[categoryID][trait_value]
            else: 
                valueIDs[categoryID] = {} 
                
            #sqlcmd = "SELECT valueID FROM trait_value WHERE categoryID = " + str(categoryID) + " AND value = '" + trait_value + "';"
            #cursor.execute(sqlcmd)
            #for row in cursor.fetchall(): 
            #    valueID = row[0]
            if valueID == 0: 
                valueID = maxValueID
                valueIDs[categoryID][trait_value] = valueID
                maxValueID += 1
                sqlcmd = "INSERT INTO trait_value (valueID, categoryID, value) VALUES (" + str(valueID) + ", " + str(categoryID) + ", '" + trait_value.replace("'", "''") + "');"
                cursor.execute(sqlcmd)
                print(sqlcmd) 
            
            sqlcmd = "INSERT INTO asset_trait (tokenID, categoryID, valueID) VALUES (" + str(currentNum) + ", " + str(categoryID) + ", " + str(valueID) + ");"
            cursor.execute(sqlcmd)
            print(sqlcmd) 
        
    cursor.commit()
    conn.close()
    
if __name__ == "__main__":
    main()
    
