# This file is part of the MapProxy project.
# Copyright (C) 2011 Omniscale <http://omniscale.de>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from __future__ import absolute_import

from mapproxy.compat import string_type
import mapproxy.util.rsa
import yaml
import os
from cryptoyaml import CryptoYAML


class YAMLError(Exception):
    pass


def load_yaml_file(file_or_filename):
    """
    Load yaml from file object or filename.
    """
    if isinstance(file_or_filename, string_type):
        with open(file_or_filename, 'rb') as f:
            return load_yaml(f)
    return load_yaml(file_or_filename)


def _load_yaml(doc):
    # try different methods to load yaml
    try:
        if getattr(yaml, '__with_libyaml__', False):
            try:
                return _safe_load_yaml(doc, yaml.load, yaml.CSafeLoader)
            except AttributeError:
                # handle cases where __with_libyaml__ is True but
                # CLoader doesn't work (missing .dispose())
                return yaml.safe_load(doc)
        else:
            return _safe_load_yaml(doc, yaml.safe_load)
    except (yaml.scanner.ScannerError, yaml.parser.ParserError) as ex:
        raise YAMLError(str(ex))


def _safe_load_yaml(doc, yamlloadfunc, loader=None):
    secret_key = _safe_get_env('SECRET_KEY')
    try:
        if secret_key is not None:
            return _load_crypto_yaml(doc.name, secret_key)
        else:
            if loader is not None:
                return yamlloadfunc(doc, loader)
            return yamlloadfunc(doc)
    except:
        if loader is not None:
            return yamlloadfunc(doc, loader)
        return yamlloadfunc(doc)


def _load_crypto_yaml(doc, key):
    return CryptoYAML(doc, key).data


def _safe_get_env(key):
    try:
        val = os.environ[key]
        return val
    except KeyError:
        return None


def load_yaml(doc):
    """
    Load yaml from file object or string.
    """
    data = _load_yaml(doc)
    if type(data) is not dict:
        # all configs are dicts, raise YAMLError to prevent later AttributeErrors (#352)
        raise YAMLError("configuration not a YAML dictionary")
    return data

