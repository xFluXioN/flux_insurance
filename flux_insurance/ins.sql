ALTER TABLE `user_licenses` ADD `time` INT(50) NOT NULL DEFAULT '-1' AFTER `owner`;

INSERT INTO `licenses` (`type`, `label`) VALUES ('ems_insurance', 'Medical insurance'), ('oc_insurance', 'Vehicle insurance');
