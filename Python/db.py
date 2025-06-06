from flask_mysqldb import MySQL

def init_db(app):
    app.config['MYSQL_HOST'] = 'localhost'
    app.config['MYSQL_USER'] = 'root'
    app.config['MYSQL_PASSWORD'] = '1744444218Ms@'
    app.config['MYSQL_DB'] = 'mydb'

    mysql = MySQL(app)
    return mysql
