# Archives page builder. Emits Pandoc-ready markdown.
# Copyright (c) Philip Conrad, 2017. All rights reserved.

from argparse import ArgumentParser
from os import listdir, sep
from os.path import isfile, join
import re
from datetime import datetime

yaml_header = """---
title: Philip Conrad
---

Hi there! I'm Philip Conrad.

This page is a mass-dump of all the stuff I've written on this blog.
I like to write about programming and related topics.
"""

# Kinda janky, but beats having to depend on somebody's YAML parser.
def get_title(filename):
    with open(filename, 'r') as f:
        lines = f.readlines()
        yaml_zone = None
        for line in lines:
            # End of YAML. Exit.
            if line.strip() == "---" and yaml_zone:
                break;
            # YAML has begun. Our hunt ensues.
            if line.strip() == "---":
                yaml_zone = True
            # Found our quarry.
            if yaml_zone and line.startswith("title:"):
                front, back = line.split(':', 1)
                return back
        return None


if __name__ == '__main__':
    # Command line interface parser.
    parser = ArgumentParser(description='Archive page generator.')

    # Required arguments.
    parser.add_argument("dir", type=str,
                        action="store",
                        help="directory to build archive from.")

    args = parser.parse_args()
    folder = args.dir

    # Cite: http://stackoverflow.com/a/3207973
    only_files = [f for f in listdir(folder) if isfile(join(folder, f))]

    # Use a regex to find all the blog posts.
    pattern = re.compile("(?P<date>(?P<year>[0-9]{4})-(?P<month>[0-9]{2})-(?P<day>[0-9]{2}))_(?P<title>[-_a-zA-Z0-9]+)\.md")
    articles = [(pattern.match(f), f) for f in only_files if pattern.match(f) is not None]

    def match_to_datetime(match):
        datestr = "{}-{}-{}".format(match.group("year"),
                                    match.group("month"),
                                    match.group("day"))
        return datetime.strptime(datestr, "%Y-%m-%d")

    # Group entries by year and generate the Markdown text.
    years = {}
    for match, filename in reversed(sorted(articles, key=(lambda x: match_to_datetime(x[0])))):
        existing_entries = years.get(match.group('year'))
        title = get_title(folder+sep+filename)  # Need relative path to get to file for parsing.
        out_filename = match.group("title")+".html"
        md_text = """- <time>{}</time> [{}]({})""".format(match.group("date"), title, out_filename)
        if existing_entries is not None:
            years[match.group('year')].append(md_text+"\n")
        else:
            years[match.group('year')] = [md_text+"\n"]

    # Output YAML header (for Pandoc), then the markdown text.
    print yaml_header
    print ""
    for year in reversed(years.keys()):
        print "## {}".format(year)
        for entry in years[year]:
            print entry
        print ""

