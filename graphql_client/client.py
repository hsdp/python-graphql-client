import requests
import json
from typing import Tuple, Dict, Any, Optional

class GraphQLClient(object):
    """
    A GraphQLClient
    """

    def __init__(self, endpoint: str, headers: Optional[Dict[str, str]]=None):
        self.endpoint = endpoint
        self.headers = headers;

    def query(self, query: str, variables: Optional[Dict[str, Any]]=None, operation_name: Optional[str]=None):
        return self.send(query, variables, operation_name=operation_name)

    def query_from_file(self, file, variables: Optional[Dict[str, Any]]=None, operation_name: Optional[str]=None):
        with open(file) as query:
            return self.send(query.read(), variables, operation_name=operation_name)

    def send(
        self,
        query: str,
        variables: Optional[Dict[str, Any]]=None,
        extra_headers: Optional[Dict[str, Any]]=None,
        operation_name: Optional[str]=None,
        extra_data: Optional[Dict[str, Any]]=None
    ):
        data = {
            'query': query,
            'variables': variables,
            'operationName': operation_name
        }

        if extra_data:
            data.update(extra_data)

        headers = {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
        }

        if self.headers:
            headers.update(self.headers)

        if extra_headers:
            headers.update(extra_headers)

        r = requests.post(self.endpoint, data=json.dumps(data), headers=headers)

        return r.json()
