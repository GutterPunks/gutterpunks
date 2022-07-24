<?php
class Asset{
  
    // database connection and table name
    private $conn;
    private $table_name = "asset";
  
    // object properties
    public $tokenID;
    public $imageIPFS;
    public $thumbnailIPFS;
    public $rarityScore;
	public $rank;
	public $revealed;
	public $traitCount;
	public $traitCountRarity;
	public $currentOwner;
	public $listed;
	public $listedPrice;
	public $staked;
  
    // constructor with $db as database connection
    public function __construct($db){
        $this->conn = $db;
    }
	
	// read assets
function getWithTraitFilter($traitfilters = array(), $page = 1, $limit = 25,$tokenID = -1,$sort = 1,$priceMin = 0,$priceMax = 0, $listed = 0, $staked = 0, $ownerAddr = ''){
	$priceMin = $priceMin * 10**9;
	$priceMax = $priceMax * 10**9; //convert to GWEI 
	
    // select all query
    $query = "SELECT
	IF(revealed, tokenID, 0) as tokenID,
    IF(revealed, imageIPFS, 'QmYY8TcPbmMDUu4LEsm5fzDPBjZ4e4NWcGYBxpijxMx5hQ') as imageIPFS,
	IF(revealed, thumbnailIPFS, 'QmYY8TcPbmMDUu4LEsm5fzDPBjZ4e4NWcGYBxpijxMx5hQ') as thumbnailIPFS,
    rarityScore,
    rank,
    revealed,
    IF(revealed, traitCount, 0) as traitCount,
    IF(revealed, traitCountRarity, 0) as traitCountRarity,
	currentOwner, 
	listed,
	listedPrice,
	staked
FROM
	asset WHERE 1 = 1 ";
	
	if($tokenID > -1) {
		$query = $query . " AND asset.tokenID = " . $tokenID . " AND revealed = 1 ";
	} else {
		if(count($traitfilters) > 0) {
			$query = $query . " AND asset.tokenID IN (SELECT ta1.tokenID FROM asset ta1 ";
		}
		for($i = 0; $i < count($traitfilters); ++$i) {
			$query = $query . "INNER JOIN (SELECT tokenID FROM asset_trait WHERE categoryID = " . str_replace("'", "''", strval($traitfilters[$i][0])) . " ";
			if (count($traitfilters[$i]) > 1) {
				$query = $query . " AND valueID IN (-1" ;
				for($k = 0; $k < count($traitfilters[$i][1]); ++$k)  {
					$query = $query . ", " . str_replace("'", "''", strval($traitfilters[$i][1][$k]));
				}
				$query = $query . ")";
			}
			$query = $query . ") AS T" . strval($i) . " ON ta1.tokenID = T" . strval($i) . ".tokenID ";
		}
		if(count($traitfilters) > 0) {
			$query = $query . " ) ";
		}
		if($listed == 1) {
			$query = $query . " AND listed = 1 ";
		}
		if($staked == 1) {
			$query = $query . " AND staked = 1 ";
		}
		if($priceMin > 0) {
			$query = $query . " AND listedPrice >= " . $priceMin;
		}
		if($priceMax > 0) {
			$query = $query . " AND listedPrice <= " . $priceMax;
		}
		if($ownerAddr != '') {
			$query = $query . " AND currentOwner = '" . str_replace("'", "''", $ownerAddr) . "' ";
		}
	}
	
	if($sort == 1) {
		$query = $query . " order by rank asc ";
	} else if($sort == 2) {
		$query = $query . " order by rank desc ";
	} else if($sort == 3) {
		$query = $query . " AND listed = 1 order by listedPrice asc ";
	} else if($sort == 4) {
		$query = $query . " AND listed = 1 order by listedPrice desc ";
	} else if($sort == 5) {
		$query = $query . " AND revealed = 1 order by tokenID asc ";
	} else if($sort == 6) {
		$query = $query . " AND revealed = 1 order by tokenID desc ";
	}
	
	$query = $query . " LIMIT " . $limit . " OFFSET " . (($page - 1) * $limit) . ";";

  
    // prepare query statement
    $stmt = $this->conn->prepare($query);
  
    // execute query
    $stmt->execute();
  
    return $stmt;
}
	
	// read assets
function getFilteredAssetCount($traitfilters = array(),$tokenID = -1,$sort = 1,$priceMin = 0,$priceMax = 0, $listed = 0, $staked = 0, $ownerAddr = ''){
	$priceMin = $priceMin * 10**9;
	$priceMax = $priceMax * 10**9; //convert to GWEI 
	
    // select all query
    $query = "SELECT COUNT(*) as assetCount, SUM(IF(asset.revealed = 1, 1, 0)) as minted FROM asset WHERE 1 = 1 ";
	
	if($tokenID > -1) {
		$query = $query . " AND asset.tokenID = " . $tokenID . " AND revealed = 1 ";
	} else {
		if(count($traitfilters) > 0) {
			$query = $query . " AND asset.tokenID IN (SELECT ta1.tokenID FROM asset ta1 ";
		}
		for($i = 0; $i < count($traitfilters); ++$i) {
			$query = $query . "INNER JOIN (SELECT tokenID FROM asset_trait WHERE categoryID = " . str_replace("'", "''", strval($traitfilters[$i][0])) . " ";
			if (count($traitfilters[$i]) > 1) {
				$query = $query . " AND valueID IN (-1" ;
				for($k = 0; $k < count($traitfilters[$i][1]); ++$k)  {
					$query = $query . ", " . str_replace("'", "''", strval($traitfilters[$i][1][$k]));
				}
				$query = $query . ")";
			}
			$query = $query . ") AS T" . strval($i) . " ON ta1.tokenID = T" . strval($i) . ".tokenID ";
		}
		if(count($traitfilters) > 0) {
			$query = $query . " ) ";
		}
		if($sort == 3 || $sort == 4) {
		    $query = $query . " AND listed = 1 ";
		}
		if($listed == 1) {
			$query = $query . " AND listed = 1 ";
		}
		if($staked == 1) {
			$query = $query . " AND staked = 1 ";
		}
		if($priceMin > 0) {
			$query = $query . " AND listedPrice >= " . $priceMin;
		}
		if($priceMax > 0) {
			$query = $query . " AND listedPrice <= " . $priceMax;
		}
		if($sort == 5) {
			$query = $query . " AND revealed = 1 ";
		} else if($sort == 6) {
			$query = $query . " AND revealed = 1 ";
		}
		if($ownerAddr != '') {
			$query = $query . " AND currentOwner = '" . str_replace("'", "''", $ownerAddr) . "' ";
		}
	}
	

  
    // prepare query statement
    $stmt = $this->conn->prepare($query);
  
    // execute query
    $stmt->execute();
  
    return $stmt;
}

function updateLatestPunk($latestpunk = 0) {
	if(is_numeric($latestpunk)) { 
		$query = "update asset set revealed = 1 WHERE tokenID <= " . $latestpunk . ";";
		$stmt = $this->conn->prepare($query);
		$stmt->execute();
		$query = "update trait_value set revealed = 1 WHERE valueID in (select valueID from asset_trait where tokenID in (select tokenID from asset where revealed = 1));";
		$stmt = $this->conn->prepare($query);
		$stmt->execute();
	}
}
}
?>