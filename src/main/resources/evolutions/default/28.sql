# --- !Ups
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


# -- !Downs

drop table "opportunity";
drop table "application_form";
drop table "section";
drop table "application_form_section";
drop table "application_form_question";