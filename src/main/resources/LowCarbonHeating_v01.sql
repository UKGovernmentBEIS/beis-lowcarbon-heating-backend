DROP TABLE "application_form_section";
DROP TABLE "application_form_question";
DROP TABLE "application_section";
DROP TABLE "application";
DROP TABLE "messageboard";
DROP TABLE "paragraph";
DROP TABLE "section";
DROP TABLE "user";
DROP TABLE "reset_password";
DROP TABLE "application_form";
DROP TABLE "opportunity";


DROP SEQUENCE opportunity_id_seq;
DROP SEQUENCE applicationform_id_seq;
DROP SEQUENCE user_id_seq;
DROP SEQUENCE section_id_seq;
DROP SEQUENCE messageboard_id_seq;
DROP SEQUENCE application_section_id_seq;
DROP SEQUENCE application_id_seq;
DROP SEQUENCE applicationformquestion_id_seq;
DROP SEQUENCE applicationformsection_id_seq;
DROP SEQUENCE reset_password_id_seq;


CREATE SEQUENCE opportunity_id_seq START WITH 1;
CREATE SEQUENCE section_id_seq START WITH 1;
CREATE SEQUENCE applicationform_id_seq START WITH 1;
CREATE SEQUENCE applicationformsection_id_seq START WITH 1;
CREATE SEQUENCE applicationformquestion_id_seq START WITH 1;
CREATE SEQUENCE messageboard_id_seq START WITH 1;
CREATE SEQUENCE application_id_seq START WITH 1;
CREATE SEQUENCE application_section_id_seq START WITH 1;
CREATE SEQUENCE user_id_seq START WITH 1;
CREATE SEQUENCE reset_password_id_seq START WITH 1;

CREATE TABLE "user" (
    id bigint DEFAULT nextval('user_id_seq'::regclass) NOT NULL PRIMARY KEY,
    user_name character varying(50) NOT NULL,
    password character varying(50) NOT NULL,
    email character varying(100)
);
CREATE TABLE "opportunity" (
    id bigint DEFAULT nextval('opportunity_id_seq'::regclass) NOT NULL PRIMARY KEY,
    title character varying(255) NOT NULL,
    start_date character varying(255) NOT NULL,
    value numeric(9,2) NOT NULL,
    value_units character varying(255) NOT NULL,
    end_date character varying(255),
    published_at_dtime timestamp with time zone,
    duplicated_from_id bigint
);
CREATE TABLE "application_form" (
    id bigint DEFAULT nextval('applicationform_id_seq'::regclass) NOT NULL PRIMARY KEY,
    opportunity_id bigint NOT NULL
);
CREATE TABLE "section" (
    id bigint DEFAULT nextval('section_id_seq'::regclass) NOT NULL PRIMARY KEY,
    section_number integer NOT NULL,
    opportunity_id bigint NOT NULL,
    title character varying(255) NOT NULL,
    text character varying(8192),
    description character varying(8192) DEFAULT 'no description'::character varying NOT NULL,
    help_text character varying(8192),
    section_type character varying(30) DEFAULT 'text'::character varying NOT NULL
);
CREATE TABLE "paragraph" (
    id bigint NOT NULL PRIMARY KEY,
    paragraph_number integer NOT NULL,
    section_id bigint NOT NULL,
    text character varying(255) NOT NULL
);
CREATE TABLE "messageboard" (
    id bigint DEFAULT nextval('messageboard_id_seq'::regclass) NOT NULL PRIMARY KEY,
    user_id character varying(50) NOT NULL,
    application_id bigint NOT NULL,
    section_number integer,
    sent_by character varying(50),
    sent_at_dtime timestamp with time zone,
    message character varying(500)
);
CREATE TABLE "application_section" (
    id bigint DEFAULT nextval('application_section_id_seq'::regclass) NOT NULL PRIMARY KEY,
    application_id bigint NOT NULL,
    section_number integer NOT NULL,
    answers jsonb NOT NULL,
    completed_at_dt timestamp with time zone
);
CREATE TABLE "application" (
    id bigint DEFAULT nextval('application_id_seq'::regclass) NOT NULL PRIMARY KEY,
    application_form_id bigint NOT NULL,
    personal_reference character varying(255),
    user_id character varying(50) NOT NULL,
    status character varying(30) NOT NULL
);
CREATE TABLE "application_form_question" (
    id bigint DEFAULT nextval('applicationformquestion_id_seq'::regclass) NOT NULL PRIMARY KEY,
    application_form_section_id bigint NOT NULL,
    key character varying(255) NOT NULL,
    text character varying(255) NOT NULL,
    description character varying(4096),
    help_text character varying(4096)
);
CREATE TABLE "application_form_section" (
    id bigint DEFAULT nextval('applicationformsection_id_seq'::regclass) NOT NULL PRIMARY KEY,
    application_form_id bigint NOT NULL,
    section_number integer NOT NULL,
    title character varying(255) NOT NULL,
    fields jsonb DEFAULT '[]'::jsonb NOT NULL,
    section_type character varying(50) DEFAULT 'form'::character varying NOT NULL
);

  CREATE TABLE "reset_password" (
    id bigint DEFAULT nextval('reset_password_id_seq'::regclass) NOT NULL PRIMARY KEY,
    user_id character varying(50) NOT NULL,
    ref_no bigint NOT NULL,
    time_to_lapse timestamp with time zone
);

