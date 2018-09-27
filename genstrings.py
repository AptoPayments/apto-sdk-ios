#  Created by Johannes Schriewer on 2011-11-30. Modified by Roy Marmelstein 2015-08-05
#  Copyright (c) 2011 planetmutlu.
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#
#  - Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  - Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
#  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
#  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
#  OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
#  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
#  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
#  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
#  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# This script is heavily copied from: https://github.com/dunkelstern/Cocoa-Localisation-Helper

from __future__ import absolute_import
import os, re, subprocess, sys
import fnmatch
import argparse
import codecs, re, chardet
import shutil


def fetch_files_recursive(directory, extension):
    matches = []
    for root, dirnames, filenames in os.walk(directory):
      for filename in fnmatch.filter(filenames, '*' + extension):
          matches.append(os.path.join(root, filename))
    return matches


def fetch_folders_recursive(directory, extension):
    matches = []
    for root, dirnames, filenames in os.walk(directory):
      for dirname in fnmatch.filter(dirnames, '*' + extension):
          matches.append(os.path.join(root, dirname))
    return matches


def find_between(s, first, last):
    try:
        start = s.rindex(first) + len(first)
        end = s.index(last, start)
        return s[start:end]
    except ValueError:
        return ""


format_encoding = 'UTF-16'


def _unescape_key(s):
    return s.replace('\\\n', '')


def _unescape(s):
    s = s.replace('\\\n', '')
    return s.replace('\\"', '"').replace(r'\n', '\n').replace(r'\r', '\r')


def _get_content(filename=None, content=None):
    if content is not None:
        if chardet.detect(content)['encoding'].startswith(format_encoding):
            encoding = format_encoding
        else:
            encoding = 'UTF-8'
        if isinstance(content, str):
            content.decode(encoding)
        else:
            return content
    if filename is None:
        return None
    return _get_content_from_file(filename, format_encoding)


def _get_content_from_file(filename, encoding):
    f = open(filename, 'r')
    try:
        content = f.read()
        if chardet.detect(content)['encoding'].startswith(format_encoding):
            #f = f.decode(format_encoding)
            encoding = format_encoding
        else:
            #f = f.decode(default_encoding)
            encoding = 'utf-8'
        f.close()
        f = codecs.open(filename, 'r', encoding=encoding)
        return f.read()
    except IOError, e:
        print "Error opening file %s with encoding %s: %s" %\
                (filename, format_encoding, e.message)
    except Exception, e:
        print "Unhandled exception: %s" % e.message
    finally:
        f.close()


def parse_strings(content="", filename=None):
    """Parse an apple .strings file and create a stringset with
    all entries in the file.

    See
    http://developer.apple.com/library/mac/#documentation/MacOSX/Conceptual/BPInternational/Articles/StringsFiles.html
    for details.
    """
    if filename is not None:
        content = _get_content(filename=filename)

    stringset = []
    f = content
    if f.startswith(u'\ufeff'):
        f = f.lstrip(u'\ufeff')
    #regex for finding all comments in a file
    cp = r'(?:/\*(?P<comment>(?:[^*]|(?:\*+[^*/]))*\**)\*/)'
    p = re.compile(r'(?:%s[ \t]*[\n]|[\r\n]|[\r]){0,1}(?P<line>(("(?P<key>[^"\\]*(?:\\.[^"\\]*)*)")|(?P<property>\w+))\s*=\s*"(?P<value>[^"\\]*(?:\\.[^"\\]*)*)"\s*;)'%cp, re.DOTALL|re.U)
    #c = re.compile(r'\s*/\*(.|\s)*?\*/\s*', re.U)
    c = re.compile(r'//[^\n]*\n|/\*(?:.|[\r\n])*?\*/', re.U)
    ws = re.compile(r'\s+', re.U)
    end=0
    start = 0
    for i in p.finditer(f):
        start = i.start('line')
        end_ = i.end()
        key = i.group('key')
        comment = i.group('comment') or ''
        if not key:
            key = i.group('property')
        value = i.group('value')
        while end < start:
            m = c.match(f, end, start) or ws.match(f, end, start)
            if not m or m.start() != end:
                print "Invalid syntax: %s" %\
                        f[end:start]
            end = m.end()
        end = end_
        key = _unescape_key(key)
        stringset.append({'key': key, 'value': _unescape(value), 'comment': comment})
    return stringset


def read_existing_translations(directory):
    translations = {}
    for dir in fetch_folders_recursive(directory, '.lproj'):
        language = find_between(dir, '/', '.lproj')
        translations[language] = {}
        for strings_file in fetch_files_recursive(dir, '.strings'):
            file_translations = parse_strings(filename=strings_file)
            for translation in file_translations:
                translations[language][translation['key']] = translation['value']
    return translations


