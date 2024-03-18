CREATE DATABASE  IF NOT EXISTS `prescriptions`;
USE `prescriptions`;

CREATE TABLE `area` (
  `idarea` int NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `mean_income` decimal(15,2) NOT NULL,
  PRIMARY KEY (`idarea`)
);

CREATE TABLE `doctor` (
  `iddoctor` int NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `specialization` varchar(45) NOT NULL,
  `idarea` int NOT NULL,
  PRIMARY KEY (`iddoctor`),
  UNIQUE KEY `iddoctor_UNIQUE` (`iddoctor`),
  KEY `doctor_area_idx` (`idarea`),
  CONSTRAINT `doctor_area` FOREIGN KEY (`idarea`) REFERENCES `area` (`idarea`)
);

CREATE TABLE `drug` (
  `iddrug` int NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `description` varchar(45) DEFAULT NULL,
  `price` decimal(15,2) NOT NULL,
  PRIMARY KEY (`iddrug`)
);

CREATE TABLE `patient` (
  `ssn_patient` char(11) NOT NULL,
  `name` varchar(45) NOT NULL,
  `phone_number` varchar(45) DEFAULT NULL,
  `birthday` date NOT NULL,
  `gender` enum('male','female') NOT NULL,
  PRIMARY KEY (`ssn_patient`),
  UNIQUE KEY `ssn_UNIQUE` (`ssn_patient`)
);

CREATE TABLE `prescription` (
  `idprescription` int NOT NULL AUTO_INCREMENT,
  `datetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `quantity` int NOT NULL,
  `iddoctor` int NOT NULL,
  `ssn_patient` char(11) NOT NULL,
  `iddrug` int NOT NULL,
  PRIMARY KEY (`idprescription`),
  UNIQUE KEY `idprescription_UNIQUE` (`idprescription`),
  KEY `prescr_doctor_idx` (`iddoctor`),
  KEY `prescr_patient_idx` (`ssn_patient`),
  KEY `prescr_drug_idx` (`iddrug`),
  CONSTRAINT `prescr_doctor` FOREIGN KEY (`iddoctor`) REFERENCES `doctor` (`iddoctor`),
  CONSTRAINT `prescr_drug` FOREIGN KEY (`iddrug`) REFERENCES `drug` (`iddrug`),
  CONSTRAINT `prescr_patient` FOREIGN KEY (`ssn_patient`) REFERENCES `patient` (`ssn_patient`) ON UPDATE CASCADE
);