ALTER TABLE "user" ADD CONSTRAINT user_user_name_key UNIQUE (user_name);
ALTER TABLE "application_section" ADD CONSTRAINT "unique_section_number_per_application" unique (application_id, section_number);
ALTER TABLE "application_form" ADD CONSTRAINT "one_form_per_opportunity" UNIQUE ("id", "opportunity_id");
ALTER TABLE "opportunity" ADD CONSTRAINT "duplicated_opportunity_fk" foreign key("duplicated_from_id") REFERENCES "opportunity"("id") on update NO ACTION on delete CASCADE;
ALTER TABLE "paragraph" ADD CONSTRAINT "paragraph_section_fk" foreign key("section_id") REFERENCES "section"("id") on update NO ACTION on delete CASCADE;
ALTER TABLE "section" ADD CONSTRAINT "section_opportunity_fk" foreign key("opportunity_id") REFERENCES "opportunity"("id") on update NO ACTION on delete CASCADE;
ALTER TABLE "application_form_section" ADD CONSTRAINT "applicationformsection_application_fk" foreign key("application_form_id") REFERENCES "application_form"("id") on update NO ACTION on delete CASCADE;
ALTER TABLE "application_form" add constraint "application_form_opportunity_fk" foreign key("opportunity_id") references "opportunity"("id") on update NO ACTION on delete CASCADE;
ALTER TABLE "application_form_question" ADD CONSTRAINT "applicationformquestion_application_form_section_fk" FOREIGN KEY ("application_form_section_id") REFERENCES "application_form_section" ("id") ON UPDATE NO ACTION ON DELETE CASCADE;

CREATE INDEX application_application_form_idx ON application USING btree (application_form_id);
CREATE INDEX application_form_opportunity_idx ON application_form USING btree (opportunity_id);
CREATE INDEX applicationformquestion_application_form_section_idx ON application_form_question USING btree (application_form_section_id);
CREATE INDEX applicationformsection_application_idx ON application_form_section USING btree (application_form_id);
CREATE INDEX applicationsection_application_idx ON application_section USING btree (application_id);
CREATE INDEX paragraph_section_idx ON paragraph USING btree (section_id);
CREATE INDEX section_opportunity_idx ON section USING btree (opportunity_id);



INSERT INTO opportunity (id, title, start_date, value, value_units, end_date, published_at_dtime, duplicated_from_id) VALUES (1, 'Low Carbon Heating Technology Innovation Fund', '22 November 2017', 2000000.00, 'maximum', NULL, '2016-11-27 16:00:00-08', NULL);
INSERT INTO application_form (id, opportunity_id) VALUES (1, 1);

