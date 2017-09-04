# --- !Ups

CREATE SEQUENCE opportunity_id_seq START WITH 1;
CREATE SEQUENCE section_id_seq START WITH 1;
CREATE SEQUENCE applicationform_id_seq START WITH 1;
CREATE SEQUENCE applicationformsection_id_seq START WITH 1;
CREATE SEQUENCE applicationformquestion_id_seq START WITH 1;
CREATE SEQUENCE messageboard_id_seq START WITH 1;
CREATE SEQUENCE application_id_seq START WITH 1;
CREATE SEQUENCE application_section_id_seq START WITH 1;
CREATE SEQUENCE user_id_seq START WITH 1;

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

		


# --- !Downs

DROP TABLE "application_form_section";
DROP TABLE "application_form_question";
DROP TABLE "application_section";
DROP TABLE "application";
DROP TABLE "messageboard";
DROP TABLE "paragraph";
DROP TABLE "section";
DROP TABLE "application_form";
DROP TABLE "opportunity";
DROP TABLE "user";

DROP SEQUENCE “opportunity_id_seq”;
DROP SEQUENCE “applicationform_id_seq”;
DROP SEQUENCE “user_id_seq”;
DROP SEQUENCE “section_id_seq”;
DROP SEQUENCE “messageboard_id_seq”;
DROP SEQUENCE “application_section_id_seq”;
DROP SEQUENCE “application_id_seq”;
DROP SEQUENCE “applicationformquestion_id_seq”;
DROP SEQUENCE “applicationformsection_id_seq”;
