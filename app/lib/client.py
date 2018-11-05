import requests


class ElasticClient(object):
	def __init__(self, url, **kwargs):
		self._url = url
		self._index = kwargs.get('index')
		self._type = kwargs.get('type')

	def get_data_entry(self, rec_id):
		req = requests.get('{}/{}/{}/{}'.format(self._url, self._index, self._type, rec_id))
		req.raise_for_status()
		return req.json()

	def get_rec_total_num(self):
		req = requests.post('{}/{}/_count'.format(self._url, self._index))
		req.raise_for_status()
		return int(req.json().get('count'))

	def get_all_entries(self):
		headers = {'Content-type': 'application/json'}
		body = {'size':10000, 'query': {'match_all':{}}}

		req = requests.get('{}/{}/{}/_search'.format(self._url, self._index, self._type),
						   json=body,
						   headers=headers)
		req.raise_for_status()

		hits = [x for x in req.json().get('hits').get('hits') if not x['_id'].startswith('_search')]
		for item in hits:
			item["_id"] = int(item.get("_id"))

		return sorted(hits, key=lambda x: x['_id'])
