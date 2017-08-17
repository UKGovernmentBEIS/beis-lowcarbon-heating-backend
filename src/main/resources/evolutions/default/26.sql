# --- !Ups

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

# --- !Downs

update "application_form_section" set "fields" = '[]' where "section_number" = 3;
UPDATE "opportunity" set "title" = null;
UPDATE "section" set "text" = null;
