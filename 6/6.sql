---APP
--TASK6

-----------Мед персонал
drop table if exists Doctors cascade ;
    drop table if exists room,Patients,links_Doctors_patients,Hurt,emergency cascade ;
create table Doctors(
    serial_doctor_key serial  not null unique  ,
    first_name varchar(80)  not null unique ,
    last_name varchar(80) not null unique  ,
    specialty varchar(80) not null unique ,
    primary key(serial_doctor_key,first_name,last_name)
);

insert into Doctors( first_name,last_name, specialty)
values ('Ivanov','Ivan','therapist'),
       ('Pushnoi','Artem','cardiologist'),
       ('Ulyanova','Maria','hematologist'),
       ('Smolnikov','Arseniy','surgeon'),
       ('Sergeev','Sergey','traumatologist'),
       ('Reshetnikov','Vadim','ophthalmologist');

-----Doctor's rooms------------------------------
create table room(
    id_room serial ,
    id_doctor serial,
    primary key (id_room,id_doctor),
   foreign key (id_doctor)  references Doctors (serial_doctor_key)
);

insert into room(id_room,id_doctor)
values (100,1),
       (102,2),
       (103,3),
       (104,4),
       (105,5),
       (106,6);
------------------Список пациентов----------------------------------
drop table if exists patients;

create table Patients(
    serial_key serial not null unique ,
    first_name varchar(80) not null ,
    last_name varchar(80) not null ,
    born_data date,
    primary key(serial_key,first_name,last_name)
);

insert into Patients(first_name,last_name,born_data)
values ('Georgiy','Ivanov','2015/2/1'),
       ('Semen','Petrov','2015/2/1');

-------------Links Doctors to patients-------------
create table links_Doctors_patients(
    id_doctor serial ,
    id_patients serial ,
    recording_time date,
    primary key (id_patients,id_doctor,recording_time),
    foreign key (id_doctor) references Doctors (serial_doctor_key),
    foreign key (id_patients) references Patients (serial_key)
);

-------Что лечит
-- create table Hurt (
--     speciality varchar(80),
--     part_of_the_body varchar(80),
--     primary key (speciality,part_of_the_body),
--     foreign key (speciality) references Doctors (specialty)
-- );
--
-- insert into Hurt(speciality, part_of_the_body)
-- values ('therapist','general'),
--        ('cardiologist','сердце'),
--        ('hematologist','blood'),
--        ('surgeon','operation'),
--        ('traumatologist','injury'),
--        ('ophthalmologist','глаза');


-----Экстренная помощь------------
drop table if exists emergency;
create table emergency(
    id_doctor serial,
    address varchar(80),
    primary key (id_doctor,address)
);

---------results_analysis----------
drop table if exists results_analysis_cardiologist,results_analysis_hematologist,results_analysis_surgeon,results_analysis_traumatologist,results_analysis_ophthalmologist;
drop table if exists results_analysis_cardiologist;
create table results_analysis_cardiologist(
    id_patients_cardiologist INT not null ,
    id_doctors_cardiologist int,
    interval_PQ int,
    interval_QRS int,
    interval_QT int,
    primary key (id_patients_cardiologist),
    foreign key (id_patients_cardiologist) references Patients(serial_key),
    foreign key (id_doctors_cardiologist) references Doctors(serial_doctor_key)
);
---------------------------------------------------
drop table if exists results_analysis_hematologist;
create table results_analysis_hematologist(
    id_patients_hematologist int not null ,
    id_doctors_hematologist int,
    WBC float,
    RBC float,
    HBC float,
    primary key (id_patients_hematologist),
    foreign key (id_patients_hematologist) references Patients(serial_key),
     foreign key (id_doctors_hematologist) references Doctors(serial_doctor_key)
);
-------------------------------------------------
drop table if exists results_analysis_surgeon;
create table results_analysis_surgeon(
    id_patients_surgeon INT not null ,
    id_doctors_surgeon int,
    pathology varchar(80),
    general_state varchar,
    primary key (id_patients_surgeon),
    foreign key (id_patients_surgeon) references Patients(serial_key),
    foreign key (id_doctors_surgeon) references Doctors(serial_doctor_key)
);
----------------------------------------------
drop table if exists results_analysis_traumatologist;
create table results_analysis_traumatologist(
    id_patients_traumatologist INT not null ,
    id_doctors_traumatologist int,
    fractures varchar(80),
    commit varchar(80),
    primary key (id_patients_traumatologist),
    foreign key (id_patients_traumatologist) references Patients(serial_key),
     foreign key (id_doctors_traumatologist) references Doctors(serial_doctor_key)
);
------------------------------------------------
drop table if exists results_analysis_ophthalmologist;
create table results_analysis_ophthalmologist(
    id_patients_ophthalmologist INT not null ,
    id_doctors_ophthalmologist int,
    refractomitry varchar(80),
    hrustalik varchar(80),
    primary key (id_patients_ophthalmologist),
    foreign key (id_patients_ophthalmologist) references Patients(serial_key),
    foreign key (id_doctors_ophthalmologist) references Doctors(serial_doctor_key)
);
----------------------------EMERGENCY_CALL---------------------------------------------------

