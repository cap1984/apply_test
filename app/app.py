from flask import Flask, render_template

from lib.client import ElasticClient 

application = Flask(__name__)

@application.route("/")
def index():
	elst_client = ElasticClient('http://elastic-vm:9200', index='gbif', type='record')
	return render_template('index.html', result=elst_client.get_all_entries())

@application.errorhandler(500)
def page_not_found(e):
    return render_template('500.html'), 500
