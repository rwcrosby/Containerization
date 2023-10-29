import argparse
import mysql.connector as mysql
import sys


def get_args():

    parser = argparse.ArgumentParser("Initialize sample database")

    parser.add_argument("--dbhost", default="k8s-1.local", type=str, help="Database host")
    parser.add_argument("--dbport", default=30003, type=int, help="Database port number")
    parser.add_argument("--dbuser", default="root", type=str, help="Database userid")
    parser.add_argument("--password", required=True, type=str, help="Database password (required)")
    parser.add_argument('files', nargs=argparse.REMAINDER)

    args = parser.parse_args()

    return args


def get_db_connection(args):
    try:
        conn = mysql.connect(
            host=args.dbhost,
            port=args.dbport,
            user=args.dbuser,
            password=args.password)
    except mysql.Error as e:
        sys.exit(f"Error connecting to {args.dbhost}:{args.dbport} as {args.dbuser}: {e}")

    print(f"Connected to {conn.server_host}:{conn._port} as {conn.user}")

    return conn


# Get arguments and process

args = get_args()

# Create the user

with get_db_connection(args) as conn:

    for file in args.files:
        print(f"Processing {file}")
        cursor = conn.cursor()
        with open(file) as f:
            for n, result in enumerate(cursor.execute(f.read(), multi=True)):
                print(f"{n}: {result.statement}")
        conn.commit()
