INSERT INTO `Location` (`location_code`, `location_name`) VALUES
                                                           ('A', '서울'),
                                                           ('B','대전'),
                                                           ('C','광주'),
                                                            ('D','구미'),
                                                            ('E','부울경'),
                                                            ('Z','테스트');
INSERT INTO `Class` (`class_code`, `location_code`) VALUES
                                                    ('A1','A'),('A2','A'),('A3','A'),
                                                    ('A4','A'),
                                                    ('A5','A'),
                                                    ('A6','A'),
                                                    ('A7','A'),
                                                    ('B1','B'),
                                                    ('B2','B'),
                                                    ('B3','B'),
                                                    ('C1','C'),
                                                    ('C2','C'),
                                                    ('D1','D'),
                                                    ('D2','D'),
                                                    ('E0','E'),
                                                    ('E1','E'),
                                                    ('E2','E'),
                                                    ('Z1','Z'),('Z2','Z'),('Z3','Z'),('Z4','Z'),('Z5','Z'),('Z6','Z'),('Z7','Z'),('Z8','Z'),('Z9','Z'),('Z10','Z');

INSERT INTO `Team` (`team_code`, `team_name`, `class_code`) VALUES
    ('A101','A101','A1'),('A102','A102','A1'),('A103','A103','A1'),('A104','A104','A1'), ('A105','A105','A1'),('A106','A106','A1'),('A107','A107','A1'),
    ('A201','A201','A2'),('A202','A202','A2'),('A203','A203','A2'),
    ('A301','A301','A3'), ('A302','A302','A3'),
    ('A401','A401','A4'),('A402','A402','A4'),
    ('E101','E101','E1'),('E102','E102','E1'),('E103','E103','E1'),('E104','E104','E1'),('E105','E105','E1'),('E106','E106','E1'),('E107','E107','E1'),
    ('E200','E200','E2'),('E201','E201','E2'),('E202','E202','E2'),('E203','E203','E2'),('E204','E204','E2'),('E205','E205','E2'),('E206','E206','E2'),('E207','E207','E2'),
    ('Z101','Z101','Z1'),('Z102','Z102','Z1'),('Z103','Z103','Z1'),('Z104','Z104','Z1'),('Z105','Z105','Z1'),('Z106','Z106','Z1'),('Z107','Z107','Z1'),
    ('Z201','Z201','Z2'),('Z202','Z202','Z2'),('Z203','Z203','Z2'),('Z204','Z204','Z2'),('Z205','Z205','Z2'),('Z206','Z206','Z2'),('Z207','Z207','Z2'),
    ('Z901','Z901','Z9'),('Z902','Z902','Z9'),('Z903','Z903','Z9'),('Z904','Z904','Z9');

INSERT INTO `SsafyUser` (`user_id`, `job_code`, `team_code`, `user_name`,`card_serial_id`) VALUES
                                                                                               ('1000000',4,'E200','마스타','MASTERKEY'),
                                                                                               ('1058448',1,'E203','원종현','04fc4ccc780000'),
                                                                                               ('1053374',1,'E203','손종민','0422a6bd790000'),
                                                                                               ('1052881',1,'E203','한성주','043d2bcc780000'),
                                                                                               ('1058706',1,'E203','서지수','04413fbd790000'),
                                                                                               ('1055605',1,'E203','장현욱','04305598780000'),
                                                                                               ('1057753',1,'E203','이동호','04c8ba97780000'),
                                                                                               ('1000001',1,'Z901','홍길동','AAAA1'),
                                                                                               ('1000002',2,'Z902','김길동','AAAA2'),
                                                                                               ('1000003',3,'Z903 ','최박사','AAAA3'),
                                                                                               ('1000004',3,'Z904 ','홍박사','AAAA4'),
                                                                                               ('1000005',1,'Z901','박길동','AAAA5'),
                                                                                               ('1000006','1','Z901','최길동','AAAA6'),
                                                                                               ('9000001',1,'Z101','김일박','ZZZZ1'),
                                                                                               ('9000002',1,'Z101','김이박','ZZZZ2'),
                                                                                               ('9000003',1,'Z101','김삼박','ZZZZ3'),
                                                                                               ('9000004',1,'Z101','김사박','ZZZZ4'),
                                                                                               ('9000005',1,'Z101','김오박','ZZZZ5'),
                                                                                               ('9000011',1,'Z102','갑일박','ZZZZ11'),
                                                                                               ('9000012',1,'Z102','갑이박','ZZZZ12'),
                                                                                               ('9000013',1,'Z102','갑삼박','ZZZZ13'),
                                                                                               ('9000014',1,'Z102','갑사박','ZZZZ14'),
                                                                                               ('9000015',1,'Z102','갑오박','ZZZZ15'),
                                                                                               ('9000016',1,'Z103','원싸피','ZZZZ21');




