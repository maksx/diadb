import os
from importlib.machinery import SourceFileLoader

from pkg_resources import parse_requirements
from setuptools import find_packages, setup


module_name = 'diadb'

_here = os.path.abspath(os.path.dirname(__file__))
req_path = os.path.join(_here, "requirements", "requirements.txt")
dev_req_path = os.path.join(_here, "requirements", "dev_requirements.txt")

module = SourceFileLoader(
    module_name, os.path.join(module_name, '__init__.py')
).load_module()


def load_requirements(fname: str) -> list:
    requirements = []
    with open(fname, 'r') as fp:
        for req in parse_requirements(fp.read()):
            extras = '[{}]'.format(','.join(req.extras)) if req.extras else ''
            requirements.append(
                '{}{}{}'.format(req.name, extras, req.specifier)
            )
    return requirements


setup(
    name=module_name,
    version=module.__version__,
    author=module.__author__,
    license=module.__license__,
    description=module.__doc__,
    long_description=open('README.rst').read(),
    url='https://github.com/maksx/diadb',
    platforms='all',
    classifiers=[
        'Intended Audience :: Developers',
        'Natural Language :: English',
        'Operating System :: MacOS',
        'Operating System :: POSIX',
        'Programming Language :: Python',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: Implementation :: CPython'
    ],
    python_requires='>=3.8',
    packages=find_packages(exclude=['tests']),
    install_requires=load_requirements(req_path),
    extras_require={'dev': load_requirements(dev_req_path)},
    entry_points={
        'console_scripts': [
            '{0}-api = {0}.api.__main__:main'.format(module_name),
            '{0}-db = {0}.db.__main__:main'.format(module_name)
        ]
    },
    include_package_data=True
)
