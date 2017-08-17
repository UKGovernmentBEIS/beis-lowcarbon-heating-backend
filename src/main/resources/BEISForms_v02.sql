--Drop all tables(if any):- 
DROP TABLE IF EXISTS public.application, public.application_form, public.application_form_question,
public.application_form_section, public.application_section, public.opportunity, public.paragraph,
public.section, public.play_evolutions;

--Drop all sequences(if any):- 
DROP SEQUENCE IF EXISTS public.applicationform_id_seq, public.applicationformquestion_id_seq, 
public.applicationformsection_id_seq, public.opportunity_id_seq, public.section_id_seq;

--Create Tables and Sequences:-

create table "paragraph" ("id" BIGINT NOT NULL PRIMARY KEY,"paragraph_number" INTEGER NOT NULL,"section_id" BIGINT NOT NULL,"text" VARCHAR(255) NOT NULL);
create index "paragraph_section_idx" on "paragraph" ("section_id");
create table "section" ("id" BIGINT NOT NULL PRIMARY KEY,"section_number" INTEGER NOT NULL,"opportunity_id" BIGINT NOT NULL,"title" VARCHAR(255) NOT NULL);
create index "section_opportunity_idx" on "section" ("opportunity_id");
create table "opportunity" ("id" BIGINT NOT NULL PRIMARY KEY,"title" VARCHAR(255) NOT NULL,"start_date" VARCHAR(255) NOT NULL,"duration" INTEGER,"duration_units" VARCHAR(255),"value" decimal(9, 2) NOT NULL,"value_units" VARCHAR(255) NOT NULL);
alter table "paragraph" add constraint "paragraph_section_fk" foreign key("section_id") references "section"("id") on update NO ACTION on delete CASCADE;
alter table "section" add constraint "section_opportunity_fk" foreign key("opportunity_id") references "opportunity"("id") on update NO ACTION on delete CASCADE;

insert into "opportunity" values (1, 'Research priorities in health care', '4 March 2017', null, null, 2000, 'per event maximum');

insert into "section" values (1, 1, 1, 'About this opportunity');
insert into "section" values (2, 2, 1, 'The events we will fund');
insert into "section" values (3, 3, 1, 'What events should cover');
insert into "section" values (4, 4, 1, 'How to get funding');
insert into "section" values (5, 5, 1, 'Assessment Criteria');
insert into "section" values (6, 6, 1, 'Further Information');

insert into "paragraph" values (1, 1, 1, 'We want to achieve the widest benefit to society and the economy from the research we fund.');
insert into "paragraph" values (2, 2, 1, 'As part of this, we want to help you to develop innovative ways of building on the research they carry out.');
insert into "paragraph" values (3, 3, 1, 'This may be by sharing knowledge, commercialising ideas, exploring social benefits or other ways to increase the impact of your research.');
insert into "paragraph" values (4, 4, 1, 'Under the Exploring Innovation Seminars programme, we will pay up to £2,000 for each event promoting innovation and collaboration. We will not pay for food or drink.');
insert into "paragraph" values (5, 5, 1, 'Only organisations which receive funding from UK Research Councils may apply.');


insert into "paragraph" values (6, 1, 2, 'To receive funding for the event, your research organisation must receive funding from the research council and must aim to attract research council supported researchers to the event.');
insert into "paragraph" values (7, 2, 2, 'We encourage applications that are coordinated across departments within a research organisation or between different research organisations.');
insert into "paragraph" values (8, 3, 2, 'We advise that attendees are invited from relevant faculties, colleges or departments, and where the primary aim is knowledge exchange, relevant stakeholders should be invited e.g. representatives from industry.');

create table "application_form_section" ("id" BIGINT NOT NULL PRIMARY KEY,"application_form_id" BIGINT NOT NULL,"section_number" INTEGER NOT NULL,"title" VARCHAR(255) NOT NULL,"started" BOOLEAN NOT NULL);
create index "applicationformsection_application_idx" on "application_form_section" ("application_form_id");
create table "application_form" ("id" BIGINT NOT NULL PRIMARY KEY,"opportunity_id" BIGINT NOT NULL);
create index "application_form_opportunity_idx" on "application_form" ("opportunity_id");
alter table "application_form_section" add constraint "applicationformsection_application_fk" foreign key("application_form_id") references "application_form"("id") on update NO ACTION on delete CASCADE;
alter table "application_form" add constraint "application_form_opportunity_fk" foreign key("opportunity_id") references "opportunity"("id") on update NO ACTION on delete CASCADE;