DROP FUNCTION IF EXISTS insert_new_emrgency_call(address varchar(80));

CREATE OR REPLACE FUNCTION insert_new_emrgency_call(new_address varchar(80)) RETURNS varchar  AS
$$
BEGIN
    insert into emergency(address)
    values (new_address);
    return 'Скорая уже выехала.';
end$$
LANGUAGE plpgsql;

-----------------ДОБАВЛЕНИЕ НОВОГО ПАЦИЕНТА--------------------------------------
DROP FUNCTION IF EXISTS insert_new_patients(first_n varchar(80) , last_n varchar(80),doctor_id int);

CREATE OR REPLACE FUNCTION insert_new_patients(first_n varchar(80) , last_n varchar(80),doctor_id int,data_born date) RETURNS varchar  AS
$$
declare
    id_pat Patients%ROWTYPE;
    ID_DOC Doctors%ROWTYPE;
BEGIN
    select serial_doctor_key from Doctors where serial_doctor_key= doctor_id into ID_DOC;
    insert into patients(first_name,last_name,born_data)
    values (first_n,last_n,data_born);
    select serial_key from patients where first_name=first_n and last_name=last_n and born_data = data_born into id_pat;
    insert into links_Doctors_patients(id_doctor, id_patients, recording_time)
    values (ID_DOC.serial_doctor_key,id_pat.serial_key,now());
    return 'Registration was succesfull';
exception
    when others then return 'wrong';
end$$
LANGUAGE plpgsql;
select *
from patients;

-----------------ДОКТОР К КОТОРОМУ ЗАПИСАЛИСЬ--------------------------------
DROP FUNCTION IF EXISTS view_recording_doctor(doctor_id int);
CREATE OR REPLACE FUNCTION view_recording_doctor(doctor_id int) RETURNS SETOF Doctors  AS
$$
BEGIN
    RETURN QUERY
    select * from Doctors  where serial_doctor_key=doctor_id ;
EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE 'SQLSTATE: %', SQLSTATE;
    RAISE NOTICE 'Illegal operation: %', SQLERRM;
    RETURN;
end$$
LANGUAGE plpgsql;

select *
from patients;
select *
from view_recording_doctor(3);
-----------------------------УДАЛИТЬ ПАЦИЕНТА----------------------------------------------

CREATE OR REPLACE FUNCTION delete_patients(pat_id int, data_born date) RETURNS varchar  AS
$$
BEGIN
    delete from links_Doctors_patients  where id_patients=pat_id ;
    delete from patients where serial_key=pat_id and born_data=data_born;
    return 'succesfull delete_patients';
EXCEPTION
    WHEN OTHERS then return 'wrong';
end$$
LANGUAGE plpgsql;

------------------------КАБИНЕТ В КОТОРЫЙ ЗАПИСАНЫ------------------------------
DROP FUNCTION IF EXISTS view_doctor_room(doctor_id int);
CREATE OR REPLACE FUNCTION view_doctor_room(doctor_id int) RETURNS integer  AS
$$
declare
   room_v integer;
BEGIN
    select id_room from room where id_doctor=doctor_id  into room_v;
    return room_v;
EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE 'SQLSTATE: %', SQLSTATE;
    RAISE NOTICE 'Illegal operation: %', SQLERRM;
    RETURN 0;
end$$
LANGUAGE plpgsql;

select *
from view_doctor_room(4);

------------------INSERT RESULTS----------------------------------------------------
CREATE OR REPLACE FUNCTION insert_results(first_name_new varchar(80),last_name_new varchar(80), data_born date) RETURNS varchar  AS
$$
declare
    id integer;
BEGIN
    select serial_key from patients as int where first_name=first_name_new and last_name=last_name_new and born_data=data_born into id;
    RETURN QUERY
        select * from results_analysis_hematologist where id_patients_hematologist=id;
exception
    WHEN OTHERS THEN
    RAISE NOTICE 'SQLSTATE: %', SQLSTATE;
    RAISE NOTICE 'Illegal operation: %', SQLERRM;
    RETURN;
end$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION notack() RETURNS varchar   AS
$$
BEGIN
    return 'Вы не сдавали анализы у этого врача';
exception
    WHEN OTHERS THEN return 'wrong';
end$$
LANGUAGE plpgsql;
------------------VIEW_RESULTS-----------------------------------------------------------------
CREATE OR REPLACE FUNCTION results_analysis_hem(first_name_new varchar(80),last_name_new varchar(80), data_born date) RETURNS SETOF results_analysis_hematologist  AS
$$
declare
    id integer;
BEGIN
    select serial_key from patients as int where first_name=first_name_new and last_name=last_name_new and born_data=data_born into id;
    if (id is null) then
        return ;
    end if;
    RETURN QUERY
        select * from results_analysis_hematologist where id_patients_hematologist=id;
