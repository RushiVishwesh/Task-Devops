import pymysql

def lambda_handler(event, context):
    try:
        data = [
            {'id': 1, 'name': 'John', 'age': 25},
            {'id': 2, 'name': 'Jane', 'age': 30},
            {'id': 3, 'name': 'Michael', 'age': 28}
        ]

        conn = pymysql.connect(
            host=os.environ['DB_HOST'],
            user=os.environ['DB_USERNAME'],
            password=os.environ['DB_PASSWORD'],
            database=os.environ['DB_NAME'],
            port=3306,
            cursorclass=pymysql.cursors.DictCursor
        )
        
        cursor = conn.cursor()
        cursor.execute(""" CREATE TABLE IF NOT EXISTS Task ( id SERIAL PRIMARY KEY, name VARCHAR(255), age INTEGER) """)

        for row in data:
            cursor.execute(""" INSERT INTO task (name, age) VALUES (%s, %s) """, (row['name'], row['age']))
        
        conn.commit()
        
        return {
            'statusCode': 200,
            'body': 'Data processed successfully'
        }
    
    except Exception as e:
        return {
            'statusCode': 500,
            'body': f'Error: {str(e)}'
        }
    finally:
        cursor.close()
        conn.close()
