# --- !Ups

CREATE SEQUENCE user_id_seq START WITH 1;

CREATE TABLE "user" (    
    id bigint DEFAULT nextval('user_id_seq'::regclass) NOT NULL,
    user_name character varying(50) NOT NULL,
    password character varying(50) NOT NULL,
    email character varying(100)
);


# --- !Downs

DROP TABLE user;
ALTER TABLE "user" ALTER column "id" SET DEFAULT null;
drop sequence "user_id_seq";
delete from user where id > 1;