insert into "application_form" values (1, 1);

insert into "application_form_section" values (1, 1, 1, 'Event title', false);
insert into "application_form_section" values (2, 1, 2, 'Provisional date', false);
insert into "application_form_section" values (3, 1, 3, 'Event objectives', false);
insert into "application_form_section" values (4, 1, 4, 'Topics and speakers', false);
insert into "application_form_section" values (5, 1, 5, 'Event audience', false);
insert into "application_form_section" values (6, 1, 6, 'Costs', false);
create table "application_section" (
  "id" BIGSERIAL NOT NULL PRIMARY KEY,
  "application_id" BIGINT NOT NULL,
  "section_number" INTEGER NOT NULL,
  "answers" jsonb NOT NULL
);
create index "applicationsection_application_idx" on "application_section" ("application_id");
create table "application" ("id" BIGSERIAL NOT NULL PRIMARY KEY,"application_form_id" BIGINT NOT NULL);
create index "application_application_form_idx" on "application" ("application_form_id");
alter table "application_section" add constraint "applicationsection_application_fk" foreign key("application_id") references "application"("id") on update NO ACTION on delete CASCADE;
alter table "application" add constraint "application_application_form_fk" foreign key("application_form_id") references "application_form"("id") on update NO ACTION on delete CASCADE;
alter table "application_section" ADD COLUMN completed_at_dt TIMESTAMP;
alter table "application_section" add constraint "unique_section_number_per_application" unique (application_id, section_number);

delete from paragraph where id = 2;
insert into paragraph (id, section_id, paragraph_number, text) values (2, 1, 2, 'As part of this, we want to help you develop innovative ways of building on the research you carry out.');

update opportunity set title = 'Exploring innovation seminars' where title = 'Research priorities in health care';

delete from section
where
  opportunity_id in (select id from opportunity where title = 'Exploring innovation seminars')
and
  section_number > 1;

insert into section values(2, 2, 1, 'What we will ask you');
insert into section values(3, 3, 1, 'Assessment criteria');

insert into paragraph values (9, 1, 2, 'Event title');
insert into paragraph values (10, 2, 2, 'What is your event called? Wordcount 20');
insert into paragraph values (11, 3, 2, ' ');
insert into paragraph values (12, 4, 2, 'Provisional date');
insert into paragraph values (13, 5, 2, 'You can can change this in the future.');
insert into paragraph values (14, 6, 2, ' ');
insert into paragraph values (15, 7, 2, 'Event objectives');
insert into paragraph values (16, 8, 2, 'What are the objectives of the event? Who will benefit? What will you do to maximise the benefits? Wordcount: 500');
insert into paragraph values (17, 9, 2, ' ');
insert into paragraph values (18, 10, 2, 'Topics and speakers');
insert into paragraph values (19, 11, 2, 'Who is the event''s target audience?  There may be one or more audiences.  How many people do you expect to attend? Which sectors (for example, academic, industrial, legal) will they represent?  Wordcount: 500');
insert into paragraph values (20, 12, 2, '');
insert into paragraph values (21, 13, 2, 'Costs');
insert into paragraph values (22, 14, 2, 'We will pay up to £2,000 towards the travel and accommodation costs of external speakers, room fees, equipment, time spent in organising the event and any other reasonable costs.');
insert into paragraph values (23, 15, 2, 'You can''t claim for food or drink. After the event, we''ll need a detailed invoice itemising all costs claimed before we release the funds.  Wordcount 200 words per item justification.');
insert into paragraph values (24, 1, 3, 'Assessment Criteria');
insert into paragraph values (25, 2, 3, 'Applications will be assessed against the following criteria which are all equally weighted: ');
insert into paragraph values (26, 3, 3, '- the research organisation already receives research council funding');
insert into paragraph values (27, 4, 3, '- there’s a fit with the funder’s strategic priorities');
insert into paragraph values (28, 5, 3, '- the programme includes coordination across research organisations or across various departments, schools and central offices in the research organisation');
insert into paragraph values (29, 6, 3, '- the target audience is diverse and includes academics, knowledge exchange professionals, senior management and, where appropriate, representatives from industry or stakeholder groups');
insert into paragraph values (30, 7, 3, '- the objectives are SMART (Specific, Measurable, Achievable, Relevant, Time-bound)');
insert into paragraph values (31, 8, 3, '- the costs are reasonable and the funding could make a difference');
update paragraph
set text = 'What is your event called? Wordcount: 20'
where paragraph_number = 2 and section_id = 2;


