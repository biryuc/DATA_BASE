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
       ('Birychkov','Nikita','hematologist'),
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

select *
from logandpass;

-------------Links Doctors to patients-------------
create table links_Doctors_patients(
    id_doctor serial ,
    id_patients serial ,
    recording_time date,
    primary key (id_patients,id_doctor,recording_time),
    foreign key (id_doctor) references Doctors (serial_doctor_key),
    foreign key (id_patients) references Patients (serial_key)
);

-----Экстренная помощь------------
drop table if exists emergency;
create table emergency(
    id_doctor serial,
    address varchar(80),
    primary key (id_doctor,address)
);

---------results_analysis----------
drop table if exists results_analysis_cardiologist,results_analysis_hematologist,results_analysis_surgeon,results_analysis_traumatologist,results_analysis_ophthalmologist cascade;
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
select *
from Patients;
-----------------ДОБАВЛЕНИЕ НОВОГО ПАЦИЕНТА--------------------------------------
DROP FUNCTION IF EXISTS insert_new_patients(first_n varchar(80) , last_n_1 varchar(80),doctor_id int,data_born date);

CREATE OR REPLACE FUNCTION insert_new_patients(first_n varchar(80) , last_n_1 varchar(80),doctor_id int,data_born date) RETURNS varchar  AS
$$
declare
    id_pat_1 integer;
    ID_DOC integer;
    spec varchar;
BEGIN
    select serial_doctor_key from Doctors where serial_doctor_key= doctor_id into ID_DOC;
    insert into patients(first_name,last_name,born_data)
    values (first_n,last_n_1,data_born);
    select serial_key from patients where first_name=first_n and last_name=last_n_1 and born_data = data_born into id_pat_1;
    insert into links_Doctors_patients(id_doctor, id_patients, recording_time)
    values (ID_DOC,id_pat_1,now());
    select specialty from Doctors where serial_doctor_key=doctor_id into spec;
    insert into history(id_pat, name, last_n, born_date, doctors, time)
    values (id_pat_1,first_n,last_n_1,data_born,spec,now());
    return 'Registration was succesfull';
exception
    when others then return 'wrong';
end$$
LANGUAGE plpgsql;


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
    insert into history(id_pat, name, last_n, born_date, doctors, time)
    values (id,first_name_new,last_name_new,data_born,'hematologist',now());
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
select * from results_analysis_hematologist;

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
drop table if exists send;
create table send(
    id serial ,
   first_name varchar(80),
   last_name varchar(80),
   commit varchar(300),
   phone_number int,
   primary key (id,first_name,last_name)
);
CREATE OR REPLACE FUNCTION send_email(first_name_new varchar(80),last_name_new varchar(80), commit_n varchar(300),phone int) RETURNS varchar  AS
$$
BEGIN
    insert into send(first_name,last_name,commit,phone_number)
    values (first_name_new,last_name_new,commit_n,phone);
    return 'Succesfull';
exception
    WHEN OTHERS THEN RETURN 'wrong';
end$$
LANGUAGE plpgsql;
-------------------ЛОГИНЫ и ПАРОЛИ---------------------------
drop table if exists Logandpass;
create table Logandpass(
    id_pat int,
    login varchar(30) not null unique ,
    password int not null unique,
    primary key(id_pat,login,password),
    foreign key (id_pat) references Patients(serial_key)
);


--------------------Создание пароля и логина конкретному пациенту-------------------------
drop function if exists new_user(new_login varchar(30),new_password int);
CREATE OR REPLACE FUNCTION new_user(new_id int ,new_login varchar(30),new_password int) RETURNS integer AS
$$
BEGIN
         INSERT INTO logandpass (id_pat,login, password)
         VALUES (new_id,new_login,new_password);
         return 1;
exception
    WHEN OTHERS THEN
    RAISE NOTICE 'SQLSTATE: %', SQLSTATE;
    RAISE NOTICE 'Illegal operation: %', SQLERRM;
    return -1;
end
$$ LANGUAGE plpgsql;

-------История Болезни-----------------------
drop table if exists History cascade ;
create table History(
    id_pat int,
    name varchar(80),
    last_n varchar(80),
    born_date date,
    doctors varchar(80),
    time date,
    foreign key (id_pat) references Patients (serial_key)
);

---------------Просмотр истории болезни-----------------------------
CREATE OR REPLACE FUNCTION view_history(first_name_new varchar(80),last_name_new varchar(80), data_born date) RETURNS SETOF History  AS
$$
BEGIN
    RETURN QUERY
        select * from history where name= first_name_new and last_n=last_name_new and born_date=data_born;
exception
    WHEN OTHERS THEN
    RAISE NOTICE 'SQLSTATE: %', SQLSTATE;
    RAISE NOTICE 'Illegal operation: %', SQLERRM;
    RETURN;
end$$
LANGUAGE plpgsql;

