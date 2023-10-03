import mysql.connector as mysql
import sys


def run_file(conn, fn):
    cursor = conn.cursor()
    with open(fn) as f:
        for n, result in enumerate(cursor.execute(f.read(), multi=True)):
            print(f"{n}: {result.statement}")

# def connect(host="k8s-1.local", port=30831): 
def connect(host="localhost", port=3306):
    try:    
        conn = mysql.connect(
            user="root",
            password="example",
            host=host,
            port=port
        )
    except mysql.Error as e:
        print(f"Error connecting to MySQL as root: {e}")
        sys.exit(1)

    return conn

# Create the user

conn = connect()

print(f"Connected to {conn.server_host} as {conn.user}")

run_file(conn, "user.sql")

conn.close()

# Create the table

conn = connect()

print(f"Connected to {conn.server_host} as {conn.user}")

run_file(conn, "schema.sql")


# Load the table

cur = conn.cursor()

cur.execute("INSERT INTO posts (title, content) VALUES (%s, %s)",
            ('First Post', 'Content for the first post'))

cur.execute("INSERT INTO posts (title, content) VALUES (%s, %s)",
            ('Second Post', 'Content for the second post'))

conn.commit()

conn.close()