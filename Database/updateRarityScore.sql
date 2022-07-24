update trait_value inner join
(select trait_value.valueID, trait_value.categoryID, trait_value.value,
	(select count(*) from asset_trait where valueID = trait_value.valueID) as occurrences,
	av2.avgByCategory,
    (select count(*) from asset) as assets
from trait_value inner join
(select 
    trait_category.categoryID, 
    avg(av1.countValue) as avgByCategory
from 
    trait_category inner join 
    trait_value on trait_category.categoryID = trait_value.categoryID inner join 
    (select asset_trait.categoryID, count(asset_trait.valueID) as countValue from asset_trait group by categoryID, asset_trait.valueID) av1 on trait_category.categoryID = av1.categoryID
group by trait_category.categoryID) av2 on trait_value.categoryID = av2.categoryID) tmp3
set rarityScore = assets / tmp3.occurrences, trait_value.occurrences = tmp3.occurrences
where trait_value.valueID = tmp3.valueID;


update asset set traitCount = (select count(*) from asset_trait where asset_trait.tokenID = asset.tokenID);



update asset inner join
    (select a3.traitCount, count(a3.tokenID) as ctc from asset a3 group by a3.traitCount) a2 on asset.traitCount = a2.traitCount
set traitCountRarity = 9999 / a2.ctc;


update asset inner JOIN	
	(select asset_trait.tokenID, sum(rarityScore) as rs from trait_value inner join asset_trait on trait_value.valueID = asset_trait.valueID group by asset_trait.tokenID) t1 on asset.tokenID = t1.tokenID
set rarityScore = traitCountRarity + t1.rs;


update asset inner join (SELECT (@row_number := @row_number + 1) as rank,
	tokenID
FROM 
	asset,
    (SELECT @row_number:=0) AS t
ORDER BY rarityScore desc) t2 on asset.tokenID = t2.tokenID
set asset.rank = t2.rank;