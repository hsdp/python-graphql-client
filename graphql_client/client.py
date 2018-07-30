import logging
import requests
import json
import sys
from typing import Tuple, Dict, Any, Optional


log = logging.getLogger(__name__)
log_stdout = logging.StreamHandler(sys.stdout)
formatter = logging.Formatter('%(asctime)s [%(name)s] '
                              '%(levelname)s %(message)s')
log_stdout.setFormatter(formatter)
log.addHandler(log_stdout)


class GraphQLClient(object):
    """
    A GraphQLClient
    """

    def __init__(self, endpoint: str, headers: Optional[Dict[str, str]]=None, retries=0):
        self.endpoint = endpoint
        self.headers = headers
        self.retries = retries

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

        if not self.retries:
            r = requests.post(
                self.endpoint,
                data=json.dumps(data),
                headers=headers
            )
            return r.json()

        retries_count = 0
        while retries_count < self.retries:
            try:
                log.info('*** Retrying GraphQL query.. attempt #: {}'
                         .format(retries_count))
                r = requests.post(
                    self.endpoint,
                    data=json.dumps(data),
                    headers=headers
                )
                return r.json()
            except Exception as e:
                log.error('*** GraphQL request failed with exception: {}'
                          .format(e))
            finally:
                retries_count += 1
