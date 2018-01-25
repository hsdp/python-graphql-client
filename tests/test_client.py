from graphql_client import GraphQLClient

GRAPHQL_API = 'https://www.graphqlhub.com/graphql'

def test_query():
    client = GraphQLClient(GRAPHQL_API)
    id = 'clayallsopp'

    result = client.query('''
    query {
        hn2 {
            nodeFromHnId(id: "clayallsopp", isUserId: true) {
                id
                ...on HackerNewsV2User {
                    hnId
                }
            }
        }
    }
    ''')

    assert 'data' in result
    assert result['data']['hn2']['nodeFromHnId']['hnId'] == id

def test_query_with_variables():
    client = GraphQLClient(GRAPHQL_API)
    id = 'clayallsopp'

    result = client.query('''
    query ($id: String!) {
        hn2 {
            nodeFromHnId(id: $id, isUserId: true) {
                id
                ...on HackerNewsV2User {
                    hnId
                }
            }
        }
    }
    ''', {'id': id})

    assert 'data' in result
    assert result['data']['hn2']['nodeFromHnId']['hnId'] == id
