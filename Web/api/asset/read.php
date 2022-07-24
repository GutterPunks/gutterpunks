<?php
// required headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
  
// database connection will be here
include_once '../config/database.php';
include_once '../objects/asset.php';
include_once '../objects/traits.php';
  
// instantiate database and subcollection object
$database = new Database();
$db = $database->getConnection();
  
// initialize object
$asset = new Asset($db);
  
// initialize object
$traits = new Traits($db);


$latestPunk = file_get_contents("../metadata/latestpunk");
$asset->updateLatestPunk($latestPunk);
  
// read subcollections will be here
// query assets
$limit = 25;
$page = 1;
$tokenID = -1;
$sort = 1;
$priceMin = 0;
$priceMax = 0;
$listed = 0;
$staked = 0;
$ownerAddr = '';
$traitvalues = array();
$includeAttributes = false;
if(isset($_GET['filterCategoryIDs'])) {
	for($i = 0;$i < count($_GET['filterCategoryIDs']);++$i) {
		array_push($traitvalues, array($_GET['filterCategoryIDs'][$i]));
		if(isset($_GET[$_GET['filterCategoryIDs'][$i]])) {
			array_push($traitvalues[$i], $_GET[$_GET['filterCategoryIDs'][$i]]);
		}
	}
}
if(isset($_GET['limit'])) {
    if(is_numeric($_GET['limit'])) {
        $limit = $_GET['limit'];
    }
}
if(isset($_GET['page'])) {
    if(is_numeric($_GET['page'])) {
        $page = $_GET['page'];
    }
}
if(isset($_GET['tokenID'])) {
    if(is_numeric($_GET['tokenID'])) {
        $tokenID = $_GET['tokenID'];
    }
}
if(isset($_GET['sort'])) {
    if(is_numeric($_GET['sort'])) {
        $sort = $_GET['sort'];
    }
}
if(isset($_GET['priceMin'])) {
    if(is_numeric($_GET['priceMin'])) {
        $priceMin = $_GET['priceMin'];
    }
}
if(isset($_GET['priceMax'])) {
    if(is_numeric($_GET['priceMax'])) {
        $priceMax = $_GET['priceMax'];
    }
}
if(isset($_GET['listed'])) {
    if(is_numeric($_GET['listed'])) {
        $listed = $_GET['listed'];
    }
}
if(isset($_GET['staked'])) {
    if(is_numeric($_GET['staked'])) {
        $staked = $_GET['staked'];
    }
}
if(isset($_GET['owner'])) {
    $ownerAddr = $_GET['owner'];
}

if($tokenID > -1) {
	$includeAttributes = true;
}

if(isset($_GET['count'])) {
	if($_GET['count'] == "y") {
		$stmt = $asset->getFilteredAssetCount($traitvalues,$tokenID,$sort,$priceMin,$priceMax,$listed,$staked,$ownerAddr);
		$num = $stmt->rowCount();
		if($num>0) {
			$asset_arr=array();
			$row = $stmt->fetch(PDO::FETCH_ASSOC);
			$asset_arr["asset_count"] = $row["assetCount"];
			$asset_arr["minted_count"] = $row["minted"];
			$asset_arr["unminted_count"] = $row["assetCount"] - $row["minted"];
			http_response_code(200);
			echo json_encode($asset_arr);
		} else {
		  
			// set response code - 404 Not found
			http_response_code(404);
		  
			// tell the user no assets found
			echo json_encode(
				array("message" => "No assets found.")
			);
		}
	}
} else {
	$stmt = $asset->getWithTraitFilter($traitvalues,$page,$limit,$tokenID,$sort,$priceMin,$priceMax,$listed,$staked,$ownerAddr);
	$num = $stmt->rowCount();
	  
	// check if more than 0 record found
	if($num>0){
	  
		// assets array
		$asset_arr=array();
		$asset_arr["assets"]=array();
	  
		while ($row = $stmt->fetch(PDO::FETCH_ASSOC)){
			// extract row
			// this will make $row['name'] to
			// just $name only
			extract($row);
	  
			$asset_item=array(
				"tokenID" => $tokenID,
				"imageIPFS" => $imageIPFS,
				"thumbnailIPFS" => $thumbnailIPFS,
				"rarityScore" => $rarityScore,
				"rank" => $rank,
				"revealed" => $revealed,
				"traitCount" => $traitCount,
				"traitCountRarity" => $traitCountRarity,
				"currentOwner" => $currentOwner,
				"listed" => $listed,
				"listedPrice" => $listedPrice,
				"staked" => $staked
			);
			
			if($includeAttributes) {
				$attr_arr=array();
				$attrSTMT = $traits->getAssetTraits($tokenID);
				$attrNUM = $attrSTMT->rowCount();
				if($num>0) {
					while($attrROW = $attrSTMT->fetch(PDO::FETCH_ASSOC)) {
						extract($attrROW);
						$attrITEM = array(
							"categoryID" => $categoryID,
							"categoryName" => $categoryName,
							"valueID" => $valueID,
							"value" => $value,
							"occurrences" => $occurrences,
							"revealed" => $revealed, 
							"rarityScore" => $rarityScore
						);
						array_push($attr_arr, $attrITEM);
					}
				}
				$asset_item["attributes"] = $attr_arr;
			}
		
			array_push($asset_arr["assets"], $asset_item);
		}
	  
		// set response code - 200 OK
		http_response_code(200);
	  
		// show assets data in json format
		echo json_encode($asset_arr);
	}
	  
	// no subcollection found will be here
	else{
	  
		// set response code - 404 Not found
		http_response_code(404);
	  
		// tell the user no assets found
		echo json_encode(
			array("message" => "No assets found.")
		);
	}
}
?>