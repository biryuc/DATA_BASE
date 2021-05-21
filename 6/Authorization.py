import cv2
import qrcode
import psycopg2 as lib
img_name = "1.png"

def generate_QR_code(data="1234", img_name="1.png"):
    img = qrcode.make(data)
    img.save(img_name)
    return img


def video_reader():

    cam = cv2.VideoCapture(0, cv2.CAP_DSHOW)
    detector = cv2.QRCodeDetector()
    while True:
        _, img = cam.read()
        data, bbox, _ = detector.detectAndDecode(img)
        if data:
            print("QR Code detected-->", data)
            return data
            break
        # cv2.imshow("img", img)
        # if cv2.waitKey(1) == ord("Q"):
        #     break
    cam.release()
    cv2.destroyAllWindows()


def authentification():
    print('Enter login')
    log = str(input())
    print('Enter password')
    print('Choose from QR_code-0 or console-1?')
    print('Enter 0 or 1')
    choose = int(input())
    if (choose==0):
        print('Поднесите QR_code к камере')
        password = video_reader()
    elif(choose==1):
        print('Enter :')
        password = input()
    else:
        print('Введите в консоли')
        password = input()
    db1 = lib.connect(dbname="postgres", user="postgres", password="89831318520", host="127.0.0.1", port="5433")
    mycursor1 = db1.cursor()
    try:
        select = 'SELECT password FROM Logandpass where login=(%(h2)s);'
        mycursor1.execute(select,{"h2": log})
        select = mycursor1.fetchall()
        if select==[]:
            print('Login or password incorrect')
            print('\nTry again!')
            return False
        db1.commit()
    except (Exception, lib.DatabaseError) as error:
        print(error)
    finally:
        mycursor1.close()
        if db1 is not None:
            db1.close()
    if  str(select[0][0])==str(password):
        print('\nLogin is correct')
        print('Password is correct\n')
        return True
    else:
        print('Login or password incorrect')
        print('\nTry again!')
        return False






