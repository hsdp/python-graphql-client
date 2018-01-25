from setuptools import setup, find_packages

setup(
    name="graphql_client",
    description="A GraphQL Client",
    version="0.1",
    packages=find_packages(),
    install_requires=[
        'requests'
    ],

    url='https://github.com/hsdp/python-graphql-client.git',
    license="Apache-2.0",

    # Meta Data
    author="Kevin Smithson",
    author_email="kevin.smithson@philips.com"
)

