import string

import psycopg2 as lib
from Authorization import authentification

def Help():
    print('Здравствуйте, это регистратура экстренной помощи')
    print('Что вас интересует?')
    print('Выберете из списка(Укажите номер) :')
    print('0.Запись к врачу\n'
          '1.Узнать результаты анализов\n'
          '2.История болезни\n'
          '3.Нужна экстренная помощь\n'
          '4.Другое\n')
    print('Ваш выбор:\n')
    number_hurt = int(input())
    if(number_hurt<0 or number_hurt>4 ):
        print('Invalid argument, Enter namber from 0 to 4')
        return -2
    print('Вы ввели:' + str(number_hurt))
    return number_hurt



def registr_to_doctor(first_name,last_name,doctor_id,data_born):
    db1 = lib.connect(dbname="postgres", user="postgres", password="89831318520", host="127.0.0.1", port="5433")
    mycursor1 = db1.cursor()
    try:
        mycursor1.execute('SELECT *  FROM insert_new_patients(%(p1)s,%(p2)s,%(p3)s,%(p4)s);', {"p1":first_name,"p2": last_name, "p3": doctor_id,"p4": data_born})
        #print('\nКабинет №:')
        mycursor1.execute('SELECT *  FROM view_recording_doctor(%(p6)s);', {"p6": doctor_id})
        print('\nДоктор')
        for row in mycursor1:
            print(row)
        mycursor1.execute('SELECT *  FROM view_doctor_room(%(p5)s);', {"p5": doctor_id})
        print('\nКабинет №:')
        for row in mycursor1:
            print(row)
        db1.commit()
    except (Exception, lib.DatabaseError) as error:
        print(error)
    finally:
        mycursor1.close()
        if db1 is not None:
            db1.close()



def Registratura():

    db1 = lib.connect(dbname="postgres", user="postgres", password="89831318520", host="127.0.0.1", port="5433")
    mycursor1 = db1.cursor()
    try:
        print('id  имя      фамилия  специальность')
        mycursor1.execute('SELECT *  FROM DOCTORS;')
        for row in mycursor1:
            print(row)
        db1.commit()
    except (Exception, lib.DatabaseError) as error:
        print(error)
    finally:
        mycursor1.close()
        if db1 is not None:
            db1.close()
    print('\nК какому врачу вы хотите записаться?')
    print('Введите номер врача:')
    doctor_number = int(input())
    print('\nВведите ваше имя:')
    first_n = str(input())
    print('\nВведите вашу фамилию:')
    last_n = str(input())
    print('\nВведите вашу дату рождения в  формате :'+'2021/2/1')
    data_n = str(input())
    registr_to_doctor(first_n, last_n, doctor_number,data_n)


def Emergency():
    print ('Укажите ваш адрес')
    address = str(input())
    db1 = lib.connect(dbname="postgres", user="postgres", password="89831318520", host="127.0.0.1", port="5433")
    mycursor1 = db1.cursor()
    try:
        mycursor1.execute('SELECT *  FROM insert_new_emrgency_call(%(h2)s);',{"h2": address})
        for row in mycursor1:
            print(row)
        db1.commit()
    except (Exception, lib.DatabaseError) as error:
        print(error)
    finally:
        mycursor1.close()
        if db1 is not None:
            db1.close()

def Results_analysis():
    print("У какого врача вы сдавали анализы?")
    db2 = lib.connect(dbname="postgres", user="postgres", password="89831318520", host="127.0.0.1", port="5433")
    mycursor2 = db2.cursor()
    try:
        print('id  имя   фамилия  специальность')
        mycursor2.execute('SELECT *  FROM DOCTORS;')
        for row in mycursor2:
            print(row)
        db2.commit()
    except (Exception, lib.DatabaseError) as error:
        print(error)
    finally:
        mycursor2.close()
        if db2 is not None:
            db2.close()
    print("Введите ID врача")
    type_doctor = int(input())
    print("Введите своё имя")
    first_n= str(input())
    print("Введите свою фамилию")
    last_n = str(input())
    print('\nВведите вашу дату рождения в  формате :'+'2021/2/1')
    data_n = str(input())
    View_results(type_doctor, first_n, last_n, data_n)