INSERT INTO `Device` (`device_id`) VALUES
                                       ('DDDD1'),
                                       ('DDDD2'),
                                       ('DDDD3'),
                                       ('DDDD4'),
                                       ('DDDD5'),
                                       ('10000000ee105777');

INSERT INTO `Position` (`position_name`, `color_code`) VALUES
                                                           ('BE', '#3DB887'),
                                                           ('FE', '#FFD700'),
                                                           ('Infra', '#FF6347'),
                                                           ('PM', '#FF4500');

INSERT INTO Device (device_id, user_id, x_coord, y_coord, class_code) VALUES
                                                                          ('E20011', NULL, 36, 290, 'E2'),
                                                                          ('E20012', NULL, 36, 390, 'E2'),
                                                                          ('E20013', NULL, 36, 490, 'E2'),
                                                                          ('E20014', NULL, 136, 290, 'E2'),
                                                                          ('E20015', NULL, 136, 390, 'E2'),
                                                                          ('E20016', NULL, 136, 490, 'E2'),
                                                                          ('E20021', NULL, 36, 647, 'E2'),
                                                                          ('E20022', NULL, 36, 747, 'E2'),
                                                                          ('E20023', NULL, 36, 847, 'E2'),
                                                                          ('E20024', NULL, 136, 647, 'E2'),
                                                                          ('E20025', NULL, 136, 747, 'E2'),
                                                                          ('E20026', NULL, 136, 847, 'E2'),
                                                                          ('E20031', NULL, 36, 1004, 'E2'),
                                                                          ('E20032', NULL, 36, 1104, 'E2'),
                                                                          ('E20033', NULL, 36, 1204, 'E2'),
                                                                          ('E20034', NULL, 136, 1004, 'E2'),
                                                                          ('E20035', NULL, 136, 1104, 'E2'),
                                                                          ('E20036', NULL, 136, 1204, 'E2'),
                                                                          ('E20041', NULL, 381, 489, 'E2'),
                                                                          ('E20042', NULL, 381, 589, 'E2'),
                                                                          ('E20043', NULL, 381, 689, 'E2'),
                                                                          ('E20044', NULL, 481, 489, 'E2'),
                                                                          ('E20045', NULL, 481, 589, 'E2'),
                                                                          ('E20046', NULL, 481, 689, 'E2'),
                                                                          ('E20051', NULL, 718, 290, 'E2'),
                                                                          ('E20052', NULL, 718, 390, 'E2'),
                                                                          ('E20053', NULL, 718, 490, 'E2'),
                                                                          ('E20054', NULL, 818, 290, 'E2'),
                                                                          ('E20055', NULL, 818, 390, 'E2'),
                                                                          ('E20056', NULL, 818, 490, 'E2'),
                                                                          ('E20061', NULL, 718, 647, 'E2'),
                                                                          ('E20062', NULL, 718, 747, 'E2'),
                                                                          ('E20063', NULL, 718, 847, 'E2'),
                                                                          ('E20064', NULL, 818, 647, 'E2'),
                                                                          ('E20065', NULL, 818, 747, 'E2'),
                                                                          ('E20066', NULL, 818, 847, 'E2'),
                                                                          ('E20071', NULL, 718, 1004, 'E2'),
                                                                          ('E20072', NULL, 718, 1104, 'E2'),
                                                                          ('E20073', NULL, 718, 1204, 'E2'),
                                                                          ('E20074', NULL, 818, 1004, 'E2'),
                                                                          ('E20075', NULL, 818, 1104, 'E2'),
                                                                          ('E20076', NULL, 818, 1204, 'E2');