update paragraph
set text = 'You can''t claim for food or drink. After the event, we''ll need a detailed invoice itemising all costs claimed before we release the funds.  Wordcount: 200 words per item justification.'
where paragraph_number = 15 and section_id = 2;

delete from paragraph where paragraph_number = 1 and section_id = 3;

CREATE TABLE "application_form_question" (
  "id"                          BIGINT       NOT NULL PRIMARY KEY,
  "application_form_section_id" BIGINT       NOT NULL,
  "key"                         VARCHAR(255) NOT NULL,
  "text"                        VARCHAR(255) NOT NULL,
  "description"                 VARCHAR(4096),
  "help_text"                   VARCHAR(4096)
);

CREATE INDEX "applicationformquestion_application_form_section_idx"
  ON "application_form_question" ("application_form_section_id");
ALTER TABLE "application_form_question"
  ADD CONSTRAINT "applicationformquestion_application_form_section_fk" FOREIGN KEY ("application_form_section_id") REFERENCES "application_form_section" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;

INSERT INTO "application_form_question" VALUES (1, 1, 'title', 'What is your event called?', NULL, NULL);

INSERT INTO "application_form_question" VALUES (2, 2, 'provisionalDate.date', 'When do you propose to hold the event?', NULL, NULL);

INSERT INTO "application_form_question" VALUES (3, 2, 'provisionalDate.days', 'How long will it last?', NULL, NULL);

INSERT INTO "application_form_question" VALUES (4, 3, 'eventObjectives', 'What are the objectives of the event?',
                                                E'Explain what outcomes you hope the event will achieve, including who is likely to benefit and the actions you will take to maximise the benefits.',
                                                E'There are no fixed rules about content;; however the most successful events have involved senior academics working with colleagues to develop the research programme and share their strategic vision.\nFeedback from previous events has shown that it is important to keep the demands on time modest, with most seminars scheduled over a half day.');

INSERT INTO "application_form_question" VALUES (5, 4, 'topicAndSpeaker', 'What topics do you intend to cover?',
                                                E'List the subjects and speakers you are planning for the event. It doesn''t matter if they are not confirmed at this stage.',
                                                E'Possible topics for discussion include intellectual asset management, licensing and collaborative R&D.\nSpeakers might include internal or external business development professionals and others such as patent lawyers/agents and KTP advisors.\nWhenever possible, a member of our Swindon office staff will be available to participate in the seminar free of charge.');

INSERT INTO "application_form_question" VALUES (6, 5, 'eventAudience', 'Who is the event''s target audience?',
                                                E'There may be one or more target audiences. How many people do you expect to attend? What sectors (for example, academic, industrial, legal) will they represent?',
                                                E'If possible, examine the audience make-up from previous similar events. Who came to them and who is likely to come to your event?\nIt''s a good idea to invite people from relevant faculties, colleges or departments, and business development offices.');

INSERT INTO "application_form_question" VALUES (7, 6, 'item', 'What will the costs be?',
                                                E'We will pay up to £2,000 towards the travel and accommodation costs of external speakers, room fees, equipment, time spent in organising the event and any other reasonable costs.\nYou can''t claim for food or drink. After the event, we''ll need a detailed invoice itemising all costs claimed before we release the funds.',
                                                E'When you''re listing items, it''s fine to cluster them in groups, for example: printed materials including hand-outs, posters and feedback forms.\nWe''ve left plenty of room for justification, but don''t feel you have to use all of the wordcount, especially if the need for an item is obvious.\nIn terms of who pays for each item, the default setting is 100% payment from the research council. But if your organisation or a partner is covering part of the cost of an item, you can reduce this percentage accordingly.\nFor example, if your organisation is paying 75% of the venue hire, you could reduce the RC percentage to 25%.');

update paragraph set text = 'You can change this in the future.'
where
  section_id = (select id from section where title = 'What we will ask you' LIMIT 1) and
  paragraph_number = 5;


alter table "application_form_section" add column "fields" JSONB not null default '[]';
update "application_form_section"
set fields = '[{"name": "title", "type": "text", "isNumeric": false}]'
where "section_number" = 1;

update "application_form_section"
set fields = '[{"name": "provisionalDate", "type": "dateWithDays", "allowPast":false, "minValue":1, "maxValue":9}]'
where "section_number" = 2;

update "application_form_section"
set fields = '[{"name": "eventObjectives", "type": "textArea"}]'
where "section_number" = 3;

