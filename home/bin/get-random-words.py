#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# See [1] https://www.eff.org/dice and [2] https://www.eff.org/deeplinks/2016/07/new-wordlists-random-passphrases

import re
from argparse import ArgumentParser
from collections.abc import Sequence
from inspect import getsourcefile
from pathlib import Path
from secrets import randbelow
from sys import stderr
from tokenize import open
from typing import TextIO

class die_rolls:
    def __init__(self, string: str) -> None:
        super().__init__()
        string = string.strip()
        matches = re.match("^[1-6]+$", string)
        if matches is None:
            raise TypeError("diecasts must be a string of one or more digits in the range 1-6")

        base6 = ""
        for c in string:
            base6 += str(int(c) - 1)
        self._int = int(base6,6)
        self._str = string

    def __int__(self):
        return self._int

    def __str__(self):
        return self._str

class WordList(Sequence):
    _parser: re.Pattern = None
    _dataPath: Path = None

    @classmethod
    def doMatch(cls, line: str) -> str:
        if cls._parser is None:
            cls._parser = re.compile("^\s*[1-6]*\s*(\S+)\s*$")
        m = cls._parser.match(line)
        if m:
            return m.group(1)

    def __init__(self, file: str = None, data: str = None) -> None:
        super().__init__()
        self._map: map[str] = None
        self._file: TextIO = None
        self._list: list[str] = None
        if file is not None:
            self._file = open(file)
            self._map = map( self.doMatch, self._file)
        elif data is not None:
            self._map = map( self.doMatch, data.splitlines())
        else:
            raise TypeError("Either file or data must be provided")

    def __del__(self):
        if self._file is not None:
            self._file.close()
    
    def _ensureConcrete(self) -> None:
        if self._list is None:
            self._list = list(self._map)
            del(self._map)

    def __getitem__(self, index: int) -> str:
        self._ensureConcrete()
        return self._list[index]

    def __len__(self) -> int:
        self._ensureConcrete()
        return len(self._list)

    @classmethod
    def fromFile(cls, filename: str) -> "WordList":
        if cls._dataPath is None:
            me = getsourcefile(lambda:0)
            cls._dataPath = Path(me).parent.joinpath("wordlists").resolve(strict=True)
        return cls(file=str(cls._dataPath.joinpath(filename)))

def main() -> int:
    parser = ArgumentParser( description="Prints a cryptographically random list of words." )
    parser.add_argument("count", nargs='?', default="1", type=int)
    parser.add_argument("--list", choices=['large','short','shorter'], default="large")
    parser.add_argument("--delimiter", default=" ")
    parser.add_argument("--rolls", nargs='*', type=die_rolls)

    argv=parser.parse_args()

    if argv.count <= 0:
        parser.error("count must be greater than 0.")
        return 2 # this is unreachable because parser.error exits with code 2, but I leave a return here since it helps readability

    words: WordList = None
    if argv.list == "short":
        words = WordList.fromFile("eff_short_wordlist_1.txt")
    elif argv.list == "shorter":
        words = WordList.fromFile("eff_short_wordlist_2_0.txt")
    else:
        words = WordList.fromFile("eff_large_wordlist.txt")

    indicies = []
    if argv.rolls:
        indicies = list(map( int, argv.rolls))

    countCast = len(indicies)

    if argv.count < countCast:
        print(f"warning: more rolls provided ({countCast}) than the number of words we've been asked to generate ({argv.count}).", file=stderr)
        argv.count = countCast
    elif argv.count > countCast:
        if countCast > 0:
            print(f"warning: not enough diecast strings provided to generate {argv.count} words. Remainder will be randomly generated", file=stderr)
        max = len(words)
        for _ in range(argv.count - countCast):
            indicies.append(randbelow(max))

    output = None
    for i in indicies:
        if output is None:
            output = words[i]
        else:
            output += " " + words[i]

    print(output)

    return 0

if __name__ == "__main__":
      exit(main())