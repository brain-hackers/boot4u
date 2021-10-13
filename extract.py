#!/usr/bin/env python3

import sys
from elftools.elf.elffile import ELFFile  # pip install pyelftools


def main():
    if len(sys.argv) < 3:
        print(f'Usage: {sys.argv[0]} in.elf out.bin')
        sys.exit(1)

    with open(sys.argv[-2], 'rb') as f:
        extract(ELFFile(f))


def extract(elf):
    text = elf.get_section_by_name('.text')
    if text is None:
        print('Input ELF has no .text section', file=sys.stderr)
        sys.exit(1)

    with open(sys.argv[-1], 'wb') as f:
        if '-p' in sys.argv:
            print(f'Pure .text mode is enabled')
            f.write(text.data())
        else:
            elf.stream.seek(0)
            elf.stream.read(text.header.sh_offset)
            f.write(elf.stream.read())

    print(f'Successfully extracted the necessary sections to "{sys.argv[2]}"')


main()
