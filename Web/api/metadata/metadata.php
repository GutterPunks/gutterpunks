<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
$metadata = [ //USE OUTPUT FROM GENERATION SCRIPTS CSV TO MAP TOKEN ID TO METADATA HASH
1 => 'QmbfGdmRgS7AVPJJbV1ofq89TvYfa5QC3cwe52dCLgc2jz', 9999 => 'Qmd1d4LVfaEXWwCXvpjXtMifZATtJLLS6c8ihktHYVpk74'
];
	
require('../Web3/vendor/autoload.php');

use Web3\Web3;
use Web3\Providers\HttpProvider;
use Web3\RequestManagers\HttpRequestManager;
use Web3\Contract;

$lastUpdate = file_get_contents("lastupdate");
if((time() - $lastUpdate) > 5) {
	updateLatestPunk();
}

if(array_key_exists("param", $_GET)) {
	if(is_numeric($_GET["param"])) {
		$latestPunk = file_get_contents("latestpunk");
		$punkNum = $_GET["param"];
		if($punkNum > 0 && $punkNum < 10000 && $punkNum <= $latestPunk) {
			//header("HTTP/1.1 301 Moved Permanently"); 
			header("Location: ipfs://" . $metadata[$punkNum]); 
		} else {
			echo "Invalid Punk Number";
		}
	} else { 
		echo "Parameter Must Be Numeric";
	} 
} else {
	echo "No Parameter Given"; 
} 


function updateLatestPunk() {

	$abi = '<<YOUR_ABI>>';
	$contractAddress = '<<YOUR_CONTRACT_ADDRESS>';
	$contract = new Contract("https://mainnet.infura.io/v3/<<YOUR_INFURA_KEY>>", $abi);

	$functionName = 'totalSupply';

	$contract->at($contractAddress)->call($functionName, function ($err, $result) use ($contract) {
		if ($err !== null) {
			echo "error";
			throw $err;
		}

		if ($result) {
			$previousPunk = file_get_contents("latestpunk");
			$latestpunkfile = fopen("latestpunk", "w") or die("Unable to open file!");
			fwrite($latestpunkfile, $result[0]);
			fclose($latestpunkfile);
			$latestupdatefile = fopen("lastupdate", "w") or die("Unable to open file!");
			fwrite($latestupdatefile, time());
			fclose($latestupdatefile);
		}
	});
}

?>