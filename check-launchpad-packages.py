#!/usr/bin/env python
import optparse
import os.path
import sys
from launchpadlib.launchpad import Launchpad


USAGE = """\
usage: %prog [options] PPA

A PPA should be expressed as ppa:PERSON/PPA-NAME
"""

error=0

def list(lp, archive, sourcepackagenames, distroseries):
    global error

    team, ppa = archive.lstrip("ppa:").split('/')

    filter_kwargs = []
    if not sourcepackagenames:
        sourcepackagenames = (None,)
    if not distroseries:
        distroseries = (None,)
    for spn in sourcepackagenames:
        for ds in distroseries:
            kw = {}
            if ds:
                kw['distro_series'] = str(lp._root_uri) + "ubuntu/" + ds
            if spn:
                kw['exact_match'] = True
                kw['source_name'] = spn
            filter_kwargs.append(kw)
    
    #print "Querying PPA..."
    archive = lp.people[team].getPPAByName(name=ppa)
    sources = []
    for kwargs in filter_kwargs:
        try:
            sources.extend(archive.getPublishedSources(status="Published", **kwargs))
        except:
            error=1
            continue
    for spph in sources:
        value = spph.self_link.split('/')[-1]
        package = spph.source_package_name
        version = spph.source_package_version
        series = spph.distro_series_link.split('/')[-1]
        status = spph.status
        print value, package, series, version, status

def main():
    global USAGE
    global error

    parser = optparse.OptionParser(USAGE)
    parser.add_option("-s", "--sourcepackagename", action="append",
            help="Restrict operation to a specific source package name. "
            "May be specified multiple times.")
    parser.add_option("-d", "--distroseries", action="append",
            help="Restrict operation to a specific distroseries. "
            "May be specified multiple times.")
    options, args = parser.parse_args()
    if len(args) != 1:
        parser.error("incorrect number of arguments: %d required, %d given"
                % (1, len(args)))
    archive, = args
    lp = Launchpad.login_anonymously('just testing', 'production', "/tmp/launchpad", version='devel')
    list(lp, archive, sourcepackagenames=options.sourcepackagename, distroseries=options.distroseries)
    sys.exit(error)


if __name__ == '__main__':
    main()

