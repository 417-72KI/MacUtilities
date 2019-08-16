#!/usr/bin/env python3

def main(args):
    import datetime
    dateFormat = args.dateFormat
    dateString = args.dateString
    date = datetime.datetime.strptime(dateString, dateFormat)
    timestamp = int(date.timestamp())
    print(timestamp)

def parse():
    from argparse import ArgumentParser
    usage = '{} FILE [-f --format format] [--help] string'.format(__file__)
    argparser = ArgumentParser(usage=usage)
    argparser.add_argument('-f', '--format', type=str,
                           dest='dateFormat',
                           default="%Y-%m-%dT%H:%M:%S%z",
                           help='date format')
    argparser.add_argument('dateString', type=str,
                           metavar='date_string',
                           help='date string')
    return argparser.parse_args()

if __name__ == '__main__':
    main(parse())