def extract_string_list_from_source_code():
    localizedStringComment = re.compile('NSLocalizedString\("([^"]*)",\s*"([^"]*)"\s*\)', re.DOTALL)
    localizedStringNil = re.compile('NSLocalizedString\("([^"]*)",\s*nil\s*\)', re.DOTALL)
    localized = re.compile('Localized\("([^"]*)"[^\n\r]*\)', re.DOTALL)
    localizedSwift2 = re.compile('"([^"]*)".podLocalized\(\)', re.DOTALL)
    localizedSwift2WithFormat = re.compile('"([^"]*)".localizedFormat\([^\n\r]*\)', re.DOTALL)

    uid = 0
    strings = []
    for file in fetch_files_recursive('.', '.swift'):
        with open(file, 'r') as f:
            content = f.read()
            for result in localizedStringComment.finditer(content):
                uid += 1
                strings.append((result.group(1), result.group(2), file, uid))
            for result in localizedStringNil.finditer(content):
                uid += 1
                strings.append((result.group(1), '', file, uid))
            for result in localized.finditer(content):
                uid += 1
                strings.append((result.group(1), '', file, uid))
            for result in localizedSwift2.finditer(content):
                uid += 1
                strings.append((result.group(1), '', file, uid))
            for result in localizedSwift2WithFormat.finditer(content):
                uid += 1
                strings.append((result.group(1), '', file, uid))

    # prepare regexes
    localizedString = re.compile('"[^=]*=\s*"([^"]*)";')

    # fetch files
    for file in fetch_files_recursive('.', '.xib'):
        tempFile = file + '.strings'
        utf8tempFile = file + '.strings.utf8'
        subprocess.call('ibtool --export-strings-file "' + tempFile + '" "' + file + '" 2>/dev/null', shell=True)
        subprocess.call('iconv -s -f UTF-16 -t UTF-8 "' + tempFile + '" >"' + utf8tempFile + '" 2>/dev/null',
                        shell=True)

        f = open(utf8tempFile, 'r')
        for line in f:
            result = localizedString.match(line)
            if result:
                uid += 1
                strings.append((result.group(1), '', file, uid))
        f.close()

        os.remove(utf8tempFile)
        os.remove(tempFile)

    # find duplicates
    duplicated = []
    filestrings = {}
    for string1 in strings:
        dupmatch = 0
        for string2 in strings:
            if string1[3] == string2[3]:
                continue
            if string1[0] == string2[0]:
                if string1[2] != string2[2]:
                    dupmatch = 1
                break
        if dupmatch == 1:
            dupmatch = 0
            for string2 in duplicated:
                if string1[0] == string2[0]:
                    dupmatch = 1
                    break
            if dupmatch == 0:
                duplicated.append(string1)
        else:
            dupmatch = 0
            if string1[2] in filestrings:
                for fs in filestrings[string1[2]]:
                    if fs[0] == string1[0]:
                        dupmatch = 1
                        break
            else:
                filestrings[string1[2]] = []
            if dupmatch == 0:
                filestrings[string1[2]].append(string1)

    return [filestrings, duplicated]


def write_translations(root_path, language, filestrings, duplicated, existing_translations):
    folder_path = os.path.join(root_path, language + '.lproj')
    shutil.rmtree(folder_path, ignore_errors=True)
    os.mkdir(folder_path)
    file_path = os.path.join(folder_path, 'Localizable.strings')
    f = open(file_path, 'w')
    f.write(codecs.BOM_UTF8)
    for key in filestrings.keys():
        f.write('/*\n * ' + key + '\n */\n')

        strings = filestrings[key]
        for string in strings:
            if string[0] in existing_translations[language]:
                f.write('"' + string[0] + '" = "' + existing_translations[language][string[0]].encode(encoding='utf-8') + '";\n')
            elif string[1] == '':
                f.write('"' + string[0] + '" = "' + string[0] + '";\n'.encode(encoding='utf-8'))
            else:
                f.write('/* ' + string[1] + ' */')
                f.write('"' + string[0] + '" = "' + string[0] + '";\n'.encode(encoding='utf-8'))

        f.write('\n\n')

    # output duplicates
    for string in duplicated:
        if string[1] == '':
            f.write('"' + string[0] + '" = "' + string[0] + '";\n'.encode(encoding='utf-8'))
        else:
            f.write('/* ' + string[1] + ' */')
            f.write('"' + string[0] + '" = "' + string[0] + '";\n'.encode(encoding='utf-8'))
    f.close()

parser = argparse.ArgumentParser(description='iOS Localization files handler.')
parser.add_argument('-i', action='store', help='path containing the language folders')
parser.add_argument('-o', action='store', help='output path where results will be written')
args = parser.parse_args()

# Read existing Localization files
existing_translations = read_existing_translations(args.i)

# Extract strings from source code
filestrings, duplicated = extract_string_list_from_source_code()

# For each language, write new Localization file
for key in existing_translations.keys():
    write_translations(args.o, key, filestrings, duplicated, existing_translations)

