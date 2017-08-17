# --- !Ups

delete from application_form_section where section_number > 4;
delete from application_form_question where key = 'item';

insert into application_form_section values (5,1,5,'Contact Details', '[{"isNumeric": false, "maxWords": 20, "type": "contact", "name": "contactDetails"}]','form');
insert into application_form_section values (6,1,6,'Access needs', '[{"maxWords":500,"type":"textArea","name":"accessNeeds"}]','form');
insert into application_form_section values (7,1,7,'Funds received previously', '[{"maxWords":500,"type":"textArea","name":"fundsReceived"}]','form');

insert into application_form_question values (5,5,'contactDetails', 'What are the company contact Details?', 'Contact Details', 'contactDetails help_text');
insert into application_form_question values (6,6,'accessNeeds', 'Do you have any access needs that we should be aware of?', 'Access Needs', 'Access Needs help_text');
insert into application_form_question values (7,7,'fundsReceived', 'Has your organisation received funding through BESN previously?', ' Funds Received', 'Funds Received help_text');

ALTER TABLE "application" ADD COLUMN "user_id" VARCHAR(50) NOT NULL, ADD COLUMN "status" VARCHAR(30) NOT NULL;
update "application" set "user_id" = 'testuser', status= 'In progress' where id = 1;

update "application_form_section" set "fields" = '[{"name":"companyInfo","isEnabled":true,"isMandatory":true,"maxWords":20,"isNumeric":false,"type":"companyInfo"}]' where id = 1;
update "application_form_section" set "fields" = '[{"name":"charityNumber","isEnabled":true,"isMandatory":true,"maxWords":20,"isNumeric":false,"type":"text"}]' where id = 2;
update "application_form_section" set "fields" = '[{"maxWords":500,"isEnabled":true,"type":"address","name":"companyAddress","isMandatory":true}]' where id = 3;
update "application_form_section" set "fields" = '[{"maxWords":500,"isEnabled":true,"type":"fileUpload","name":"supportingDocuments","isMandatory":true}]' where id = 4;
update "application_form_section" set "fields" = '[{"contactitems":[{"name":"contactDetails.telephone","isEnabled":true,"isMandatory":true,"label":"Telephone","maxWords":20,"isNumeric":false,"type":"text"},{"name":"contactDetails.email","isEnabled":true,"isMandatory":true,"label":"Email","maxWords":100,"isNumeric":false,"type":"text"},{"name":"contactDetails.web","isEnabled":true,"isMandatory":false,"label":"Web","maxWords":100,"isNumeric":false,"type":"text"},{"name":"contactDetails.twitter","isEnabled":true,"isMandatory":true,"label":"Twitter","maxWords":20,"isNumeric":false,"type":"text"}],"type":"contact","name":"contactDetails"}]' where id = 5;
update "application_form_section" set "fields" = '[{"maxWords":500,"isEnabled":true,"type":"textArea","name":"accessNeeds","isMandatory":true}]' where id = 6;
update "application_form_section" set "fields" = '[{"maxWords":500,"isEnabled":true,"type":"textArea","name":"fundsReceived","isMandatory":true}]' where id = 7;

create table "messageboard" ("id" BIGINT NOT NULL PRIMARY KEY,"user_id" VARCHAR(50) NOT NULL, "application_id" BIGINT NOT NULL, "section_number" INTEGER, "sent_by" VARCHAR(50), "sent_at_dtime" timestamptz, "message" VARCHAR(500));
CREATE SEQUENCE messageboard_id_seq START WITH 1;
ALTER TABLE "messageboard" ALTER column "id" SET DEFAULT NEXTVAL('messageboard_id_seq');


# -- !Downs

insert into application_form_question values (9,9,'item', 'We will pay up to £2,000 towards equipment', 'Costitem description_text', 'Costitem help_text');
insert into application_form_section values (6,1,6,'Cost of Item', '[{"type":"costItem","name":"item"}]','list');
delete from application_form_question;
delete from application_form_section;

UPDATE "application" set "user_id" = null;
drop table "messageboard";
