# Copyright (c) 2013 Georgios Gousios
# MIT-licensed
# [tundo91] 
# * Edited to import local XML files
# * Updated create table procedures to support Sept.-12-2016 dataset dump version
# Additional contributions by Roel Van de Paar (RoelVdP) and Mark Heath (MHLoppy)

SET @@SESSION.SQL_MODE='';

create database stackoverflow_com DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

use stackoverflow_com;



create table Badges (
  Id INT NOT NULL PRIMARY KEY,
  UserId INT,
  Name VARCHAR(50),
  Date DATETIME,
  Class SMALLINT,
  TagBased BIT(64)
);

CREATE TABLE Comments (
    Id INT NOT NULL PRIMARY KEY,
    PostId INT NOT NULL,
    Score INT NOT NULL DEFAULT 0,
    Text MEDIUMTEXT,
    CreationDate DATETIME,
    UserDisplayName VARCHAR(30),
    UserId INT
);

CREATE TABLE PostHistory (
    Id INT NOT NULL PRIMARY KEY,
    PostHistoryTypeId SMALLINT NOT NULL,
    PostId INT NOT NULL,
    RevisionGUID VARCHAR(36) NOT NULL,
    CreationDate DATETIME NOT NULL,
    UserId INT,
    UserDisplayName VARCHAR(40),
    Comment VARCHAR(400),
    Text MEDIUMTEXT
);

CREATE TABLE PostLinks (
  Id INT NOT NULL PRIMARY KEY,
  CreationDate DATETIME DEFAULT NULL,
  PostId INT NOT NULL,
  RelatedPostId INT NOT NULL,
  LinkTypeId SMALLINT NOT NULL
);


CREATE TABLE Posts (
    Id INT NOT NULL PRIMARY KEY,
    PostTypeId TINYINT NOT NULL ,
    AcceptedAnswerId INT,
    ParentId INT,
    CreationDate DATETIME NOT NULL,
    DeletionDate DATETIME,
    Score INT NULL,
    ViewCount INT NULL,
    Body MEDIUMTEXT NULL,
    OwnerUserId INT,
    OwnerDisplayName varchar(256),
    LastEditorUserId INT,
    LastEditorDisplayName VARCHAR(40),
    LastEditDate DATETIME,
    LastActivityDate DATETIME,
    Title varchar(256),
    Tags VARCHAR(256),
    AnswerCount INT DEFAULT 0,
    CommentCount INT DEFAULT 0,
    FavoriteCount INT DEFAULT 0,
    ClosedDate DATETIME,
    CommunityOwnedDate DATETIME
);

CREATE TABLE Tags (
  Id INT NOT NULL PRIMARY KEY,
  TagName VARCHAR(50) CHARACTER SET latin1 DEFAULT NULL,
  Count INT DEFAULT NULL,
  ExcerptPostId INT DEFAULT NULL,
  WikiPostId INT DEFAULT NULL
);


CREATE TABLE Users (
    Id INT NOT NULL PRIMARY KEY,
    Reputation INT NOT NULL,
    CreationDate DATETIME,
    DisplayName VARCHAR(40) NULL,
    LastAccessDate  DATETIME NOT NULL,
    WebsiteUrl VARCHAR(256) NULL,
    Location VARCHAR(256) NULL,
    AboutMe TEXT NULL,
    Views INT DEFAULT 0,
    UpVotes INT,
    DownVotes INT,
    ProfileImageUrl VARCHAR(200) NULL,
    EmailHash VARCHAR(32),
    Age INT NULL,
    AccountId INT NULL
);

CREATE TABLE Votes (
    Id INT NOT NULL PRIMARY KEY,
    PostId INT NOT NULL,
    VoteTypeId SMALLINT NOT NULL,
    UserId INT,
    CreationDate DATETIME,
    BountyAmount INT
);



load xml infile 'D:/Misc/SO_data_dump_Sep_2023/Badges.xml'
into table Badges
rows identified by '<row>';

load xml infile 'D:/Misc/SO_data_dump_Sep_2023/Comments.xml'
into table Comments
rows identified by '<row>';

load xml infile 'D:/Misc/SO_data_dump_Sep_2023/PostHistory.xml'
into table PostHistory
rows identified by '<row>';

load xml infile 'D:/Misc/SO_data_dump_Sep_2023/PostLinks.xml'
INTO TABLE PostLinks
ROWS IDENTIFIED BY '<row>';

load xml infile 'D:/Misc/SO_data_dump_Sep_2023/Posts.xml'
into table Posts
rows identified by '<row>';

load xml infile 'D:/Misc/SO_data_dump_Sep_2023/Tags.xml'
INTO TABLE Tags
ROWS IDENTIFIED BY '<row>';

load xml infile 'D:/Misc/SO_data_dump_Sep_2023/Users.xml'
into table Users
rows identified by '<row>';

load xml infile 'D:/Misc/SO_data_dump_Sep_2023/Votes.xml'
into table Votes
rows identified by '<row>';



create index Badges_idx_1 on Badges(UserId);

create index Comments_idx_1 on Comments(PostId);
create index Comments_idx_2 on Comments(UserId);

create index Post_history_idx_1 on PostHistory(PostId);
create index Post_history_idx_2 on PostHistory(UserId);

create index Posts_idx_1 on Posts(AcceptedAnswerId);
create index Posts_idx_2 on Posts(ParentId);
create index Posts_idx_3 on Posts(OwnerUserId);
create index Posts_idx_4 on Posts(LastEditorUserId);

create index Votes_idx_1 on Votes(PostId);