update "application_form_section"
set fields = '[{"name": "topicAndSpeaker", "type": "textArea"}]'
where "section_number" = 4;

update "application_form_section"
set fields = '[{"name": "eventAudience", "type": "textArea"}]'
where "section_number" = 5;

update "application_form_section"
set fields = '[{"name": "", "type": "costList"}]'
where "section_number" = 6;

alter table "section" add column "text" VARCHAR(8192);

UPDATE "section"
SET "text" = E'We want to achieve the widest benefit to society and the economy from the research we fund.

As part of this, we want to help you develop innovative ways of building on the research you carry out.

This may be by sharing knowledge, commercialising ideas, exploring social benefits or other ways to increase the impact of your research.

Under the Exploring Innovation Seminars programme, we will pay up to £2,000 for each event promoting innovation and collaboration. We will not pay for food or drink.

Only organisations which receive funding from UK Research Councils may apply.'
WHERE "section_number" = 1;

UPDATE "section"
SET "text" = E'Event title

What is your event called? Wordcount: 20

Provisional date

You can change this in the future.

Event objectives

What are the objectives of the event? Who will benefit? What will you do to maximise the benefits? Wordcount: 500

Topics and speakers

Who is the event''s target audience?  There may be one or more audiences.  How many people do you expect to attend? Which sectors (for example, academic, industrial, legal) will they represent?  Wordcount: 500

Costs

We will pay up to £2,000 towards the travel and accommodation costs of external speakers, room fees, equipment, time spent in organising the event and any other reasonable costs.

You can''t claim for food or drink. After the event, we''ll need a detailed invoice itemising all costs claimed before we release the funds.  Wordcount: 200 words per item justification.'
WHERE "section_number" = 2;

UPDATE "section"
SET "text" = E'Applications will be assessed against the following criteria which are all equally weighted:

- the research organisation already receives research council funding

- there’s a fit with the funder’s strategic priorities

- the programme includes coordination across research organisations or across various departments, schools and central offices in the research organisation

- the target audience is diverse and includes academics, knowledge exchange professionals, senior management and, where appropriate, representatives from industry or stakeholder groups

- the objectives are SMART (Specific, Measurable, Achievable, Relevant, Time-bound)

- the costs are reasonable and the funding could make a difference'
WHERE "section_number" = 3;




update "application_form_section"
set fields = '[{"name": "title", "type": "text", "isNumeric": false, "maxWords": 20}]'
where "section_number" = 1;

update "application_form_section"
set fields = '[{"name": "eventObjectives", "type": "textArea", "maxWords": 500}]'
where "section_number" = 3;

update "application_form_section"
set fields = '[{"name": "topicAndSpeaker", "type": "textArea", "maxWords": 500}]'
where "section_number" = 4;

update "application_form_section"
set fields = '[{"name": "eventAudience", "type": "textArea", "maxWords": 500}]'
where "section_number" = 5;

alter table "application_form_section" drop column "started";

alter table "application_form_section" add column "section_type" varchar(50) not null default 'form';
update "application_form_section" set "section_type" = 'list' where "section_number" = 6;
update "application_form_section" set "fields" = '[]' where "section_number" = 6;

alter table "opportunity" drop column duration;
alter table "opportunity" drop column duration_units;
alter table "opportunity" add column end_date varchar(255);

ALTER TABLE "application_form" ADD CONSTRAINT "one_form_per_opportunity" UNIQUE ("id", "opportunity_id");

update "application_form_section" set "fields" = '[{"name": "cost", "type": "costItem"}]' where "section_number" = 6;

update "application_form_section" set "fields" = '[{"name": "item", "type": "costItem"}]' where "section_number" = 6;

--21--

alter table "opportunity" add column "published_at_dtime" timestamptz;
alter table "opportunity" add column "duplicated_from_id" BIGINT;

alter table "opportunity" add constraint "duplicated_opportunity_fk" foreign key("duplicated_from_id") references "opportunity"("id") on update NO ACTION on delete CASCADE;

update "opportunity" set "published_at_dtime" = '2016-11-28 00:00:00' where id = 1;

ALTER TABLE "application_section" ALTER COLUMN "completed_at_dt" TYPE TIMESTAMPTZ;

CREATE SEQUENCE opportunity_id_seq START WITH 3;
ALTER TABLE "opportunity" ALTER column "id" SET DEFAULT NEXTVAL('opportunity_id_seq');

CREATE SEQUENCE section_id_seq START WITH 7;
ALTER TABLE "section" ALTER column "id" SET DEFAULT NEXTVAL('section_id_seq');