INSERT INTO application_form_section VALUES (1, 1, 1, 'Proposal Summary', '[{"name": "proposalsummary", "type": "simpleform", "isEnabled": true, "isNumeric": false, "simpleform": [{"name": "proposalsummary.name", "type": "text", "label": "Name of Applicant Business", "maxWords": 200, "fieldType": "text", "isEnabled": true, "isNumeric": false, "isMandatory": true}, {"name": "proposalsummary.title", "type": "text", "label": "Project Title", "maxWords": 200, "fieldType": "text", "isEnabled": true, "isNumeric": false, "isMandatory": true}, {"name": "proposalsummary.startdate", "type": "date", "label": "Estimated Start Date", "maxWords": 100, "fieldType": "date", "isEnabled": true, "isNumeric": true, "isMandatory": true, "minYearValue": 2018}, {"name": "proposalsummary.duration", "type": "text", "label": "Project Duration (months)", "maxValue": 36, "maxWords": 1, "minValue": 1, "fieldType": "text", "isEnabled": true, "isNumeric": true, "isMandatory": true}, {"name": "proposalsummary.costs", "type": "currency", "label": "Total Eligible Project Costs (£)", "maxWords": 10, "fieldType": "currency", "isEnabled": true, "isNumeric": true, "isMandatory": true}, {"name": "proposalsummary.totalcost", "type": "currency", "label": "Total BEIS grant applied for (£) (maximum award is £2 million) ", "maxValue": 2000000, "maxWords": 10, "minValue": 0, "fieldType": "currency", "isEnabled": true, "isNumeric": true, "isMandatory": true}, {"name": "proposalsummary.pvtsectorcontrib", "type": "currency", "label": "Total private sector contribution to Project Costs (£)", "maxWords": 10, "fieldType": "currency", "isEnabled": true, "isNumeric": true, "isMandatory": true}, {"name": "proposalsummary.collaborativeapplication", "type": "dropdown", "label": "Is this a collaborative application?", "maxWords": 10, "fieldType": "dropdown", "isEnabled": true, "isNumeric": false, "isMandatory": true, "defaultvalue": "Yes:Yes,No:No"}]}]', 'simpleform');
INSERT INTO application_form_section VALUES (2, 1, 2, 'Applicant Details - Contact Details', '[{"name": "contactdetails", "type": "simpleform", "isEnabled": true, "isNumeric": false, "simpleform": [{"name": "contactdetails.name", "type": "text", "label": "Name", "maxWords": 100, "fieldType": "text", "isEnabled": true, "isNumeric": false, "isMandatory": true}, {"name": "contactdetails.position", "type": "text", "label": "Position", "maxWords": 100, "fieldType": "text", "isEnabled": true, "isNumeric": false, "isMandatory": true}, {"name": "contactdetails.email", "type": "text", "label": "Email", "maxWords": 100, "fieldType": "text", "isEnabled": true, "isNumeric": false, "isMandatory": true}, {"name": "contactdetails.phone", "type": "tableform", "maxWords": 20, "fieldType": "tableform", "isEnabled": true, "isNumeric": false, "tableform": [{"name": "howfunded.row2", "fields": [{"name": "contactdetails.phone.telephone", "type": "text", "label": "Telephone", "maxWords": 20, "fieldType": "text", "isEnabled": true, "isNumeric": false, "isMandatory": true}, {"name": "contactdetails.phone.mobile", "type": "text", "label": "Mobile", "maxWords": 20, "fieldType": "text", "isEnabled": true, "isNumeric": false, "isMandatory": true}], "isEnabled": true}], "isMandatory": false}, {"name": "contactdetails.organisation", "type": "text", "label": "Organisation Name", "maxWords": 200, "fieldType": "text", "isEnabled": true, "isNumeric": false, "isMandatory": true}, {"name": "contactdetails.address", "type": "address", "label": "Address", "maxWords": 200, "fieldType": "address", "isEnabled": true, "isNumeric": false, "isMandatory": true}, {"name": "contactdetails.businesstype", "type": "dropdown", "label": "Business Type", "maxWords": 100, "fieldType": "dropdown", "isEnabled": true, "isNumeric": false, "isMandatory": true, "defaultvalue": "Chairty:Charity,Coop:Co-Operative,LGT:Limited by Guarantee,LTD:Limited Company,LLP:Limited Liability Partnership,Partnership:Partnership,PLC:PLC,Sole:Sole Trader,EDU:University/Educational,UC:University Company,Other:Other"}, {"name": "contactdetails.otherbuisiness", "type": "text", "label": "If type of business is ‘other’, please describe here:", "maxWords": 100, "fieldType": "text", "isEnabled": true, "isNumeric": false, "isMandatory": false}]}]', 'simpleform');
INSERT INTO application_form_section VALUES (3, 1, 3, 'Applicant Details - Business Details', '[{"name": "businessdetails", "type": "simpleform", "isEnabled": true, "isNumeric": false, "simpleform": [{"name": "businessdetails.employees", "type": "text", "label": "Number of employees (including directors)", "maxWords": 20, "fieldType": "text", "isEnabled": true, "isNumeric": true, "isMandatory": true}, {"name": "businessdetails.regnumber", "type": "text", "label": "Business Registration Number", "maxWords": 100, "fieldType": "text", "isEnabled": true, "isNumeric": false, "isMandatory": false}, {"name": "businessdetails.turnoverlabel", "size": 10, "type": "String", "label": "Turnover (in most recent annual accounts) (£)", "maxWords": 20, "fieldType": "String", "isEnabled": true, "isNumeric": true, "isMandatory": true}, {"name": "businessdetails.turnover", "type": "tableform", "maxWords": 20, "fieldType": "tableform", "isEnabled": true, "isNumeric": false, "tableform": [{"name": "turnover.row1", "fields": [{"name": "businessdetails.turnover.value", "label": "Value", "fieldType": "currency", "isEnabled": true, "isMandatory": true}, {"name": "businessdetails.turnover.asat", "label": "as at", "fieldType": "String", "isEnabled": true}, {"name": "businessdetails.turnover.date", "label": "Date", "fieldType": "date", "isEnabled": true, "isNumeric": true, "isMandatory": false}], "isEnabled": true}], "isMandatory": true}, {"name": "businessdetails.balancesheetlabel", "size": 10, "type": "String", "label": "Balance Sheet Total (total assets net of depreciation) (£)", "maxWords": 20, "fieldType": "String", "isEnabled": true, "isNumeric": false, "isMandatory": true}, {"name": "businessdetails.balancesheet", "type": "tableform", "maxWords": 20, "fieldType": "tableform", "isEnabled": true, "isNumeric": false, "tableform": [{"name": "balancesheet.row1", "fields": [{"name": "businessdetails.balancesheet.value", "label": "Value", "fieldType": "currency", "isEnabled": true, "isMandatory": true}, {"name": "businessdetails.balancesheet.asat", "label": "as at", "fieldType": "String", "isEnabled": true}, {"name": "businessdetails.balancesheet.date", "label": "Date", "fieldType": "date", "isEnabled": true, "isMandatory": false}], "isEnabled": true}], "isMandatory": false}, {"name": "businessdetails.businessmaturity", "type": "dropdown", "label": "Business maturity", "maxWords": 10, "fieldType": "dropdown", "isEnabled": true, "isNumeric": false, "isMandatory": true, "defaultvalue": "Pre:Pre-Startup,Startup:Startup <1yr,Upto5:1-5yrs,Upto10:6-10yrs,MoreThan10:>10yrs"}, {"name": "businessdetails.howfunded", "type": "String", "label": "How is the business currently funded? (Choose all that apply)", "maxWords": 100, "fieldType": "String", "isEnabled": true, "isNumeric": false, "isMandatory": false}, {"name": "businessdetails.howfunded", "type": "tableform", "maxWords": 20, "fieldType": "tableform", "isEnabled": true, "isNumeric": false, "tableform": [{"name": "howfunded.row1", "fields": [{"name": "businessdetails.howfunded.row1col1", "label": "No Funding", "fieldType": "checkbox", "isEnabled": true}, {"name": "businessdetails.howfunded.row1col2", "label": "Founders (including bank loans)", "fieldType": "checkbox", "isEnabled": true}, {"name": "businessdetails.howfunded.row1col3", "label": "Friends and Family", "fieldType": "checkbox", "isEnabled": true}], "isEnabled": true}, {"name": "howfunded.row2", "fields": [{"name": "businessdetails.howfunded.row2col1", "label": "Public Sector Grants", "fieldType": "checkbox", "isEnabled": true}, {"name": "businessdetails.howfunded.row2col2", "label": "Private Investment", "fieldType": "checkbox", "isEnabled": true}, {"name": "businessdetails.howfunded.row2col3", "label": "Stock Market Floatation", "fieldType": "checkbox", "isEnabled": true}], "isEnabled": true}], "isMandatory": true}, {"name": "businessdetails.duration", "type": "textarea", "label": "Please list any public sector support you are recieving or have recieved", "helptext": "With respect to this project or the technology it is based on, please list briefly any public sector support you are receiving or have received in the past 10 years, or which is currently being sought.", "maxWords": 300, "fieldType": "textarea", "isEnabled": true, "isNumeric": false, "isMandatory": false}]}]', 'simpleform');
INSERT INTO application_form_section VALUES (4, 1, 4, 'Applicant Details - Parent Company Details', '[{"name": "parentcompany", "type": "simpleform", "isEnabled": true, "isNumeric": false, "simpleform": [{"name": "parentcompany.check", "label": "Does the business have a parent company? (If ‘no’ please mark page as complete and move to next page.)", "maxWords": 10, "fieldType": "dropdown", "isEnabled": true, "isNumeric": false, "isMandatory": true, "defaultvalue": "Yes:Yes,No:No"}, {"name": "parentcompany.organisationname", "type": "text", "label": "Organisation name", "maxWords": 200, "fieldType": "text", "isEnabled": true, "isNumeric": false, "isMandatory": false}, {"name": "parentcompany.address", "type": "address", "label": "Address", "maxWords": 200, "fieldType": "address", "isEnabled": true, "isNumeric": false, "isMandatory": false}, {"name": "parentcompany.turnoverlabel", "size": 10, "type": "String", "label": "Turnover (in most recent annual accounts)", "maxWords": 20, "fieldType": "String", "isEnabled": true, "isNumeric": false, "isMandatory": false}, {"name": "parentcompany.turnover", "type": "tableform", "maxWords": 20, "fieldType": "tableform", "isEnabled": true, "isNumeric": false, "tableform": [{"name": "parentcompany.turnover.row1", "fields": [{"name": "parentcompany.turnover.value", "label": "Value", "fieldType": "currency", "isEnabled": true, "isMandatory": false}, {"name": "parentcompany.turnover.asat", "label": "as at", "fieldType": "String", "isEnabled": true}, {"name": "parentcompany.turnover.date", "label": "Date", "fieldType": "date", "isEnabled": true}], "isEnabled": true}], "isMandatory": false}, {"name": "parentcompany.balancesheetlabel", "size": 10, "type": "String", "label": "Balance Sheet Total (total assets net of depreciation)", "maxWords": 20, "fieldType": "String", "isEnabled": true, "isNumeric": false, "isMandatory": false}, {"name": "parentcompany.balancesheet", "type": "tableform", "maxWords": 20, "fieldType": "tableform", "isEnabled": true, "isNumeric": false, "tableform": [{"name": "parentcompany.balancesheet.row1", "fields": [{"name": "parentcompany.balancesheet.value", "label": "Value", "fieldType": "currency", "isEnabled": true, "isMandatory": false}, {"name": "parentcompany.balancesheet.asat", "label": "as at", "fieldType": "String", "isEnabled": true}, {"name": "parentcompany.balancesheet.date", "label": "Date", "fieldType": "date", "isEnabled": true}], "isEnabled": true}], "isMandatory": false}, {"name": "parentcompany.businessmaturity", "type": "dropdown", "label": "Business maturity", "maxWords": 100, "fieldType": "dropdown", "isEnabled": true, "isNumeric": false, "isMandatory": false, "defaultvalue": "Pre:Pre-Startup,Startup:Startup <1yr,Upto5:1-5yrs,Upto10:6-10yrs,MoreThan10:>10yrs"}]}]', 'simpleform');
INSERT INTO application_form_section VALUES (5, 1, 5, 'Eligibility Criteria - Technology Scope', '[{"name": "techscope", "type": "simpleform", "isEnabled": true, "isNumeric": false, "simpleform": [{"name": "techscope.proposaltype", "type": "dropdown", "label": "Is this a proposal for a technology, a tool or process?", "maxWords": 20, "fieldType": "dropdown", "isEnabled": true, "isNumeric": false, "isMandatory": true, "defaultvalue": "Technology:Technology,Tool:Tool,Process:Process"}, {"name": "techscope.whhichtechnology", "type": "dropdown", "label": "To which technology family does this innovation belong?", "maxWords": 10, "fieldType": "dropdown", "isEnabled": true, "isNumeric": false, "isMandatory": true, "defaultvalue": "Gas:Gas,Electrict:Electric,Hybrid:Hybrid,Solar:Solar,Other:Other"}, {"name": "techscope.othertech", "type": "text", "label": "If other please describe:", "maxWords": 10, "fieldType": "text", "isEnabled": true, "isNumeric": false, "isMandatory": false}, {"name": "techscope.whatisinnovation", "label": "Will your innovation provide, or help to provide, low carbon heating systems in existing buildings", "maxWords": 100, "fieldType": "dropdown", "isEnabled": true, "isNumeric": false, "isMandatory": true, "defaultvalue": "Yes:Yes,No:No"}, {"name": "techscope.spf", "type": "text", "label": "If your innovation is a heat pump system, or impacts on the performance of a heat pump system, what SPFH4 is achieved in-situ?", "maxWords": 200, "fieldType": "text", "isEnabled": true, "isNumeric": false, "isMandatory": false}, {"name": "techscope.qtyofco2", "type": "text", "label": "Quantify the CO2 emissions associated with the provision of 1kWh of useful heat using your innovation / a system supported by your innovation", "maxWords": 10, "fieldType": "text", "isEnabled": true, "isNumeric": false, "isMandatory": false}, {"name": "techscope.commerciallydeployed", "label": "Is this technology already commercially deployed?", "helptext": "To the best of your knowledge, is this innovation already commercially deployed in the UK or elsewhere?", "maxWords": 10, "fieldType": "dropdown", "isEnabled": true, "isNumeric": false, "isMandatory": true, "defaultvalue": "Yes:Yes,No:No"}, {"name": "techscope.undeployment", "type": "text", "label": "If yes, please describe the extent of commercial deployment.", "maxWords": 100, "fieldType": "text", "isEnabled": true, "isNumeric": false, "isMandatory": false}]}]', 'simpleform');
INSERT INTO application_form_section VALUES (6, 1, 6, 'Eligibility Criteria - Technology Readiness Level (TRL)', '[{"name": "trl", "type": "simpleform", "isEnabled": true, "isNumeric": false, "simpleform": [{"name": "trl.techreadiness", "type": "text", "label": "The current TRL of the overall heating system in which the inovation is to be used.", "maxWords": 100, "fieldType": "text", "isEnabled": true, "isNumeric": true, "isMandatory": true}, {"name": "trl.currenttechnology", "type": "text", "label": "The current TRL of your innovation.", "maxWords": 100, "fieldType": "text", "isEnabled": true, "isNumeric": true, "isMandatory": true}, {"name": "trl.justification", "type": "textarea", "label": "Please justify the current TRL of your innovation by explaining what has been done to date  (300 words)", "maxWords": 300, "fieldType": "textarea", "isEnabled": true, "isNumeric": false, "isMandatory": true}, {"name": "trl.progresstechreadiness", "type": "text", "label": "The expected TRL of your innovation to be achieved by the end of the project.", "maxWords": 100, "fieldType": "text", "isEnabled": true, "isNumeric": true, "isMandatory": true}]}]', 'simpleform');
INSERT INTO application_form_section VALUES (7, 1, 7, 'Eligibility Criteria - Project Activity', '[{"name": "activity", "type": "simpleform", "isEnabled": true, "isNumeric": false, "simpleform": [{"name": "activity.randdcategory", "type": "dropdown", "label": "What is the main research, development and innovation category applicable to your project?", "maxWords": 10, "fieldType": "dropdown", "isEnabled": true, "isNumeric": false, "isMandatory": false, "defaultvalue": "ExpDevSingle:Experimental development - single company,ExpDevCollab:Experimental development - collaboration,IndResSingle:Industrial research - single company,IndResCollab:Industrial research - collaboration"}]}]', 'simpleform');
INSERT INTO application_form_section VALUES (8, 1, 8, 'Eligibility Criteria - Project Status', '[{"name": "status", "type": "simpleform", "isEnabled": true, "isNumeric": false, "simpleform": [{"name": "status.projectstatus", "label": "Please tick to confirm that the Low Carbon Heating Technology Innovation Fund will not be used to fund retrospective work.", "maxWords": 100, "fieldType": "checkbox", "isEnabled": true, "isNumeric": false, "isMandatory": true}]}]', 'simpleform');
INSERT INTO application_form_section VALUES (9, 1, 9, 'Eligibility Criteria - Grant Size ', '[{"name": "gsize", "type": "simpleform", "isEnabled": true, "isNumeric": false, "simpleform": [{"name": "gsize.grantfundingforIR", "type": "text", "label": "Maximum grant funding requested for Industrial Research project activity (£)", "maxWords": 10, "fieldType": "currency", "isEnabled": true, "isNumeric": true, "isMandatory": true}, {"name": "gsize.grantfundingforED", "type": "text", "label": "Maximum grant funding requested for Experimental Development project activity (£)", "maxWords": 10, "fieldType": "currency", "isEnabled": true, "isNumeric": true, "isMandatory": true}, {"name": "gsize.grantfundingtotal", "type": "text", "label": "Maximum total grant funding requested (£)", "maxWords": 10, "fieldType": "currency", "isEnabled": true, "isNumeric": true, "isMandatory": true}]}]', 'simpleform');
INSERT INTO application_form_section VALUES (10, 1, 10, 'Eligibility Criteria - Grant Intensity', '[{"name": "grantintensity", "type": "dynamictableform", "isEnabled": true, "isNumeric": false, "dynamictableform": [{"name": "grantintensity.row1", "fields": [{"name": "grantintensity.row1.col1", "label": "Name of partner organisation", "fieldType": "text", "isEnabled": true}, {"name": "grantintensity.row1.col2", "label": "Size and type of partner", "fieldType": "text", "isEnabled": true, "isNumeric": true}, {"name": "grantintensity.row1.col3", "label": "Partner’s eligible project costs (in £)", "fieldType": "currency", "isEnabled": true, "isNumeric": true}, {"name": "grantintensity.row1.col4", "label": "Partner’s \n project costs as a proportion of the total eligible project costs (%)", "fieldType": "text", "isEnabled": true, "isNumeric": true}, {"name": "grantintensity.row1.col5", "label": "Partner’s grant funding request from BEIS (in £)", "fieldType": "currency", "isEnabled": true, "isNumeric": true}, {"name": "grantintensity.row1.col6", "label": "Partner’s grant funding request as a proportion of their eligible project costs (%)", "fieldType": "text", "isEnabled": true, "isNumeric": true}], "isEnabled": true}]}]', 'dynamictableform');
INSERT INTO application_form_section VALUES (11, 1, 11, 'Eligibility Criteria - Project Location', '[{"name": "loc", "type": "simpleform", "isEnabled": true, "isNumeric": false, "simpleform": [{"name": "loc.UK", "label": "Will all activities supported by the Low Carbon Heating Technology Innovation Fund be largely conducted in the UK?", "maxWords": 100, "fieldType": "dropdown", "isEnabled": true, "isNumeric": false, "isMandatory": true, "defaultvalue": "Yes:Yes,No:No"}, {"name": "loc.NOTUK", "label": "If no, please provide an estimate of the total project costs to be delivered outside of the UK (£)", "maxWords": 100, "fieldType": "currency", "isEnabled": true, "isNumeric": true, "isMandatory": false}]}]', 'simpleform');
INSERT INTO application_form_section VALUES (12, 1, 12, 'Eligibility Criteria - Project Duration', '[{"name": "eligibility", "type": "simpleform", "isEnabled": true, "isNumeric": false, "simpleform": [{"name": "eligibility.startdate", "type": "date", "label": "Estimated Start Date", "maxWords": 100, "fieldType": "date", "isEnabled": true, "isNumeric": true, "isMandatory": true}, {"name": "eligibility.duration", "type": "text", "label": "Project Duration (months)", "maxWords": 100, "fieldType": "text", "isEnabled": true, "isNumeric": true, "isMandatory": true}, {"name": "eligibility.enddate", "label": "Please tick to confirm that the project will be completed by 31/03/2021", "maxWords": 100, "fieldType": "checkbox", "isEnabled": true, "isNumeric": false, "isMandatory": true}]}]', 'simpleform');
INSERT INTO application_form_section VALUES (13, 1, 13, 'Eligibility Criteria - General Conditions', '[{"name": "eligibilitycriteria", "type": "simpleform", "isEnabled": true, "isNumeric": false, "simpleform": [{"name": "eligibilitycriteria.message", "label": "Please confirm that you have read Appendix 3 of the Guidance Notes. If you cannot answer ‘no’ to every question you should contact BEIS at BuiltEnvironmentInnovation@beis.gov.uk before continuing with your application.", "maxWords": 100, "fieldType": "checkbox", "isEnabled": true, "isNumeric": false, "isMandatory": true}]}]', 'simpleform');
INSERT INTO application_form_section VALUES (14, 1, 14, 'Public Description of the Project', '[{"name": "applicationcriteria", "type": "simpleform", "isEnabled": true, "isNumeric": false, "simpleform": [{"name": "applicationcriteria.marketpotential", "type": "textarea", "label": "Please give a public description of the project (max 250 words)", "helptext": "The public description of the project should be a brief non-confidential description of the project that BEIS may use in online or printed publications. Please describe the project objectives and key deliverables and the expected project benefits", "maxWords": 250, "fieldType": "textarea", "isEnabled": true, "isNumeric": false, "isMandatory": true}]}]', 'simpleform');
INSERT INTO application_form_section VALUES (15, 1, 15, 'Assessment Criteria - Full Project Description', '[{"name": "assessment", "type": "simpleform", "isEnabled": true, "isNumeric": false, "simpleform": [{"name": "assessment.fulldescription", "type": "textarea", "label": "Please provide a full project description (max 750 words)", "helptext": "The full project description should provide a  more thorough technical description of the project to be used by BEIS to assess the application.", "maxWords": 750, "fieldType": "textarea", "isEnabled": true, "isNumeric": false, "isMandatory": true}]}]', 'simpleform');
INSERT INTO application_form_section VALUES (16, 1, 16, 'Assessment Criteria - Cost Metrics Table', '[{"name": "costmetrics", "type": "simpleform", "isEnabled": true, "isNumeric": false, "simpleform": [{"name": "costmetrics.table", "type": "tableform", "maxWords": 20, "fieldType": "tableform", "isEnabled": true, "isNumeric": false, "tableform": [{"name": "costmetrics.table.row1", "fields": [{"name": "costmetrics.table.row1col1", "label": "Cost element", "fieldType": "String", "isEnabled": true}, {"name": "costmetrics.table.row1col2", "label": "Current costs of low carbon heating system", "fieldType": "String", "isEnabled": true}, {"name": "costmetrics.table.row1col3", "label": "Estimated costs 5 years from now as a result of your innovation activity", "fieldType": "String", "isEnabled": true}], "isEnabled": true}, {"name": "costmetrics.table.row2", "fields": [{"name": "costmetrics.table.row2col1", "label": "Capital costs", "fieldType": "String", "isEnabled": true}, {"name": "costmetrics.table.row2col2", "label": "", "fieldType": "currency", "isEnabled": true, "isMandatory": false}, {"name": "costmetrics.table.row2col3", "label": "", "fieldType": "currency", "isEnabled": true, "isMandatory": false}], "isEnabled": true}, {"name": "costmetrics.table.row3", "fields": [{"name": "costmetrics.table.row3col1", "label": "Installation costs", "fieldType": "String", "isEnabled": true}, {"name": "costmetrics.table.row3col2", "label": "", "fieldType": "currency", "isEnabled": true, "isMandatory": false}, {"name": "costmetrics.table.row3col3", "label": "", "fieldType": "currency", "isEnabled": true, "isMandatory": false}], "isEnabled": true}, {"name": "costmetrics.table.row4", "fields": [{"name": "costmetrics.table.row4col1", "label": " Annual operating costs", "fieldType": "String", "isEnabled": true}, {"name": "costmetrics.table.row4col2", "label": "", "fieldType": "currency", "isEnabled": true, "isMandatory": false}, {"name": "costmetrics.table.row4col3", "label": "", "fieldType": "currency", "isEnabled": true, "isMandatory": false}], "isEnabled": true}, {"name": "costmetrics.table.row5", "fields": [{"name": "costmetrics.table.row5col1", "label": "Annual maintenance costs ", "fieldType": "String", "isEnabled": true}, {"name": "costmetrics.table.row5col2", "label": "", "fieldType": "currency", "isEnabled": true, "isMandatory": false}, {"name": "costmetrics.table.row5col3", "label": "", "fieldType": "currency", "isEnabled": true, "isMandatory": false}], "isEnabled": true}, {"name": "costmetrics.table.row6", "fields": [{"name": "costmetrics.table.row6col1", "label": "Life expectancy (years)", "fieldType": "String", "isEnabled": true}, {"name": "costmetrics.table.row6col2", "label": "", "fieldType": "text", "isEnabled": true, "isNumeric": true, "isMandatory": false}, {"name": "costmetrics.table.row6col3", "label": "", "fieldType": "text", "isEnabled": true, "isNumeric": false, "isMandatory": false}], "isEnabled": true}]}, {"name": "costmetrics.marketpotential", "type": "textarea", "label": "How will this innovation reduce the upfront/lifetime costs of low carbon heating technology systems? \n\nPlease provide evidence for the current and expected costs provided in the table (max 500 words).", "helptext": "Please provide details of the current costs associated with installing and running a heating system of this type (if applicable), and how costs are expected to change as a result of innovation. Include the following:\n\n-  Capital costs\n\n-  Installation costs\n\n-  Operating costs\n\n-  Maintenance Costs\n\n-  Life Expectancy\n\n", "maxWords": 500, "fieldType": "textarea", "isEnabled": true, "isNumeric": false, "isMandatory": true}]}]', 'simpleform');
INSERT INTO application_form_section VALUES (17, 1, 17, 'Assessment Criteria - Performance Metrics', '[{"name": "metrics", "type": "simpleform", "isEnabled": true, "isNumeric": false, "simpleform": [{"name": "metrics.performanceimprovement", "type": "textarea", "label": "How will this innovation provide better performing low carbon heating systems than those currently on the market (max 500 words)?", "helptext": "You should consider:\n\n-  How performance metrics will be calculated\n\n-  Current and anticipated performance parameters e.g. SPFH4\n\n-  Energy Demand\n\n-  Peak load factors\n\n-  Consumer experience\n\nPlease provide explanation and supporting evidence.", "maxWords": 500, "fieldType": "textarea", "isEnabled": true, "isNumeric": false, "isMandatory": true}, {"name": "metrics.performancemonitoring", "type": "textarea", "label": "Please describe how the performance of your product will be monitored, in situ, throughout the lifetime of the product (max 250 words) ", "maxWords": 250, "fieldType": "textarea", "isEnabled": true, "isNumeric": false, "isMandatory": true}, {"name": "metrics.performanceintegration", "type": "textarea", "label": "How does the innovation integrate into the overall heating system (max 250 words)?", "helptext": "Please address the following:\n\n-  The type or types of heating system the innovation you are proposing might apply to and the types of buildings this system could be installed in \n\n-  Integration with/of other low carbon heating technologies\n\n-  Integration with the wider energy system ", "maxWords": 250, "fieldType": "textarea", "isEnabled": true, "isNumeric": false, "isMandatory": true}]}]', 'simpleform');
INSERT INTO application_form_section VALUES (18, 1, 18, 'Assessment Criteria - Market Potential', '[{"name": "pot", "type": "simpleform", "isEnabled": true, "isNumeric": false, "simpleform": [{"name": "pot.marketpotential", "type": "textarea", "label": "What is the market potential for your innovation both in the UK and internationally (max 500 words)?", "helptext": "Please describe:\n\n-  The size and nature of the market opportunities\n\n-  The proposed exploitation route and timescales to market  \n\n-  How value is expected to be generated from the innovation\n\n-  Any further technology development needed to secure sales", "maxWords": 500, "fieldType": "textarea", "isEnabled": true, "isNumeric": false, "isMandatory": true}]}]', 'simpleform');
INSERT INTO application_form_section VALUES (19, 1, 19, 'Assessment Criteria - Project Delivery', '[{"name": "projectdelivery", "type": "simpleform", "isEnabled": true, "isNumeric": false, "simpleform": [{"name": "projectdelivery.skills", "type": "textarea", "label": "Please provide details of the relevant skills, qualifications and experience of the project team (max 1000 words).", "helptext": "Please include descriptions and evidence of previous relevant work carried out, including the date, location, client and project size. ''CV''s for the project team can be uploaded in Section 6 of this application form", "maxWords": 1000, "fieldType": "textarea", "isEnabled": true, "isNumeric": false, "isMandatory": true}, {"name": "projectdelivery.consortium", "type": "textarea", "label": "If the project is being delivered as part of consortium please outline below the key roles for each partner and the proposed governance arrangements to ensure effective project delivery (max 500 words).", "maxWords": 500, "fieldType": "textarea", "isEnabled": true, "isNumeric": false, "isMandatory": false}, {"name": "projectdelivery.listexternalparty", "type": "textarea", "label": "If any external party is responsible for delivering goods or services worth more than 10% of the total project value please explain how you will ensure delays will be prevented (max 500 words).", "maxWords": 500, "fieldType": "textarea", "isEnabled": true, "isNumeric": false, "isMandatory": false}]}]', 'simpleform');
INSERT INTO application_form_section VALUES (20, 1, 20, 'Assessment Criteria - Project Delivery: Gantt Chart', '[{"name": "ganttchart", "type": "fileUpload", "label": "Please upload a high level Gantt chart or outline project plan listing the key tasks and timescales for the proposed project. The upload should be a pdf or excel file.", "helptext": "Please upload a high level Gantt chart or outline project plan listing the key tasks and timescales for the proposed project. The upload should be a pdf or excel file.", "maxWords": 500, "isEnabled": true, "isMandatory": true, "downloadfile": ""}]', 'file');
INSERT INTO application_form_section VALUES (21, 1, 21, 'Assessment Criteria - Project Delivery: Milestones', '[{"name": "thermalefficiency", "type": "dynamictableform", "isEnabled": true, "isNumeric": false, "dynamictableform": [{"name": "thermalefficiency.row1", "fields": [{"name": "thermalefficiency.row1col1", "label": "Milestone number", "fieldType": "text", "isEnabled": true, "isNumeric": true}, {"name": "thermalefficiency.row1col2", "label": "Milestone name", "fieldType": "text", "isEnabled": true, "isNumeric": false}, {"name": "thermalefficiency.row1col3", "label": "Project lead for milestone delivery", "fieldType": "text", "isEnabled": true}, {"name": "thermalefficiency.row1col4", "label": "Brief description of milestone, including deliverables", "fieldType": "textarea", "isEnabled": true}], "isEnabled": true}]}]', 'dynamictableform');
INSERT INTO application_form_section VALUES (22, 1, 22, 'Assessment Criteria - Project Delivery: Risks and Risk Management', '[{"name": "riskmanagement", "type": "dynamictableform", "isEnabled": true, "isNumeric": false, "dynamictableform": [{"name": "riskmanagement.row1", "fields": [{"name": "riskmanagement.row1col1", "label": "Risk (Identify and describe all key project risks, including: financial, technology, supply chain, regulatory, etc)", "helptext": "Risk (Identify and describe all key project risks, including: financial, technology, supply chain, regulatory, etc)", "fieldType": "textarea", "isEnabled": true}, {"name": "riskmanagement.row1col2", "label": "Overall risk rating: (Probability x Impact) High, Medium or Low ", "fieldType": "text", "isEnabled": true}, {"name": "riskmanagement.row1col3", "label": "Mitigation actions (Describe the actions taken or planned responses to reduce the impact and/or probability of the risk)", "fieldType": "textarea", "isEnabled": true}], "isEnabled": true}]}]', 'dynamictableform');
INSERT INTO application_form_section VALUES (23, 1, 23, 'Assessment Criteria - Project Financing', '[{"name": "projectfinancing", "type": "fileUpload", "helptext": "Please download, complete and upload the Finance Form ", "maxWords": 500, "isEnabled": true, "isMandatory": true, "downloadfile": "Project_Financing_Form.xlsx"}]', 'file');
INSERT INTO application_form_section VALUES (24, 1, 24, 'Assessment Criteria - Project Financing: Additionality', '[{"name": "projectfinancingjustification", "type": "simpleform", "isEnabled": true, "isNumeric": false, "simpleform": [{"name": "projectfinancingjustification.value", "type": "textarea", "label": "Please explain why public sector funding is required to take this innovation forward (max 1000 words)?", "maxWords": 1000, "fieldType": "textarea", "isEnabled": true, "isNumeric": false, "isMandatory": true}]}]', 'simpleform');
INSERT INTO application_form_section VALUES (25, 1, 25, 'Assessment Criteria - Wider Objectives', '[{"name": "wider", "type": "simpleform", "isEnabled": true, "isNumeric": false, "simpleform": [{"name": "wider.marketpotential", "type": "textarea", "label": "How does the innovation contribute to the wider objectives of this Low Carbon Heating Technology Innovation Fund (max 1000 words)?", "helptext": "You may wish to address the following:\n\n-  Fuel poverty\n\n-  Consumer acceptance and the improving the attractiveness of low carbon heating technologies\n\n-  Supply chain strengthening\n\n-  Peaking (particularly impacts on peak electricity demand)\n\n-  Demand management \n\n-  Off-gas grid decarbonisation \n\n-  Avoidance of unintended consequences associated with the retrofit of low carbon heating systems into existing buildings\n\n Please provide explanation and supporting evidence for the benefits claimed.", "maxWords": 1000, "fieldType": "textarea", "isEnabled": true, "isNumeric": false, "isMandatory": true}]}]', 'simpleform');
INSERT INTO application_form_section VALUES (26, 1, 26, 'CVs and Supporting Documents', '[{"name": "supportingDocuments", "type": "fileUpload", "helptext": "Please upload CVs and other supporting documents.", "maxWords": 500, "isEnabled": true, "isMandatory": true, "downloadfile": ""}]', 'file');
INSERT INTO application_form_section VALUES (27, 1, 27, 'Any Partner Organisations', '[{"name": "partnerorganisations", "type": "fileUpload", "label": "If you are making this application with any partner organisation(s), please download the file below, fill it in and upload using the add files link. Upload a separate file for each partner organisation.", "helptext": "Please download the file below, fill it in and upload using the add files link. Upload separate file for each partner organisation", "maxWords": 500, "isEnabled": true, "isMandatory": true, "downloadfile": "Partner_Organisations_Details.docx"}]', 'file');
INSERT INTO application_form_section VALUES (28, 1, 28, 'Submission Confirmation', '[{"name": "submissionconfirmation", "type": "simpleform", "isEnabled": true, "isNumeric": false, "simpleform": [{"name": "submissionconfirmation.message", "label": "By ticking this box you are confirming that the lead applicant business, as well as any project partners, are aware and approve of this application", "maxWords": 100, "fieldType": "checkbox", "isEnabled": true, "isNumeric": false, "isMandatory": true}, {"name": "submissionconfirmation.name", "type": "text", "label": "Full name of person submitting application", "maxWords": 200, "fieldType": "text", "isEnabled": true, "isNumeric": false, "isMandatory": true}]}]', 'simpleform');


