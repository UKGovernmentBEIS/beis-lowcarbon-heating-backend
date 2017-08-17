# --- !Ups

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



# --- !Downs

update "application_form_question" set fields = '[]';
update "application_form_section" set fields = '[]';