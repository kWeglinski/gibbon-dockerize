



-- MySQL initialization script for GibbonEdu
-- This script runs when the database container is first created

SET GLOBAL sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';

-- Grant privileges
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';

-- Flush privileges
FLUSH PRIVILEGES;

-- Set default database for subsequent operations
USE ${DB_NAME};

-- Create necessary tables and import Gibbon schema if it exists
-- Note: The actual gibbon.sql file should be mounted by the user

-- Create uploads directory structure
CREATE TABLE IF NOT EXISTS `gibbonFile` (
  `gibbonFileID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `gibbonPersonIDCreate` int(10) unsigned DEFAULT NULL,
  `timestampCreated` datetime NOT NULL,
  `name` varchar(100) NOT NULL,
  `path` varchar(255) NOT NULL,
  `size` int(11) unsigned DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `version` int(11) unsigned NOT NULL DEFAULT '1',
  `extension` varchar(10) DEFAULT NULL,
  `folder` varchar(100) NOT NULL DEFAULT 'User Files',
  `comment` text,
  `active` enum('Y','N') NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`gibbonFileID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create session table for Redis fallback
CREATE TABLE IF NOT EXISTS `gibbonSession` (
  `gibbonSessionID` varchar(32) NOT NULL,
  `gibbonPersonID` int(10) unsigned DEFAULT NULL,
  `timestampCreated` datetime NOT NULL,
  `timestampLastAccessed` datetime NOT NULL,
  `data` text,
  `ipAddress` varchar(45) DEFAULT NULL,
  `userAgent` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`gibbonSessionID`),
  KEY `gibbonPersonID` (`gibbonPersonID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create configuration table
CREATE TABLE IF NOT EXISTS `gibbonSetting` (
  `gibbonSettingID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `scope` varchar(50) NOT NULL DEFAULT 'System',
  `name` varchar(100) NOT NULL,
  `value` text,
  `category` varchar(50) DEFAULT 'General',
  PRIMARY KEY (`gibbonSettingID`),
  UNIQUE KEY `scope_name` (`scope`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default settings
INSERT IGNORE INTO `gibbonSetting` (`scope`, `name`, `value`, `category`) VALUES
('System', 'version', 'Docker', 'General'),
('System', 'installType', 'docker', 'General'),
('System', 'defaultTimezone', '${TIMEZONE}', 'General');

-- Create backup table
CREATE TABLE IF NOT EXISTS `gibbonBackup` (
  `gibbonBackupID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `timestampCreated` datetime NOT NULL,
  `type` varchar(50) NOT NULL DEFAULT 'full',
  `size` int(11) unsigned DEFAULT NULL,
  `path` varchar(255) NOT NULL,
  `status` enum('pending','completed','failed') NOT NULL DEFAULT 'pending',
  PRIMARY KEY (`gibbonBackupID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



