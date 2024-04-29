DROP TABLE IF EXISTS `Position`;
DROP TABLE IF EXISTS `Device`;
DROP TABLE IF EXISTS `User`;
DROP TABLE IF EXISTS `SSAFYUser`;

DROP TABLE IF EXISTS `Team`;
DROP TABLE IF EXISTS `Class`;
DROP TABLE IF EXISTS `Location`;

CREATE TABLE `Location` (
                            `location_code`	VARCHAR(5)	NOT NULL,
                            `location_name`	VARCHAR(40)	NOT NULL,
                            PRIMARY KEY (`location_code`)
);

CREATE TABLE `Class` (
                         `class_code`	VARCHAR(5)	NOT NULL,
                         `location_code`	VARCHAR(5)	NOT NULL,
                         PRIMARY KEY (`class_code`),
                         FOREIGN KEY (`location_code`) REFERENCES `Location` (`location_code`)
);

CREATE TABLE `Team` (
                        `team_code` VARCHAR(5)	NOT NULL,
                        `team_name` VARCHAR(20) NULL,
                        `class_code` VARCHAR(5)	NOT NULL,
                        PRIMARY KEY (`team_code`),
                        FOREIGN KEY (`class_code`) REFERENCES `Class` (`class_code`)
);

CREATE TABLE `SsafyUser`(
                            `user_id`   VARCHAR(20) NOT NULL,
                            `job_code`  INT NOT NULL,
                            `team_code` VARCHAR(5)  NOT NULL,
                            `user_name` VARCHAR(10) NOT NULL,
                            `card_serial_id` VARCHAR(30)  NULL,
                            PRIMARY KEY (`user_id`),
                            FOREIGN KEY (`team_code`) REFERENCES `Team` (`team_code`)
);

CREATE TABLE `User`(
                       `user_id` VARCHAR(20) NOT NULL,
                       `status_id` INT NOT NULL DEFAULT 0,
                       `user_email` VARCHAR(40) NOT NULL COMMENT '로그인',
                       `password` VARCHAR (255)NOT NULL,
                       `profile_img` VARCHAR(255) NULL,
                       `background_img` VARCHAR(255) NULL,
                       `rayout` INT NOT NULL DEFAULT 1,
                       `connect_flag` INT NULL DEFAULT 0,
                        `position_name` VARCHAR(20) NULL,
                       PRIMARY KEY (`user_id`),
                       CONSTRAINT `FK_SSAFYUser_TO_User_1` FOREIGN KEY (`user_id`) REFERENCES `SSAFYUser` (`user_id`)
);

CREATE TABLE `Device` (
                          `device_id` VARCHAR(40) NOT NULL,
                          `user_id` VARCHAR(20) NULL,
                          PRIMARY KEY (`device_id`),
                          FOREIGN KEY (`user_id`) REFERENCES `User` (`user_id`)
);


CREATE TABLE `Position`
(
    `position_name` VARCHAR(20) NOT NULL,
    `color_code`    VARCHAR(8)  NOT NULL DEFAULT '#3DB887',
    PRIMARY KEY (`position_name`)
);

