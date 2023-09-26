import argparse
from flask import Flask, render_template, request, url_for, flash, redirect
import mysql.connector as mysql
import sys
from werkzeug.exceptions import abort


def get_args():

    parser = argparse.ArgumentParser("Simple flask app")

    parser.add_argument("--webport", default=8081, type=int, help="Server port number")
    parser.add_argument("--dbhost", default="mysql", type=str, help="Database host")
    parser.add_argument("--dbport", default=3306, type=int, help="Database port number")
    parser.add_argument("--dbuser", default="flask", type=str, help="Database userid")
    parser.add_argument("--password", required=True, type=str, help="Database password (required)")
    parser.add_argument("--database", default="flask", type=str, help="App database name")

    args = parser.parse_args()

    return args


def get_db_connection():
    try:
        conn = mysql.connect(
            host=args.dbhost,
            port=args.dbport,
            user=args.dbuser,
            password=args.password,
            database=args.database)
    except mysql.Error as e:
        print(f"Error connecting to {args.dbhost}:{args.dbport} as {args.dbuser}: {e}")
        abort(404)

    print(f"Connected to {conn.server_host}:{conn._port} as {conn.user}")

    return conn


def get_post(post_id):
    with get_db_connection() as conn:
        cur = conn.cursor(dictionary=True)
        post = cur.execute('SELECT * FROM posts WHERE id = %s',
                           (post_id,))
        post = cur.fetchone()

    if post is None:
        abort(404)
    return post


app = Flask(__name__)
# app.config['SECRET_KEY'] = 'your secret key'


@app.route('/')
def index():
    with get_db_connection() as conn:
        cur = conn.cursor(dictionary=True)
        cur.execute('SELECT * FROM posts')
        posts = cur.fetchall()
    return render_template('index.html', posts=posts)


@app.route('/<int:post_id>')
def post(post_id):
    post = get_post(post_id)
    return render_template('post.html', post=post)


@app.route('/create', methods=('GET', 'POST'))
def create():
    if request.method == 'POST':
        title = request.form['title']
        content = request.form['content']

        if not title:
            flash('Title is required!')
        else:
            with get_db_connection() as conn:
                cur = conn.cursor()
                cur.execute('INSERT INTO posts (title, content) VALUES (%s, %s)',
                            (title, content))
                conn.commit()
            return redirect(url_for('index'))

    return render_template('create.html')


@app.route('/<int:id>/edit', methods=('GET', 'POST'))
def edit(id):
    post = get_post(id)

    if request.method == 'POST':
        title = request.form['title']
        content = request.form['content']

        if not title:
            flash('Title is required!')
        else:
            with get_db_connection() as conn:
                cur = conn.cursor()
                cur.execute('UPDATE posts SET title = %s, content = %s'
                            ' WHERE id = %s',
                            (title, content, id))
                conn.commit()
            return redirect(url_for('index'))

    return render_template('edit.html', post=post)


@app.route('/<int:id>/delete', methods=('POST',))
def delete(id):
    post = get_post(id)
    with get_db_connection() as conn:
        cur = conn.cursor()
        cur.execute('DELETE FROM posts WHERE id = %s', (id,))
        conn.commit()
    flash('"{}" was successfully deleted!'.format(post['title']))
    return redirect(url_for('index'))


if __name__ == "__main__":

    print(sys.argv)

    args = get_args()
    app.run(debug=False, host='0.0.0.0', port=args.webport)