INSERT INTO section VALUES (1, 1, 1, 'About this opportunity', 'The objective of the Low Carbon Heating Technology Innovation Fund is to support, through capital grants provided by the Department for Business, Energy and Industrial Strategy (BEIS), the development and demonstration of innovative technologies and processes for producing better ways of providing low carbon heat in existing buildings


The Innovation Fund will consider proposals for low carbon heating systems which provide space and/or water heating in any type of existing UK building. The innovation could be a technology, or a process (a way of combining technologies to deliver better low carbon heating), or a tool (e.g. software and/or hardware to reduce the complexity of installation), or some combination of these.

Funding Type: Grant

Application Launch Date: 10th October 2017

Application Closing Date:  5pm, 2nd January 2018

Grant Size: £200,000 to £2 million 

Project Length: To be completed within 3 years 


Before starting an application please read the detailed Guidance Notes. If you have read the Guidance Notes and still have questions, you may address queries to the following email address: BuiltEnvironmentInnovation@beis.gov.uk. 

', 'no description', NULL, 'text');

INSERT INTO section VALUES (2, 2, 1, 'Key eligibility criteria', 'The lead applicant should complete and submit the application form. Only one proposal per applicant may be submitted.   

As a lead applicant:

 • you are responsible for collecting the information for your funding application

 • you are responsible for supplying information pertaining to any collaborators 

 • your organisation will lead the project if your application is successful


Projects will only be considered provided: 

•	the innovation has the potential to produce better ways of providing low carbon heat in existing buildings

•	the innovation is a technology, process or tool 

•	the current TRL of the innovation is a minimum of 6

•	the project proposal meets the definition of Industrial Research or Experimental Development (EU GBER Section 4, Article 25)

•	funding will not be used for retrospective project work

•	the need for public sector funding is evidenced

•	requested funding is between £200k and £2 million 

•	applicants secure private funding to cover the balance of eligible costs

•	project activities are largely conducted in the UK

•	projects are completed within 3 years of the grant award 

•	applicants must be financially viable


Projects that will not be considered include: 

•	innovations around biomass systems

•	innovations around heat networks

•	activities to support deployment which are not innovative

For detailed guidance please read the Guidance Notes.
', 'no description', NULL, 'text');

INSERT INTO section VALUES (3, 3, 1, 'About this form', 'Applicants are required to provide: 

•	a short public description of the project (not assessed)

•	a full project description 

•	detailed cost data to demonstrate how the innovation will reduce the upfront and lifetime costs of delivering low carbon heating

•	detailed performance metrics including how the innovation will impact on current and anticipated performance parameters, energy demand, peak load factors, and consumer experience

•	evidence of the market potential with consideration of size and scale assuming successful deployment

•	a credible approach to project delivery

•	detailed project financing 

•	an explanation of how the project meets the wider objectives of the Innovation Fund


Projects must score a minimum total score of 60% to be considered for funding. For detailed guidance please read the Guidance Notes.', 'no description', NULL, 'text');