CREATE SEQUENCE applicationform_id_seq START WITH 3;
ALTER TABLE "application_form" ALTER column "id" SET DEFAULT NEXTVAL('applicationform_id_seq');

CREATE SEQUENCE applicationformsection_id_seq START WITH 11;
ALTER TABLE "application_form_section" ALTER column "id" SET DEFAULT NEXTVAL('applicationformsection_id_seq');

CREATE SEQUENCE applicationformquestion_id_seq START WITH 11;
ALTER TABLE "application_form_question" ALTER column "id" SET DEFAULT NEXTVAL('applicationformquestion_id_seq');

--22--

ALTER TABLE "section"
  ADD COLUMN "description" VARCHAR(8192) NOT NULL default 'no description';
ALTER TABLE "section"
  ADD COLUMN "help_text" VARCHAR(8192) NULL;

UPDATE section
SET
  description = 'Be as specific as possible so that applicants fully understand the aim of the opportunity. This will help ensure that applications meet the criteria and objectives.',
  help_text = E'There are no fixed rules about content;; however the most successful events have involved senior academics working with colleagues to develop the research programme and share their strategic vision.

Feedback from previous events has shown that it is important to keep the demands on time modest, with most seminars scheduled over a half day.'
WHERE section_number = 1;

UPDATE section
SET
  description = 'Describe the questions the applicant will see on their application form.',
  help_text = NULL
WHERE section_number = 2;

UPDATE section
SET
  description = 'Which criteria will be used to assess applications?',
  help_text = E'Criteria will depend on the opportunity, but may include quality, objectives, collaboration between teams and organisations, and value for money. You may weight criteria equally or set priorities.'
WHERE section_number = 3;

ALTER TABLE "application"
  ADD COLUMN "personal_reference" VARCHAR(255) NULL;

alter table section add column "section_type" varchar(30) not null default 'text';
update section set text = null, section_type = 'questions' where section_number = 2;

-- 25-----

delete from application_form_question where id > 5;

update "application_form_question"
set key = 'companyInfo', text = 'what is your company name and number?', description = 'companyNameNumber description', help_text = 'companyNameNumber help_text',
application_form_section_id = 1
where "id" = 1;

update "application_form_question"
set key = 'charityNumber', text = 'What is your Charity Number?', description = 'charityNumber description', help_text = 'charityNumber help_text',
application_form_section_id = 2
where "id" = 2;

update "application_form_question"
set key = 'companyAddress', text = 'What is your company address?', description = 'companyAddress description', help_text = 'companyAddress help_text',
application_form_section_id = 3
where "id" = 3;


update "application_form_question"
set key = 'supportingDocuments', text = 'What are the Supporting Documents?', description = 'File size maximum is 5 Mb. You can upload further files', help_text = 'supportingDocuments help_text',
application_form_section_id = 4
where "id" = 4;


update "application_form_question"
set key = 'item', text = 'What will the costs be?', description = 'We will pay up to £2,000 towards equipment', help_text = 'Costitem help_text',
application_form_section_id = 5
where "id" = 5;


update "application_form_section"
set title = 'Company Info', fields = '[{"isNumeric":false,"maxWords":20,"type":"text","name":"companyInfo"}]'
where "section_number" = 1;

update "application_form_section"
set title = 'Charity Number', fields = '[{"isNumeric":false,"maxWords":20,"type":"text","name":"charityNumber"}]'
where "section_number" = 2;

update "application_form_section"
set title = 'Company Address', fields = '[{"maxWords":500,"type":"textArea","name":"companyAddress"}]'
where "section_number" = 3;

update "application_form_section"
set title = 'Supporting Documents', fields = '[{"maxWords":500,"type":"fileUpload","name":"supportingDocuments"}]', section_type = 'file'
where "section_number" = 4;

update "application_form_section"
set title = 'Cost of Item', fields = '[{"type":"costItem","name":"item"}]'
where "section_number" = 5;


--26--------

update "application_form_section" set "fields" = '[{"isNumeric":false,"maxWords":20,"type":"companyInfo","name":"companyInfo"}]' where "section_number" = 1;

update "application_form_section" set "fields" = '[{"maxWords":500,"type":"address","name":"companyAddress"}]' where "section_number" = 3;

update "opportunity" set title = 'Big Energy Saving Network 2016-2017', value = 5000 where title = 'Exploring innovation seminars';

UPDATE "section" set "text" = E'Big Energy Saving Network 2017/18:

