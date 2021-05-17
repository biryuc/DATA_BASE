import psycopg2 as lib


def Help():
    print('Здравствуйте, это регистратура экстренной помощи')
    print('Что вас интересует?')
    print('Выберете из списка(Укажите номер) :')
    print('0.Запись к врачу\n'
          '1.Узнать результаты анализов\n'
          '2.Нужна экстренная помощь\n'
          '3.Другое\n'
          '4.Закончить сеанс\n')
    print('Ваш выбор:\n')
    number_hurt = int(input())
    if(number_hurt<0 or number_hurt>4 ):
        print('Invalid argument, Enter namber from 0 to 4')
    print('Вы ввели:' + str(number_hurt))
    return number_hurt



def registr_to_doctor(first_name,last_name,doctor_id,data_born):
    db1 = lib.connect(dbname="postgres", user="postgres", password="89831318520", host="127.0.0.1", port="5433")
    mycursor1 = db1.cursor()
    try:
        mycursor1.execute('SELECT *  FROM insert_new_patients(%(p1)s,%(p2)s,%(p3)s,%(p4)s);', {"p1":first_name,"p2": last_name, "p3": doctor_id,"p4": data_born})
        #print('\nКабинет №:')
        #mycursor1.execute('SELECT *  FROM view_recording_doctor(%(p6)s);', {"p6": doctor_id})
        # mycursor2.execute('SELECT *  FROM view_doctor_room(%(p5)s);', {"p5": doctor_id})

        for row in mycursor1:
            print(row)
        db1.commit()
    except (Exception, lib.DatabaseError) as error:
        print(error)
    finally:
        mycursor1.close()
        if db1 is not None:
            db1.close()



def registratura():

    db1 = lib.connect(dbname="postgres", user="postgres", password="89831318520", host="127.0.0.1", port="5433")
    mycursor1 = db1.cursor()
    try:
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


def emergency():
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

def results_analysis():
    print("У какого врача вы сдавали анализы?")
    db2 = lib.connect(dbname="postgres", user="postgres", password="89831318520", host="127.0.0.1", port="5433")
    mycursor2 = db2.cursor()
    try:
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
    view_results(type_doctor, first_n, last_n, data_n)

def view_results(type_doctor,first_n,last_n,data_n):
    db1 = lib.connect(dbname="postgres", user="postgres", password="89831318520", host="127.0.0.1", port="5433")
    mycursor1 = db1.cursor()
    try:
        if type_doctor == 2:
            print('id1,id2,PQ,QRS,QT')
            mycursor1.execute('SELECT *  FROM results_analysis_card(%(h2)s,%(h1)s,%(h3)s);',{"h2": first_n,"h1": last_n,"h3": data_n})
        elif type_doctor==3:
            print('id1,id2,WBC,RBC,HBC')
            mycursor1.execute('SELECT *  FROM results_analysis_hem(%(h2)s,%(h1)s,%(h3)s);',{"h2": first_n, "h1": last_n, "h3": data_n})
        elif type_doctor==4:
            print('id1,id2,pathology,general_state')
            mycursor1.execute('SELECT *  FROM results_analysis_surg(%(h2)s,%(h1)s,%(h3)s);',{"h2": first_n, "h1": last_n, "h3": data_n})
        elif type_doctor==5:
            print('id1,id2,fractures,commit')
            mycursor1.execute('SELECT *  FROM results_analysis_trauma(%(h2)s,%(h1)s,%(h3)s);',{"h2": first_n, "h1": last_n, "h3": data_n})
        elif type_doctor==6:
            print('id1,id2,refractomitry,hrustalik')
            mycursor1.execute('SELECT *  FROM results_analysis_opht(%(h2)s,%(h1)s,%(h3)s);',{"h2": first_n, "h1": last_n, "h3": data_n})
        for row in mycursor1:
            print(row)
        db1.commit()
    except (Exception, lib.DatabaseError) as error:
            print(error)
    finally:
            mycursor1.close()
            if db1 is not None:
                db1.close()
def end():
    print('Хорошего дня! До свидания!')
    ans = 0

def commit():
    print("Оставьте свою заявку и мы с вами свяжемся")
    print("Введите своё имя")
    first_n = str(input())
    print("Введите свою фамилию")
    last_n = str(input())
    print('\nВведите ваш отзыв')
    commit_1 = str(input())
    db2 = lib.connect(dbname="postgres", user="postgres", password="89831318520", host="127.0.0.1", port="5433")
    mycursor2 = db2.cursor()
    try:
        mycursor2.execute('SELECT *  FROM send_email(%(h2)s,%(h1)s,%(h3)s);',{"h2": first_n, "h1": last_n, "h3": commit_1})
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

#operations = [registratura,results_analysis,emergency,commit,end]

def main():
    operations = [registratura, results_analysis, emergency, commit, end]
    ans=1
    while (ans !=0):
        i = Help()
        action = operations[i]
        action()
        print('Хотите продолжить сеанс?')
        print('Введите 1-Да 0-Нет:\n')
        ans = int(input())
        if ans == 0:
            print('Хорошего дня! До свидания!')


main()

