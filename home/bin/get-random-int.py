#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from argparse import ArgumentParser
from secrets import randbelow
from sys import stderr

def main() -> int:
    parser = ArgumentParser( description="Prints a cryptographically random integer in a chosen range." )
    parser.add_argument("minimum", nargs='?', default="1", type=int)
    parser.add_argument("maximum", nargs='?', default="65536", type=int)

    argv=parser.parse_args()

    if argv.minimum >= argv.maximum:
        parser.error("minimum may not be greater than or equal to the maximum.")
        return 2 # this is unreachable because parser.error exits with code 2, but I leave a return here since it helps readability

    range = argv.maximum - argv.minimum + 1

    print( randbelow( range ) + argv.minimum )
    return 0

if __name__ == "__main__":
      exit(main())