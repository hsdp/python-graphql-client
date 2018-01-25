GraphQL Client
==============

Getting Started
---------------

.. code:: python

    client = GraphQLClient('https://www.graphqlhub.com/graphql')

    result = client.query('''
    query ($id: String!) {
        hn2 {
            nodeFromHnId(id: $id, isUserId: true) {
                id
            }
        }
    }
    ''', {'id': 'clayallsopp'})

The client constructor can also take a dictionary of additonal headers
in a keyword argument ``headers`` or as the second parameter.

Tests
-----

To Run Tests

.. code:: bash

    make test