exception
    WHEN OTHERS THEN
    RAISE NOTICE 'SQLSTATE: %', SQLSTATE;
    RAISE NOTICE 'Illegal operation: %', SQLERRM;
    RETURN;
end$$
LANGUAGE plpgsql;

select *
from results_analysis_hem('ss','skk','2011/1/1');
-------------------------------------------------------------
DROP FUNCTION IF EXISTS results_analysis_card(first_name_new varchar(80),last_name_new varchar(80), data_born date);
CREATE OR REPLACE FUNCTION results_analysis_card(first_name_new varchar(80),last_name_new varchar(80), data_born date) RETURNS SETOF results_analysis_cardiologist  AS
$$
declare
    id integer;
BEGIN
    select serial_key from patients as int where first_name=first_name_new and last_name=last_name_new and born_data=data_born into id;
    RETURN QUERY
        select * from results_analysis_cardiologist where id_patients_cardiologist =id;
exception
    WHEN OTHERS THEN
    RAISE NOTICE 'SQLSTATE: %', SQLSTATE;
    RAISE NOTICE 'Illegal operation: %', SQLERRM;
    RETURN;
end$$
LANGUAGE plpgsql;
-----------------------------------------------------------------
DROP FUNCTION IF EXISTS results_analysis_surg(first_name_new varchar(80),last_name_new varchar(80), data_born date);
CREATE OR REPLACE FUNCTION results_analysis_surg(first_name_new varchar(80),last_name_new varchar(80), data_born date) RETURNS SETOF results_analysis_surgeon  AS
$$
declare
    id integer;
BEGIN
    select serial_key from patients as int where first_name=first_name_new and last_name=last_name_new and born_data=data_born into id;
    RETURN QUERY
        select * from results_analysis_surgeon where id_patients_surgeon =id;
exception
    WHEN OTHERS THEN
    RAISE NOTICE 'SQLSTATE: %', SQLSTATE;
    RAISE NOTICE 'Illegal operation: %', SQLERRM;
    RETURN;
end$$
LANGUAGE plpgsql;
-----------------------------------------------------------------
CREATE OR REPLACE FUNCTION results_analysis_trauma(first_name_new varchar(80),last_name_new varchar(80), data_born date) RETURNS SETOF results_analysis_traumatologist  AS
$$
declare
    id integer;
BEGIN
    select serial_key from patients as int where first_name=first_name_new and last_name=last_name_new and born_data=data_born into id;
    RETURN QUERY
        select * from results_analysis_traumatologist where id_patients_traumatologist =id;
exception
    WHEN OTHERS THEN
    RAISE NOTICE 'SQLSTATE: %', SQLSTATE;
    RAISE NOTICE 'Illegal operation: %', SQLERRM;
    RETURN;
end$$
LANGUAGE plpgsql;
-----------------------------------------------------------------
CREATE OR REPLACE FUNCTION results_analysis_opht(first_name_new varchar(80),last_name_new varchar(80), data_born date) RETURNS SETOF results_analysis_ophthalmologist  AS
$$
declare
    id integer;
BEGIN
    select serial_key from patients as int where first_name=first_name_new and last_name=last_name_new and born_data=data_born into id;
    RETURN QUERY
        select * from results_analysis_ophthalmologist where id_patients_ophthalmologist =id;
exception
    WHEN OTHERS THEN
    RAISE NOTICE 'SQLSTATE: %', SQLSTATE;
    RAISE NOTICE 'Illegal operation: %', SQLERRM;
    RETURN;
end$$
LANGUAGE plpgsql;
---------------------------ОСТАВЛЕННЫЕ ЗАПРОСЫ-----------------------------------------
create table send(
    id serial ,
   first_name varchar(80),
   last_name varchar(80),
   commit varchar(300),
   primary key (id,first_name,last_name)
);
CREATE OR REPLACE FUNCTION send_email(first_name_new varchar(80),last_name_new varchar(80), commit_n varchar(300)) RETURNS varchar  AS
$$
BEGIN
    insert into send(first_name,last_name,commit)
    values (first_name_new,last_name_new,commit_n);
    return 'Succesfull';
exception
    WHEN OTHERS THEN RETURN 'wrong';
end$$
LANGUAGE plpgsql;

select *
from send_email('ss','ss','sssssssssssssssssssssssssssssss');

insert into send(id,first_name,last_name)
    values ('ss','ss','sssssssssssssssssssssssssssssss');





select *
from patients;
select *
from links_Doctors_patients;

select *
from results_analysis_cardiologist;

insert into results_analysis_cardiologist(id_patients_cardiologist, id_doctors_cardiologist, interval_PQ, interval_QRS, interval_QT)
values (12,2,2,2,2);

insert into results_analysis_surgeon(id_patients_surgeon, id_doctors_surgeon, pathology, general_state)
values (8,4,'не обнаружено','здоров');