DECC has launched the 2017/18 Big Energy Saving Network, a £1.7 million programme jointly funded by BEIS and National Energy Action (NEA) to support eligible third sector organisations and community groups, deliver help and advice to vulnerable consumers.

Use this service to:

• Apply for financial assistance towards your energy costs

• Something else 1

• Something else 2

Before you start

You can also apply by post

If you have any questions about the application process please contact BESN@beis.gov.uk.
The online service is also available in Welsh (Cymraeg)
You can''t register for this service if you''re in the UK illegally.'
WHERE "section_number" = 1 and "opportunity_id" = 1;

UPDATE "section"
SET "text" = 'The aims of the fund and the criteria by which bids will be assessed are contained in the Guidance document. Any activity funded through this competition must be completed by 24th March 2018.'
WHERE "section_number" = 3 and "opportunity_id" = 1;


---27----
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

---28-------
insert into "opportunity" values (2, 'Sickness Absence Application', '4 June 2017', 1000, 'per event maximum', null, '2016-11-28 00:00:00', null);
insert into "application_form" values (2, 2);

insert into "section" values (4, 1, 2, 'About this Form');
insert into "section" values (5, 2, 2, 'About this opportunity');
insert into "section" values (6, 3, 2, 'What to do next');


insert into "application_form_section" values (8, 2, 1, 'Manager Details', '[{"simpleform":[
{"name":"sicknessAbsence.managername","isEnabled":true,"isMandatory":true,"label":"Manager Name","maxWords":20,"fieldType":"text","isNumeric":false,"type":"text"},
{"name":"sicknessAbsence.position","isEnabled":true,"isMandatory":false,"label":"Position","maxWords":20,"fieldType":"text","isNumeric":false,"type":"text"},
{"name":"sicknessAbsence.manageremail","isEnabled":true,"isMandatory":true,"label":"Email","maxWords":100,"fieldType":"text","isNumeric":false,"type":"text"}
],"type":"simpleform","name":"sicknessAbsence","isEnabled":true,"isNumeric":false}]', 'simpleform');

insert into "application_form_section" values (9, 2, 2, 'Employee Details', '[{"simpleform":[
{"name":"sicknessAbsence.employeename","isEnabled":true,"isMandatory":true,"label":"Employee full name","maxWords":100,"fieldType":"text","isNumeric":false,"type":"text"},
{"name":"sicknessAbsence.department","isEnabled":true,"isMandatory":true,"label":"Department /section","maxWords":100,"fieldType":"text","isNumeric":false,"type":"text"},
{"name":"sicknessAbsence.firstdayofabsence","isEnabled":true,"isMandatory":false,"label":"First day of absence","maxWords":100,"fieldType":"date","isNumeric":false,"type":"date"},
{"name":"sicknessAbsence.expectedlengthofillness","isEnabled":true,"isMandatory":false,"label":"Expected length of illness (if known)","maxWords":100,"fieldType":"text","isNumeric":false,"type":"text"},
{"name":"sicknessAbsence.whoreported","isEnabled":true,"isMandatory":false,"label":"Who reported the absence?","maxWords":20,"fieldType":"text","isNumeric":false,"type":"text"},
{"name":"sicknessAbsence.natureofillness","isEnabled":true,"isMandatory":true,"label":"Nature of illness","maxWords":200,"fieldType":"textArea","isNumeric":false,"type":"text"},
{"name":"sicknessAbsence.additionalcomments","isEnabled":true,"isMandatory":false,"label":"Additional comments","maxWords":200,"fieldType":"textArea","isNumeric":false,"type":"text"},
{"name":"sicknessAbsence.actualdateofreturn","isEnabled":true,"isMandatory":false,"label":"Actual date of return","maxWords":20,"fieldType":"date","isNumeric":false,"type":"text"}
],"type":"simpleform","name":"sicknessAbsence","isEnabled":true,"isNumeric":false}]', 'simpleform');

insert into "application_form_section" values (10, 2, 3, 'Supporting Documents', '[{"maxWords":500,"isEnabled":true,"type":"fileUpload","name":"supportingDocuments","isMandatory":true}]', 'file');


INSERT INTO "application_form_question" VALUES (8, 8, 'simpleform1', 'simpleform1 Text', 'simpleform1 Description',
'simpleform1 Help Text');

INSERT INTO "application_form_question" VALUES (9, 9, 'simpleform2', 'simpleform2 Text', 'simpleform2 Description',
'simpleform2 Help Text');