def View_results(type_doctor,first_n,last_n,data_n):
    db1 = lib.connect(dbname="postgres", user="postgres", password="89831318520", host="127.0.0.1", port="5433")
    mycursor1 = db1.cursor()
    try:
        if type_doctor == 2:
            select = 'SELECT *  FROM results_analysis_card(%(h2)s,%(h1)s,%(h3)s);'
            print('id1,id2,PQ,QRS,QT')
            mycursor1.execute(select,{"h2": first_n,"h1": last_n,"h3": data_n})
        elif type_doctor==3:
            select= 'SELECT *  FROM results_analysis_hem(%(h2)s,%(h1)s,%(h3)s);'
            print('id1,id2,WBC,RBC,HBC')
            mycursor1.execute(select,{"h2": first_n, "h1": last_n, "h3": data_n})
        elif type_doctor==4:
            select = 'SELECT *  FROM results_analysis_surg(%(h2)s,%(h1)s,%(h3)s);'
            print('id1,id2,pathology,general_state')
            mycursor1.execute(select,{"h2": first_n, "h1": last_n, "h3": data_n})
        elif type_doctor==5:
            select = 'SELECT *  FROM results_analysis_trauma(%(h2)s,%(h1)s,%(h3)s);'
            print('id1,id2,fractures,commit')
            mycursor1.execute(select,{"h2": first_n, "h1": last_n, "h3": data_n})
        elif type_doctor==6:
            select = 'SELECT *  FROM results_analysis_opht(%(h2)s,%(h1)s,%(h3)s);'
            print('id1,id2,refractomitry,hrustalik')
            mycursor1.execute(select,{"h2": first_n, "h1": last_n, "h3": data_n})
        # select = mycursor1.fetchall()
        # if select=='no results to fetch':
        #     print('no results to fetch')
        # else:
        #     print(select)
        for row in mycursor1:
            print(row)

        db1.commit()
    except (Exception, lib.DatabaseError) as error:
            print(error)
    finally:
            mycursor1.close()
            if db1 is not None:
                db1.close()

def Commit():
    print("Оставьте свою заявку и мы с вами свяжемся")
    print("Введите своё имя")
    first_n = str(input())
    print("Введите свою фамилию")
    last_n = str(input())
    print("Введите ваш номер телефона")
    phone_n = str(input())
    print('\nВведите ваш отзыв')
    commit_1 = str(input())
    db2 = lib.connect(dbname="postgres", user="postgres", password="89831318520", host="127.0.0.1", port="5433")
    mycursor2 = db2.cursor()
    try:
        mycursor2.execute('SELECT *  FROM send_email(%(h2)s,%(h1)s,%(h3)s,%(h4)s);',{"h2": first_n, "h1": last_n, "h3": commit_1,"h4": phone_n})
        for row in mycursor2:
            print(row)
        db2.commit()
    except (Exception, lib.DatabaseError) as error:
        print(error)
    finally:
        mycursor2.close()
        if db2 is not None:
            db2.close()
    print("Ваш отзыв отправлен,мы с вами свяжемся")

def View_history():
    print("Введите своё имя")
    first_n = str(input())
    print("Введите свою фамилию")
    last_n = str(input())
    print('\nВведите вашу дату рождения в  формате :' + '2021/2/1')
    data_n = str(input())
    db2 = lib.connect(dbname="postgres", user="postgres", password="89831318520", host="127.0.0.1", port="5433")
    mycursor2 = db2.cursor()
    try:
        print('id  имя   фамилия    дата рожд.              врач                время посещ.')
        mycursor2.execute('SELECT *  FROM  view_history(%(h2)s,%(h1)s,%(h3)s);',
                          {"h2": first_n, "h1": last_n, "h3": data_n})
        for row in mycursor2:
            print(row)
        db2.commit()
    except (Exception, lib.DatabaseError) as error:
        print(error)
    finally:
        mycursor2.close()
        if db2 is not None:
            db2.close()



operations = [Registratura,Results_analysis,View_history,Emergency,Commit]


def main():
    check=False
    while (check!=True):
        check = authentification()

    ans=1
    if(check == True):
        while (ans !=0):

            i = Help()
            if (i == -2):
                print('Повторите попытку')
            else:
                action = operations[i]
                action()
                print('Хотите продолжить сеанс?')
                print('Введите 1-Да 0-Нет:\n')
                ans = int(input())
                if ans == 0:
                    print('Хорошего дня! До свидания!')
    else:
        print('Incorrect password or login')


main()




