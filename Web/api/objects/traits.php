<?php
class Traits{
  
    // database connection and table name
    private $conn;
    private $table_name = "traits";
  
    // object properties
	public $categoryID;
    public $categoryName;
    public $valueID;
    public $value;
	public $occurrences;
	public $revealed;
  
    // constructor with $db as database connection
    public function __construct($db){
        $this->conn = $db;
    }
	
	// subcollection traits
function getTraits(){
  
    // select all query
    $query = "select trait_category.categoryID, trait_category.categoryName, IF(trait_value.revealed, trait_value.valueID, 0) as valueID, IF(trait_value.revealed, trait_value.value, 'Not Revealed') as value, trait_value.occurrences, trait_value.revealed
from 
trait_category inner join trait_value on trait_category.categoryID = trait_value.categoryID
order by trait_category.categoryName, trait_value.occurrences asc";
  
    // prepare query statement
    $stmt = $this->conn->prepare($query);
  
    // execute query
    $stmt->execute();
  
    return $stmt;
}
	
	// subcollection traits
function getAssetTraits($tokenID=0){
  
    // select all query
    $query = "select trait_category.categoryID, trait_category.categoryName, IF(trait_value.revealed, trait_value.valueID, 0) as valueID, IF(trait_value.revealed, trait_value.value, 'Not Revealed') as value, 
	trait_value.occurrences, trait_value.revealed, trait_value.rarityScore
from 
trait_category inner join trait_value on trait_category.categoryID = trait_value.categoryID
where trait_value.valueID in (select valueID from asset_trait where tokenID = " . $tokenID . " and revealed = 1)
order by trait_value.rarityScore desc";
  
    // prepare query statement
    $stmt = $this->conn->prepare($query);
  
    // execute query
    $stmt->execute();
  
    return $stmt;
}
}
?>