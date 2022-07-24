<?php
// required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
  
// database connection will be here
include_once '../config/database.php';
include_once '../objects/traits.php';
  
// instantiate database and subcollection object
$database = new Database();
$db = $database->getConnection();
  
// initialize object
$trait = new Traits($db);
  
$stmt = $trait->getTraits();
$num = $stmt->rowCount();
  
// check if more than 0 record found
if($num>0){
  
    // traits array
    $traits_arr=array();
    $traits_arr["traits"]=array();
  
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)){
        // extract row
        // this will make $row['name'] to
        // just $name only
        extract($row);
  
        $trait_item=array(
            "categoryID" => $categoryID,
            "categoryName" => $categoryName,
            "valueID" => $valueID,
			"value" => $value, 
            "occurrences" => $occurrences, 
            "revealed" => $revealed
        );
  
        array_push($traits_arr["traits"], $trait_item);
    }
  
    // set response code - 200 OK
    http_response_code(200);
  
    // show traits data in json format
    echo json_encode($traits_arr);
}
  
// no subcollection found will be here
else{
  
    // set response code - 404 Not found
    http_response_code(404);
  
    // tell the user no traits found
    echo json_encode(
        array("message" => "No traits found.")
    );
}
?>