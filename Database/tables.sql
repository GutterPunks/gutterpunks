-- phpMyAdmin SQL Dump
-- version 4.9.7
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jul 24, 2022 at 03:52 AM
-- Server version: 5.6.51-cll-lve
-- PHP Version: 7.3.32

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `gutterpunks`
--

-- --------------------------------------------------------

--
-- Table structure for table `asset`
--

CREATE TABLE `asset` (
  `tokenID` int(11) NOT NULL,
  `customName` varchar(255) NOT NULL,
  `imageIPFS` varchar(128) NOT NULL,
  `thumbnailIPFS` varchar(128) NOT NULL,
  `rarityScore` float NOT NULL,
  `rank` int(11) NOT NULL,
  `revealed` tinyint(1) NOT NULL DEFAULT '0',
  `traitCount` int(11) NOT NULL,
  `traitCountRarity` float NOT NULL,
  `currentChainID` int(11) NOT NULL,
  `currentOwner` varchar(128) NOT NULL,
  `listed` tinyint(1) NOT NULL,
  `listedPrice` bigint(11) NOT NULL,
  `staked` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `asset_trait`
--

CREATE TABLE `asset_trait` (
  `tokenID` int(11) NOT NULL,
  `categoryID` int(11) NOT NULL,
  `valueID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `trait_category`
--

CREATE TABLE `trait_category` (
  `categoryID` int(11) NOT NULL,
  `categoryName` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


-- --------------------------------------------------------

--
-- Table structure for table `trait_value`
--

CREATE TABLE `trait_value` (
  `valueID` int(11) NOT NULL,
  `categoryID` int(11) NOT NULL,
  `value` varchar(255) NOT NULL,
  `imageIPFS` varchar(128) NOT NULL,
  `rarityScore` float NOT NULL,
  `occurrences` int(11) NOT NULL,
  `revealed` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


--
-- Indexes for dumped tables
--

--
-- Indexes for table `asset`
--
ALTER TABLE `asset`
  ADD PRIMARY KEY (`tokenID`);

--
-- Indexes for table `asset_trait`
--
ALTER TABLE `asset_trait`
  ADD KEY `tokenID` (`tokenID`),
  ADD KEY `categoryID` (`categoryID`),
  ADD KEY `valueID` (`valueID`);

--
-- Indexes for table `trait_category`
--
ALTER TABLE `trait_category`
  ADD PRIMARY KEY (`categoryID`);

--
-- Indexes for table `trait_value`
--
ALTER TABLE `trait_value`
  ADD PRIMARY KEY (`valueID`),
  ADD KEY `categoryID` (`categoryID`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `asset_trait`
--
ALTER TABLE `asset_trait`
  ADD CONSTRAINT `asset_trait_ibfk_1` FOREIGN KEY (`tokenID`) REFERENCES `asset` (`tokenID`),
  ADD CONSTRAINT `asset_trait_ibfk_2` FOREIGN KEY (`categoryID`) REFERENCES `trait_category` (`categoryID`),
  ADD CONSTRAINT `asset_trait_ibfk_3` FOREIGN KEY (`valueID`) REFERENCES `trait_value` (`valueID`);


--
-- Constraints for table `trait_value`
--
ALTER TABLE `trait_value`
  ADD CONSTRAINT `trait_value_ibfk_1` FOREIGN KEY (`categoryID`) REFERENCES `trait_category` (`categoryID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
